import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/format.dart';
import 'paisa_report_reader.dart';
import 'report.dart';
import 'xlsx_writer.dart';

/// Turns a [Report] into a shareable PDF or Excel file.
class ExportService {
  const ExportService._();

  /// Builds the PDF and opens the share sheet. Returns the file name, or
  /// null if the user dismissed the sheet without sharing.
  static Future<String?> sharePdf(Report report) async {
    final bytes = await buildPdf(report);
    final name = '${report.fileStem}.pdf';
    final shared = await Printing.sharePdf(bytes: bytes, filename: name);
    return shared ? name : null;
  }

  /// Builds the .xlsx and asks where to save it. Returns the file name, or
  /// null if the user cancelled.
  static Future<String?> saveXlsx(Report report) async {
    final table = report.table();
    final name = '${report.fileStem}.xlsx';
    final saved = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Excel',
      fileName: name,
      bytes: writeXlsx(
        sheetName: report.book.name,
        headers: table.headers,
        rows: table.rows,
      ),
    );
    return saved == null ? null : name;
  }

  static Future<Uint8List> buildPdf(Report report) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Nunito-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Nunito-ExtraBold.ttf'),
    );
    // Nunito has no Devanagari; Nepali titles, notes and names use Mukta.
    // The pdf package doesn't shape complex scripts, so some conjuncts may
    // render as separate letters, but the text stays readable.
    final devanagari = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Mukta-SemiBold.ttf'),
    );
    const green = PdfColor.fromInt(0xFF0F7A4A);
    const red = PdfColor.fromInt(0xFFD33A3F);
    const grey = PdfColor.fromInt(0xFF5B6870);

    final table = report.table();
    String text(String header, Object value) {
      if (value is! double) return value.toString();
      return switch (header) {
        'Amount' || 'Net' => signedMoney(value, report.currency),
        'Balance' => balanceMoney(value, report.currency),
        _ => report.formatAmount(value),
      };
    }

    final amountColumns = {
      for (var i = 0; i < table.headers.length; i++)
        if (const {
          'Amount',
          'Balance',
          'Cash in',
          'Cash out',
          'Net',
        }.contains(table.headers[i]))
          i,
    };

    final document = pw.Document(
      title: '${report.book.name} — ${report.type.label}',
      author: report.preparedBy.isEmpty ? 'Paisa Flow' : report.preparedBy,
      // The entries, readable by Paisa Flow's import (see
      // PaisaReportReader); summary reports carry none.
      keywords: report.type == ReportType.all
          ? PaisaReportReader.encodeForPdf(report.entries.reversed.toList())
          : null,
      theme: pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        fontFallback: [devanagari],
      ),
    );
    pw.Widget figure(String label, String value, PdfColor color) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: grey)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // Long ledgers: the default 20-page guard trips at ~800 rows.
        maxPages: 1000,
        margin: const pw.EdgeInsets.all(36),
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Paisa Flow',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: green,
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: grey),
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Text(
            report.book.name,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            [
              report.type.label,
              report.rangeLabel,
              report.currency,
              if (report.preparedBy.isNotEmpty)
                'Prepared by ${report.preparedBy}',
              DateFormat('d MMM y').format(DateTime.now()),
            ].join(' · '),
            style: const pw.TextStyle(fontSize: 10, color: grey),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              figure(
                'Cash in',
                '+ ${report.formatAmount(report.inflow)}',
                green,
              ),
              pw.SizedBox(width: 28),
              figure(
                'Cash out',
                '− ${report.formatAmount(report.outflow)}',
                red,
              ),
              pw.SizedBox(width: 28),
              figure(
                'Net',
                signedMoney(report.net, report.currency),
                report.net < 0 ? red : green,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: table.headers,
            data: [
              for (final row in table.rows)
                [
                  for (var i = 0; i < row.length; i++)
                    text(table.headers[i], row[i]),
                ],
            ],
            border: null,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: grey,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: grey, width: .5)),
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFE3E9E6),
                  width: .5,
                ),
              ),
            ),
            cellAlignments: {
              for (final i in amountColumns) i: pw.Alignment.centerRight,
            },
            headerAlignments: {
              for (final i in amountColumns) i: pw.Alignment.centerRight,
            },
          ),
          if (table.rows.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 12),
              child: pw.Text(
                'No entries in this range.',
                style: const pw.TextStyle(color: grey),
              ),
            ),
        ],
      ),
    );
    return document.save();
  }
}

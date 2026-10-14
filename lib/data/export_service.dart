import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/format.dart';
import 'models.dart';

class ExportService {
  static Future<void> exportPdf({
    required LedgerBook book,
    required List<LedgerTransaction> transactions,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Paisa Flow',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(book.name, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Title', 'Type', 'Amount', 'Balance'],
            data: transactions
                .map(
                  (transaction) => [
                    DateFormat.yMd().format(transaction.occurredAt),
                    transaction.title,
                    transaction.type.label,
                    money(transaction.amount, book.currency),
                    balanceMoney(transaction.runningBalance, book.currency),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: '${book.name.replaceAll(' ', '_')}_report.pdf',
    );
  }

  static Future<void> exportExcelLike({
    required LedgerBook book,
    required List<LedgerTransaction> transactions,
  }) async {
    final rows = [
      [
        'Date',
        'Title',
        'Type',
        'Category',
        'Payment Mode',
        'Amount',
        'Balance',
        'Reference',
        'Notes',
      ],
      for (final transaction in transactions)
        [
          DateFormat('yyyy-MM-dd HH:mm').format(transaction.occurredAt),
          transaction.title,
          transaction.type.label,
          transaction.category,
          transaction.paymentMode,
          transaction.amount.toStringAsFixed(2),
          transaction.runningBalance.toStringAsFixed(2),
          transaction.externalReference,
          transaction.notes,
        ],
    ];
    final csv = rows
        .map(
          (row) =>
              row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','),
        )
        .join('\n');
    await FilePicker.platform.saveFile(
      dialogTitle: 'Export Excel-compatible CSV',
      fileName: '${book.name.replaceAll(' ', '_')}_report.csv',
      bytes: Uint8List.fromList(utf8.encode(csv)),
    );
  }
}


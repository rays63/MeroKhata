import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/export_service.dart';
import '../../data/models.dart';
import '../../data/report.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../insights/insights_screen.dart' show displayGroupName;

/// UI labels for the report enums; the enums' own English labels stay for
/// the exported files.
String _typeLabel(AppLocalizations l, ReportType type) => switch (type) {
  ReportType.all => l.reportTypeAll,
  ReportType.daily => l.reportTypeDaily,
  ReportType.category => l.reportTypeCategory,
  ReportType.mode => l.paymentMode,
};

String _typeColumn(AppLocalizations l, ReportType type) => switch (type) {
  ReportType.all => l.reportColumnEntry,
  ReportType.daily => l.reportColumnDay,
  ReportType.category => l.reportColumnCategory,
  ReportType.mode => l.reportColumnMode,
};

String _fieldLabel(AppLocalizations l, ReportField field) => switch (field) {
  ReportField.date => l.reportFieldDate,
  ReportField.title => l.reportFieldTitle,
  ReportField.category => l.category,
  ReportField.mode => l.paymentMode,
  ReportField.notes => l.reportFieldNotes,
  ReportField.balance => l.reportFieldBalance,
  ReportField.reference => l.reportFieldReference,
};

/// Builds a report from the ledger's current filters: pick a type and the
/// fields to include, preview it, then export to PDF or Excel.
class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.bookId,
    required this.entries,
    required this.rangeLabel,
    this.rangeDisplayLabel,
  });

  final String bookId;

  /// The ledger's filtered entries, newest first.
  final List<LedgerTransaction> entries;

  /// Goes into the exported file (always English).
  final String rangeLabel;

  /// Shown on screen in the app's language; defaults to [rangeLabel].
  final String? rangeDisplayLabel;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportType type = ReportType.category;
  final fields = {...ReportField.defaults};
  bool exporting = false;

  static const _typeIcons = {
    ReportType.all: LucideIcons.list,
    ReportType.daily: LucideIcons.calendarDays,
    ReportType.category: LucideIcons.tags,
    ReportType.mode: LucideIcons.wallet,
  };

  Report _report(AppStore store, LedgerBook book) => Report(
    book: book,
    entries: widget.entries,
    type: type,
    fields: fields,
    rangeLabel: widget.rangeLabel,
    preparedBy: store.profile.name.trim(),
  );

  Future<void> _export(Report report, {required bool pdf}) async {
    if (exporting) return;
    setState(() => exporting = true);
    final l = context.l10n;
    try {
      final name = pdf
          ? await ExportService.sharePdf(report)
          : await ExportService.saveXlsx(report);
      if (name != null && mounted) showPfToast(context, l.readyToShare(name));
    } catch (error) {
      if (mounted) showPfToast(context, l.exportFailed('$error'));
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final book = store.bookById(widget.bookId);
    final l = context.l10n;
    if (book == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: PfHeader(title: l.reportTitle),
          ),
        ),
      );
    }
    final c = context.pf;
    final report = _report(store, book);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.reportTitle,
              subtitle:
                  '${book.name} · ${widget.rangeDisplayLabel ?? widget.rangeLabel}',
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 170 / 54,
              children: [
                for (final value in ReportType.values)
                  _TypeTile(
                    label: _typeLabel(l, value),
                    icon: _typeIcons[value]!,
                    selected: type == value,
                    onTap: () => setState(() => type = value),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PfSectionLabel(
              l.reportFieldsToExport(fields.length, ReportField.values.length),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final field in ReportField.values)
                  _FieldChip(
                    label: _fieldLabel(l, field),
                    on: fields.contains(field),
                    onTap: () => setState(() {
                      if (!fields.remove(field)) fields.add(field);
                    }),
                  ),
              ],
            ),
            if (type != ReportType.all) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l.reportFieldsHint,
                  style: pfText(12, weight: w700, color: c.mute),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _Preview(report: report),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PfButton(
                    label: l.reportExportPdf,
                    icon: LucideIcons.fileText,
                    height: 56,
                    fontSize: 15,
                    onPressed: exporting
                        ? null
                        : () => _export(report, pdf: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PfButton(
                    label: l.reportExportExcel,
                    icon: LucideIcons.fileSpreadsheet,
                    style: PfButtonStyle.soft,
                    height: 56,
                    fontSize: 15,
                    onPressed: exporting
                        ? null
                        : () => _export(report, pdf: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = selected ? c.cashIn : c.sub;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.soft : c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? c.pri : c.line, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: pfText(14, color: fg),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({
    required this.label,
    required this.on,
    required this.onTap,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = on ? c.cashIn : c.sub;
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? c.soft : c.card,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  on ? LucideIcons.check : LucideIcons.plus,
                  size: 14,
                  color: fg,
                ),
                const SizedBox(width: 6),
                Text(label, style: pfText(13, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// First rows of the report, as it will be exported, plus the net total.
class _Preview extends StatelessWidget {
  const _Preview({required this.report});

  final Report report;

  static const _maxRows = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final rows = <(String, String, double)>[
      if (report.type == ReportType.all)
        for (final entry in report.chronological.take(_maxRows))
          (
            entry.title,
            '${DateFormat('d MMM').format(entry.occurredAt)} · ${entry.category}',
            entry.signedAmount,
          )
      else
        for (final group in report.groups.take(_maxRows))
          (
            displayGroupName(l, group.key),
            l.entryCount(group.count),
            group.net,
          ),
    ];
    final total = report.type == ReportType.all
        ? report.entries.length
        : report.groups.length;
    final hidden = total - rows.length;
    return PfCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _typeColumn(l, report.type),
                    style: pfText(
                      11,
                      weight: w900,
                      color: c.mute,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                Text(
                  l.reportColumnAmount,
                  style: pfText(
                    11,
                    weight: w900,
                    color: c.mute,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          const PfDivider(),
          for (final (title, meta, amount) in rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: pfText(14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          meta,
                          style: pfText(12, weight: w700, color: c.sub),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    signedMoney(amount, report.currency),
                    style: pfText(
                      14,
                      weight: w900,
                      color: c.amount(amount >= 0),
                    ),
                  ),
                ],
              ),
            ),
            const PfDivider(),
          ],
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                l.reportEmpty,
                style: pfText(14, weight: w700, color: c.sub),
              ),
            ),
          if (hidden > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                l.reportMoreInExport(hidden),
                style: pfText(12.5, color: c.sub),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.reportNet, style: pfText(14, weight: w900)),
                ),
                Text(
                  balanceMoney(report.net, report.currency),
                  style: pfText(14, weight: w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

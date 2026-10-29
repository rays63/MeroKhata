import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import '../entries/entry_form_screen.dart';

/// Shows the due popup once per app open when repeating entries are due.
/// Put it on Home; it draws nothing itself.
class DueWatcher extends StatefulWidget {
  const DueWatcher({super.key});

  @override
  State<DueWatcher> createState() => _DueWatcherState();
}

class _DueWatcherState extends State<DueWatcher> {
  bool showing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppScope.watch(context);
    if (showing || store.dueAskedLater || store.dueEntries().isEmpty) return;
    showing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const DueSheet(),
      );
      // Closing the sheet without choosing counts as "ask me later".
      store.dueAskedLater = true;
      showing = false;
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Due repeating entries, ticked by default: add them, skip them, or be
/// asked later. Nothing is added without this confirmation.
class DueSheet extends StatefulWidget {
  const DueSheet({super.key});

  @override
  State<DueSheet> createState() => _DueSheetState();
}

class _DueSheetState extends State<DueSheet> {
  late List<DueEntry> items = AppScope.read(context).dueEntries();
  late final Set<DueEntry> ticked = {...items};
  bool busy = false;

  Future<void> _finish({required bool add}) async {
    if (busy) return;
    setState(() => busy = true);
    final store = AppScope.read(context);
    final l = context.l10n;
    final added = await store.confirmDue(
      shown: items,
      add: add
          ? [
              for (final i in items)
                if (ticked.contains(i)) i,
            ]
          : const [],
    );
    if (!mounted) return;
    showPfToast(context, l.dueAdded(added));
    Navigator.pop(context);
  }

  /// Opens the entry form filled from this due item; once saved there, the
  /// item is done and leaves the list.
  Future<void> _edit(DueEntry item) async {
    final store = AppScope.read(context);
    final r = item.recurring;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntryFormScreen(
          bookId: r.bookId,
          type: r.type,
          initialWhen: item.due,
          template: EntryTemplate(
            id: '',
            title: r.title,
            type: r.type,
            amount: r.amount,
            category: r.category,
            paymentMode: r.paymentMode,
            bookId: r.bookId,
            tags: r.tags,
          ),
        ),
      ),
    );
    if (saved != true || !mounted) return;
    await store.markDueHandled(item);
    if (!mounted) return;
    setState(() {
      items = [
        for (final i in items)
          if (i != item) i,
      ];
      ticked.remove(item);
    });
    if (items.isEmpty) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final today = DateUtils.dateOnly(DateTime.now());
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: c.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PfIconTile(
                  icon: LucideIcons.calendarClock,
                  background: c.soft,
                  foreground: c.cashIn,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.dueTitle(items.length),
                        style: pfText(19, weight: w900),
                      ),
                      Text(
                        l.dueBody,
                        style: pfText(
                          13,
                          weight: w700,
                          color: c.sub,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in items)
                  _DueRow(
                    item: item,
                    ticked: ticked.contains(item),
                    when: () {
                      final days = today
                          .difference(DateUtils.dateOnly(item.due))
                          .inDays;
                      return days <= 0 ? l.dueToday : l.dueDaysAgo(days);
                    }(),
                    subtitle: item.recurring.isTransfer
                        ? l.transferRowTitle(
                            store.bookById(item.recurring.bookId)?.name ?? '',
                            store.bookById(item.recurring.toBookId!)?.name ??
                                '',
                          )
                        : [
                            item.recurring.category,
                            ?store.bookById(item.recurring.bookId)?.name,
                          ].join(' · '),
                    currency:
                        store.bookById(item.recurring.bookId)?.currency ??
                        store.defaultCurrency,
                    onToggle: () => setState(() {
                      if (!ticked.remove(item)) ticked.add(item);
                    }),
                    onEdit: item.recurring.isTransfer
                        ? null
                        : () => _edit(item),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: PfButton(
              label: l.dueAdd(ticked.length),
              icon: LucideIcons.check,
              onPressed: busy || ticked.isEmpty
                  ? null
                  : () => _finish(add: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: busy ? null : () => _finish(add: false),
                    child: Text(
                      l.dueSkip,
                      style: pfText(14, weight: w800, color: c.sub),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: busy
                        ? null
                        : () {
                            store.dueAskedLater = true;
                            Navigator.pop(context);
                          },
                    child: Text(
                      l.dueLater,
                      style: pfText(14, weight: w800, color: c.sub),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({
    required this.item,
    required this.ticked,
    required this.when,
    required this.subtitle,
    required this.currency,
    required this.onToggle,
    required this.onEdit,
  });

  final DueEntry item;
  final bool ticked;
  final String when;
  final String subtitle;
  final String currency;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final r = item.recurring;
    final isIn = r.type == TransactionType.cashIn;
    final color = r.isTransfer ? c.blue : c.amount(isIn);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Semantics(
            checked: ticked,
            label: l.dueTick(r.title),
            child: Checkbox(
              value: ticked,
              onChanged: (_) => onToggle(),
              activeColor: c.btn,
            ),
          ),
          PfIconTile(
            icon: r.isTransfer
                ? LucideIcons.arrowLeftRight
                : entryIcon(r.category),
            background: r.isTransfer ? c.blueSoft : c.amountSoft(isIn),
            foreground: color,
            size: 38,
            iconSize: 17,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(14.5, weight: w800),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(12, weight: w700, color: c.sub),
                ),
                Text(
                  when,
                  style: pfText(11.5, weight: w800, color: c.gold),
                ),
              ],
            ),
          ),
          Text(
            r.isTransfer
                ? money(r.amount, currency)
                : signedMoney(isIn ? r.amount : -r.amount, currency),
            style: pfText(14, weight: w900, color: color),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: l.dueEdit(r.title),
              onPressed: onEdit,
              icon: Icon(LucideIcons.pencil, size: 16, color: c.sub),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

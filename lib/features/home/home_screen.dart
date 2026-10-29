import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../app/shell.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/pf.dart';
import '../../l10n/l10n.dart';
import '../backup/backup_screen.dart';
import '../repeating/due_sheet.dart';
import '../split/split_bill_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final name = store.profile.name.trim();
    return ListView(
      padding: pagePadding,
      children: [
        // Asks about repeating entries that are due; draws nothing.
        const DueWatcher(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.greeting(),
                    style: pfText(14, weight: w700, color: c.sub),
                  ),
                  Text(
                    name.isEmpty ? context.l10n.appName : name,
                    style: pfText(24, weight: w900, letterSpacing: -.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PfIconButton(
              icon: LucideIcons.search,
              tooltip: context.l10n.search,
              onPressed: () => openSearch(context),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: context.l10n.settings,
              excludeSemantics: true,
              child: Material(
                color: PfColors.avatar,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openSettings(context),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Text(
                        initials(name),
                        style: pfText(15, weight: w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (store.loadError != null) ...[
          const SizedBox(height: 18),
          PfErrorBanner(context.l10n.loadError),
        ],
        if (store.backupReminderDays() case final days?) ...[
          const SizedBox(height: 18),
          _BackupNudge(days: days, store: store),
        ],
        const SizedBox(height: 18),
        _TotalCard(store: store),
        const SizedBox(height: 18),
        const _QuickActions(),
        const SizedBox(height: 18),
        if (store.untypedBooks.isNotEmpty && !store.typePromptLater) ...[
          _TypePrompt(count: store.untypedBooks.length, store: store),
          const SizedBox(height: 18),
        ],
        // Same height side by side, whichever card has more content.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _GoalsCard(store: store)),
              const SizedBox(width: 10),
              const Expanded(child: _SplitCard()),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _RecentActivity(store: store),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    // Only books in the home currency are summed; others are shown
    // separately and never converted.
    final home = store.defaultCurrency;
    final nprIds = {
      for (final book in store.books)
        if (book.currency == home) book.id,
    };
    final now = DateTime.now();
    var monthIn = 0.0, monthOut = 0.0;
    for (final entry in store.transactions) {
      if (!entry.countsAsFlow ||
          !nprIds.contains(entry.bookId) ||
          entry.occurredAt.year != now.year ||
          entry.occurredAt.month != now.month) {
        continue;
      }
      if (entry.type == TransactionType.cashIn) {
        monthIn += entry.amount;
      } else {
        monthOut += entry.amount;
      }
    }
    final totals = store.totalsFor(home);
    final month = DateFormat('MMM').format(now);
    final others = store.accountCurrencies.where((code) => code != home);
    final count = nprIds.length;

    return Container(
      decoration: BoxDecoration(
        color: c.hero,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: c.hero2, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.homeNetWorth(home),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(
                          13,
                          weight: w800,
                          color: PfColors.heroLabel,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => ShellScope.go(context, ShellTab.books),
                        child: PfBadge(
                          label: context.l10n.bookCount(count),
                          pill: true,
                          fontSize: 11,
                          background: Colors.white.withValues(alpha: .16),
                          foreground: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balanceMoney(totals.net, home),
                    style: pfText(
                      34,
                      weight: w900,
                      color: Colors.white,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
                Text(
                  context.l10n.homeAssetsOwed(
                    money(totals.assets, home),
                    money(totals.owed, home),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(12.5, weight: w800, color: PfColors.heroLabel),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        icon: LucideIcons.arrowDownLeft,
                        label: context.l10n.homeCashInMonth(month),
                        value: '+ ${money(monthIn, home)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(
                        icon: LucideIcons.arrowUpRight,
                        label: context.l10n.homeCashOutMonth(month),
                        value: '− ${money(monthOut, home)}',
                      ),
                    ),
                  ],
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context.l10n.homeOtherCurrencies,
                        style: pfText(
                          11.5,
                          weight: w800,
                          color: PfColors.heroLabel,
                        ),
                      ),
                      for (final code in others)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .18),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            balanceMoney(store.totalsFor(code).net, code),
                            style: pfText(
                              12,
                              weight: w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: PfColors.heroLabel),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: pfText(12, weight: w800, color: PfColors.heroLabel),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: pfText(17, weight: w900, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      children: [
        _QuickAction(
          icon: LucideIcons.arrowDownLeft,
          label: context.l10n.cashIn,
          background: c.soft,
          foreground: c.cashIn,
          onTap: () => openNewEntry(context, type: TransactionType.cashIn),
        ),
        _QuickAction(
          icon: LucideIcons.arrowUpRight,
          label: context.l10n.cashOut,
          background: c.outSoft,
          foreground: c.cashOut,
          onTap: () => openNewEntry(context, type: TransactionType.cashOut),
        ),
        _QuickAction(
          icon: LucideIcons.arrowLeftRight,
          label: context.l10n.transfer,
          background: c.blueSoft,
          foreground: c.blue,
          onTap: () => openNewTransfer(context),
        ),
        _QuickAction(
          icon: LucideIcons.split,
          label: context.l10n.splitABill,
          background: c.goldSoft,
          foreground: c.gold,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SplitBillScreen())),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            children: [
              PfIconTile(
                icon: icon,
                background: background,
                foreground: foreground,
                size: 58,
                radius: 20,
                iconSize: 24,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: pfText(12.5, weight: w800, color: context.pf.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final saved = store.goals.fold(
      0.0,
      (sum, goal) => sum + goal.savedAmount.clamp(0, goal.targetAmount),
    );
    final target = store.goals.fold(
      0.0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final count = store.goals.length;
    return _HomeCard(
      title: context.l10n.goals,
      icon: LucideIcons.target,
      iconColor: c.pri,
      onTap: () => openGoals(context),
      children: [
        Text(
          count == 0
              ? context.l10n.setSavingsTarget
              : context.l10n.goalsSaved(
                  money(saved),
                  context.l10n.goalCount(count),
                ),
          style: pfText(12.5, weight: w700, color: c.sub),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: target <= 0 ? 0 : saved / target,
            minHeight: 8,
            backgroundColor: c.card2,
            color: c.pri,
          ),
        ),
      ],
    );
  }
}

class _SplitCard extends StatelessWidget {
  const _SplitCard();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final store = AppScope.watch(context);
    final owe = store.youOwe > store.owedToYou;
    return _HomeCard(
      title: context.l10n.split,
      icon: LucideIcons.users,
      iconColor: c.gold,
      onTap: () => ShellScope.go(context, ShellTab.split),
      children: [
        Text(
          owe ? context.l10n.youOwe : context.l10n.youreOwed,
          style: pfText(12.5, weight: w700, color: c.sub),
        ),
        Text(
          money(owe ? store.youOwe : store.owedToYou, store.defaultCurrency),
          style: pfText(17, weight: w900, color: c.amount(!owe)),
        ),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PfCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: pfText(15, weight: w900)),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _TypePrompt extends StatelessWidget {
  const _TypePrompt({required this.count, required this.store});

  final int count;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.line, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfIconTile(
            icon: LucideIcons.shapes,
            background: c.card2,
            foreground: c.sub,
            size: 40,
            iconSize: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.accountTypePrompt,
                  style: pfText(14.5, weight: w900, height: 1.3),
                ),
                const SizedBox(height: 3),
                Text(
                  l.accountTypePromptBody(count),
                  style: pfText(12.5, weight: w700, color: c.sub, height: 1.4),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PfSmallButton(
                      label: l.accountSetType,
                      height: 36,
                      radius: 12,
                      fontSize: 13,
                      background: c.soft,
                      foreground: c.cashIn,
                      onPressed: () => ShellScope.go(context, ShellTab.books),
                    ),
                    PfSmallButton(
                      label: l.later,
                      height: 36,
                      radius: 12,
                      fontSize: 13,
                      background: Colors.transparent,
                      foreground: c.sub,
                      onPressed: store.dismissTypePrompt,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The latest entries across every account, with "See all".
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final recent = [
      for (final entry in store.entriesNewestFirst)
        if (!entry.isTransferMirror) entry,
    ].take(6).toList();
    final manyAccounts = store.books.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l.homeRecentActivity,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pfText(18, weight: w900),
              ),
            ),
            TextButton(
              onPressed: () => openAllEntries(context),
              child: Text(
                l.seeAll,
                style: pfText(14, weight: w800, color: c.cashIn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          PfEmptyCard(
            icon: LucideIcons.notebookPen,
            title: l.feedEmptyTitle,
            body: l.feedEmptyBody,
            actionLabel: l.feedAddEntry,
            onAction: () =>
                openNewEntry(context, type: TransactionType.cashOut),
          )
        else
          EntryGroupCard(
            children: [
              for (final entry in recent)
                EntryRow(
                  entry: entry,
                  currency:
                      store.bookById(entry.bookId)?.currency ??
                      store.defaultCurrency,
                  account: manyAccounts
                      ? store.bookById(entry.bookId)?.name
                      : null,
                  showBalance: false,
                  onTap: () => openEntry(context, entry.id),
                ),
            ],
          ),
      ],
    );
  }
}

/// Data lives only on this phone; after 30 days without a backup, say so.
class _BackupNudge extends StatelessWidget {
  const _BackupNudge({required this.days, required this.store});

  final int days;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.hardDriveDownload, size: 22, color: c.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.backupNudgeTitle(days), style: pfText(15, weight: w900)),
                const SizedBox(height: 4),
                Text(
                  l.backupNudgeBody,
                  style: pfText(13, weight: w700, color: c.sub, height: 1.4),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PfSmallButton(
                      label: l.backupNow,
                      height: 38,
                      radius: 12,
                      fontSize: 13.5,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BackupScreen()),
                      ),
                    ),
                    PfSmallButton(
                      label: l.later,
                      height: 38,
                      radius: 12,
                      fontSize: 13.5,
                      background: Colors.transparent,
                      foreground: c.sub,
                      onPressed: store.snoozeBackupReminder,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

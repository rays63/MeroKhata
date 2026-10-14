import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../app/shell.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting(),
                    style: pfText(14, weight: w700, color: c.sub),
                  ),
                  Text(
                    name.isEmpty ? 'Paisa Flow' : name,
                    style: pfText(24, weight: w900, letterSpacing: -.4),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PfIconButton(
              icon: LucideIcons.calendarDays,
              tooltip: 'Calendar',
              onPressed: () => openCalendar(context),
            ),
            const SizedBox(width: 10),
            Semantics(
              button: true,
              label: 'Settings',
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
          PfErrorBanner(store.loadError!),
        ],
        const SizedBox(height: 18),
        _TotalCard(store: store),
        const SizedBox(height: 18),
        const _QuickActions(),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _GoalsCard(store: store)),
            const SizedBox(width: 10),
            const Expanded(child: _SplitCard()),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text('Recently updated', style: pfText(18, weight: w900)),
            ),
            TextButton(
              onPressed: () => ShellScope.go(context, ShellTab.books),
              child: Text(
                'See all',
                style: pfText(14, weight: w800, color: c.cashIn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final book in store.booksByRecent.take(3)) ...[
          _RecentBookTile(book: book, store: store),
          const SizedBox(height: 10),
        ],
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
    final nprBooks = store.books.where((book) => book.currency == home);
    final nprIds = nprBooks.map((book) => book.id).toSet();
    final now = DateTime.now();
    var monthIn = 0.0, monthOut = 0.0;
    for (final entry in store.transactions) {
      if (!nprIds.contains(entry.bookId) ||
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
    final total = nprIds.fold(0.0, (sum, id) => sum + store.balanceFor(id));
    final month = DateFormat('MMM').format(now);
    final others = store.books.where((book) => book.currency != home);
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
                        'Total balance · $home',
                        style: pfText(
                          13,
                          weight: w800,
                          color: PfColors.heroLabel,
                        ),
                      ),
                    ),
                    PfBadge(
                      label: '$count ${count == 1 ? 'book' : 'books'}',
                      pill: true,
                      fontSize: 11,
                      background: Colors.white.withValues(alpha: .16),
                      foreground: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balanceMoney(total, home),
                    style: pfText(
                      36,
                      weight: w900,
                      color: Colors.white,
                      letterSpacing: -.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        icon: LucideIcons.arrowDownLeft,
                        label: 'Cash in · $month',
                        value: '+ ${money(monthIn, home)}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(
                        icon: LucideIcons.arrowUpRight,
                        label: 'Cash out · $month',
                        value: '− ${money(monthOut, home)}',
                      ),
                    ),
                  ],
                ),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final book in others)
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
                            '${book.name} · ${balanceMoney(store.balanceFor(book.id), book.currency)}',
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
          label: 'Cash in',
          background: c.soft,
          foreground: c.cashIn,
          onTap: () => openNewEntry(context, type: TransactionType.cashIn),
        ),
        _QuickAction(
          icon: LucideIcons.arrowUpRight,
          label: 'Cash out',
          background: c.outSoft,
          foreground: c.cashOut,
          onTap: () => openNewEntry(context, type: TransactionType.cashOut),
        ),
        _QuickAction(
          icon: LucideIcons.fileUp,
          label: 'Import',
          background: c.blueSoft,
          foreground: c.blue,
          onTap: () => openImport(context),
        ),
        _QuickAction(
          icon: LucideIcons.split,
          label: 'Split a bill',
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
      title: 'Goals',
      icon: LucideIcons.target,
      iconColor: c.pri,
      onTap: () => openGoals(context),
      children: [
        Text(
          count == 0
              ? 'Set a savings target'
              : '${money(saved)} saved · $count ${count == 1 ? 'goal' : 'goals'}',
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
      title: 'Split',
      icon: LucideIcons.users,
      iconColor: c.gold,
      onTap: () => ShellScope.go(context, ShellTab.split),
      children: [
        Text(
          owe ? 'You owe' : "You're owed",
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

class _RecentBookTile extends StatelessWidget {
  const _RecentBookTile({required this.book, required this.store});

  final LedgerBook book;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final balance = store.balanceFor(book.id);
    return PfCard(
      radius: 22,
      padding: const EdgeInsets.all(14),
      onTap: () => openBook(context, book.id),
      child: Row(
        children: [
          BookAvatar(name: book.name, color: Color(book.colorValue)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.name,
                  style: pfText(16, weight: w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  updatedLabel(book.updatedAt),
                  style: pfText(12.5, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balanceMoney(balance, book.currency),
                style: pfText(
                  16,
                  weight: w900,
                  color: balance < 0 ? c.cashOut : c.ink,
                ),
              ),
              Text(
                book.currency,
                style: pfText(11, weight: w800, color: c.sub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

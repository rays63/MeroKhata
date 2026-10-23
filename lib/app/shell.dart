import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/models.dart';
import '../features/books/books_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/split/split_screen.dart';
import '../theme/tokens.dart';
import '../widgets/pf.dart';
import 'nav.dart';
import '../l10n/l10n.dart';

enum ShellTab { home, books, insights, split }

/// Five-slot shell: Home · Books · ＋ · Insights · Split.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final tab = ValueNotifier(ShellTab.home);

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShellScope(
      tab: tab,
      child: ValueListenableBuilder(
        valueListenable: tab,
        builder: (context, current, _) => Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: current.index,
              children: const [
                HomeScreen(),
                BooksScreen(),
                InsightsScreen(),
                SplitScreen(),
              ],
            ),
          ),
          bottomNavigationBar: _TabBar(
            current: current,
            onSelect: (value) => tab.value = value,
          ),
          // A FAB rather than a child of the bar: it overhangs the bar's top
          // edge, and only the Scaffold hit-tests that overhang.
          floatingActionButton: _AddButton(
            onPressed: () =>
                openNewEntry(context, type: TransactionType.cashOut),
          ),
          floatingActionButtonLocation: const _RaisedCenter(),
          floatingActionButtonAnimator:
              FloatingActionButtonAnimator.noAnimation,
        ),
      ),
    );
  }
}

/// Lets screens inside the shell switch tabs (e.g. Home's "See all").
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.tab, required super.child});

  final ValueNotifier<ShellTab> tab;

  static void go(BuildContext context, ShellTab value) {
    context.getInheritedWidgetOfExactType<ShellScope>()?.tab.value = value;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => tab != oldWidget.tab;
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onSelect});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget item(ShellTab value, IconData icon, String label) => Expanded(
      child: _TabItem(
        icon: icon,
        label: label,
        selected: current == value,
        onTap: () => onSelect(value),
      ),
    );
    // Labels stay legible at large text sizes without overflowing the bar.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: _bar(context, c, bottom, item),
    );
  }

  Widget _bar(
    BuildContext context,
    PfColors c,
    double bottom,
    Widget Function(ShellTab, IconData, String) item,
  ) {
    return Container(
      height: 64 + bottom,
      padding: EdgeInsets.fromLTRB(6, 8, 6, bottom),
      decoration: BoxDecoration(
        color: c.tab,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item(ShellTab.home, LucideIcons.house, context.l10n.tabHome),
          item(ShellTab.books, LucideIcons.walletCards, context.l10n.tabBooks),
          const Spacer(),
          item(
            ShellTab.insights,
            LucideIcons.chartPie,
            context.l10n.tabInsights,
          ),
          item(ShellTab.split, LucideIcons.split, context.l10n.tabSplit),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final color = selected ? c.pri : c.mute;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          // Shrinks a few pixels when large text would overflow the bar.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 23, color: color),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: pfText(11, weight: w900, color: color),
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

/// Centers the ＋ button so it rises 14px above the tab bar, as in the design
/// (bar padding 8 minus a 22px negative margin).
class _RaisedCenter extends FloatingActionButtonLocation {
  const _RaisedCenter();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final size = geometry.floatingActionButtonSize;
    return Offset(
      (geometry.scaffoldSize.width - size.width) / 2,
      geometry.contentBottom - 14,
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      button: true,
      label: context.l10n.newEntry,
      excludeSemantics: true,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: c.btn,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.bg, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F7A4A).withValues(alpha: .6),
              blurRadius: 20,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Icon(LucideIcons.plus, size: 26, color: c.onBtn),
          ),
        ),
      ),
    );
  }
}

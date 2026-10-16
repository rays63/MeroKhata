import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/brand.dart';
import '../../widgets/pf.dart';
import 'profile_screen.dart';

class _Page {
  const _Page(this.title, this.body, this.art);

  final String title;
  final String body;
  final Widget art;
}

List<_Page> _pagesFor(AppLocalizations l) => [
  _Page(l.onboardBooksTitle, l.onboardBooksBody, const _BooksArt()),
  _Page(l.onboardImportTitle, l.onboardImportBody, const _ImportArt()),
  _Page(l.onboardGoalsTitle, l.onboardGoalsBody, const _GoalsArt()),
];

const _pageCount = 3;

/// Three intro cards, built from real UI rather than stock art.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pages = PageController();
  int index = 0;

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  void _toProfile() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const ProfileScreen(onboarding: true)),
  );

  void _next() {
    if (index < _pageCount - 1) {
      pages.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _toProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final pageList = _pagesFor(l);
    final last = index == _pageCount - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  PaisaDrop(size: 22, color: c.pri, semanticLabel: null),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Paisa Flow',
                      style: pfText(17, weight: w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _toProfile,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      l.onboardSkip,
                      style: pfText(15, weight: w800, color: c.sub),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Expanded(
                child: PageView.builder(
                  controller: pages,
                  itemCount: pageList.length,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder: (context, i) => _PageBody(page: pageList[i]),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Semantics(
                    label: l.onboardPageOf(index + 1, _pageCount),
                    liveRegion: true,
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        for (var i = 0; i < _pageCount; i++) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: i == index ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == index ? c.pri : c.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  PfButton(
                    label: last ? l.getStarted : l.next,
                    onPressed: _next,
                    expand: false,
                    height: 56,
                    fontSize: 16,
                    trailingIcon: LucideIcons.arrowRight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final _Page page;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.soft,
              borderRadius: BorderRadius.circular(36),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: page.art,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        // Scrolls instead of overflowing on small screens / large text.
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  page.title,
                  style: pfText(
                    30,
                    weight: w900,
                    letterSpacing: -.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  page.body,
                  style: pfText(16, weight: w600, color: c.sub, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.child,
    this.width = 250,
    this.angle = 0,
    this.padding = 16,
  });

  final Widget child;
  final double width;
  final double angle;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Transform.rotate(
      angle: angle * pi / 180,
      child: Container(
        width: width,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F5032).withValues(alpha: .3),
              blurRadius: 30,
              spreadRadius: -12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _BookLine extends StatelessWidget {
  const _BookLine(this.initial, this.color, this.name, this.amount);

  final String initial;
  final Color color;
  final String name;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      children: [
        BookAvatar(name: initial, color: color, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: pfText(14), overflow: TextOverflow.ellipsis),
              Text(
                amount,
                style: pfText(15, weight: w900, color: c.cashIn),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BooksArt extends StatelessWidget {
  const _BooksArt();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 8,
            child: _MiniCard(
              width: 210,
              angle: -6,
              child: _BookLine(
                'J',
                Color(0xFFE39A2E),
                'Japan Trip',
                '¥ 73,200',
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 88,
            child: _MiniCard(
              width: 220,
              angle: 3,
              child: _BookLine(
                'K',
                Color(0xFF3B7DD8),
                'Kirana Pasal',
                'Rs 37,500',
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 168,
            child: _MiniCard(
              width: 210,
              angle: -2,
              child: _BookLine(
                'P',
                Color(0xFF10A65A),
                'Personal',
                'Rs 1,20,380',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportArt extends StatelessWidget {
  const _ImportArt();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    Widget count(String value, String label, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: pfText(22, weight: w900, color: color),
            ),
            Text(label, style: pfText(11, color: c.sub)),
          ],
        ),
      ),
    );
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          _MiniCard(
            child: Row(
              children: [
                PfIconTile(
                  icon: LucideIcons.fileText,
                  background: c.outSoft,
                  foreground: c.cashOut,
                  size: 44,
                  iconSize: 22,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'bank_statement_oct.pdf',
                        style: pfText(14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l.onboardArtParsed(13),
                        style: pfText(12, weight: w700, color: c.sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              count('6', l.onboardArtReady, c.cashIn),
              const SizedBox(width: 8),
              count('2', l.onboardArtDuplicates, c.gold),
              const SizedBox(width: 8),
              count('5', l.onboardArtSkipped, c.sub),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: c.btn,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.onboardArtImportEntries(6),
                    style: pfText(14, color: c.onBtn),
                  ),
                ),
                Icon(LucideIcons.arrowRight, size: 16, color: c.onBtn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsArt extends StatelessWidget {
  const _GoalsArt();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    Widget person(String initial, Color color, {bool overlap = false}) =>
        Transform.translate(
          offset: Offset(overlap ? -10 : 0, 0),
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: c.card, width: 2),
            ),
            child: Text(
              initial,
              style: pfText(13, weight: w900, color: Colors.white),
            ),
          ),
        );
    return SizedBox(
      width: 250,
      child: Column(
        children: [
          _MiniCard(
            padding: 18,
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: .62,
                          strokeWidth: 9,
                          strokeCap: StrokeCap.butt,
                          color: c.pri,
                          backgroundColor: c.card2,
                        ),
                      ),
                      Text('62%', style: pfText(14, weight: w900)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency fund',
                        style: pfText(14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l.onboardArtGoalProgress('Rs 92,500', '1,50,000'),
                        style: pfText(12, weight: w700, color: c.sub),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _MiniCard(
            child: Row(
              children: [
                person('S', const Color(0xFFE9A23B)),
                person('B', const Color(0xFF8B5CF6), overlap: true),
                const SizedBox(width: 2),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pokhara Trip',
                        style: pfText(14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${l.youreOwed} Rs 4,200',
                        style: pfText(12, color: c.cashIn),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

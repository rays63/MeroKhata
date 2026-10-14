import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../theme/app_theme.dart';
import 'shell.dart';

class PaisaFlowBootstrap extends StatefulWidget {
  const PaisaFlowBootstrap({super.key});

  @override
  State<PaisaFlowBootstrap> createState() => _PaisaFlowBootstrapState();
}

class _PaisaFlowBootstrapState extends State<PaisaFlowBootstrap> {
  /// First launch keeps the splash up briefly so it reads as a welcome, not a
  /// flicker; returning users go straight in once data has loaded.
  static const _firstLaunchSplash = Duration(milliseconds: 1500);

  final store = AppStore();
  bool splashTimeUp = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_firstLaunchSplash, () {
      if (mounted) setState(() => splashTimeUp = true);
    });
    store.load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    store.dispose();
    super.dispose();
  }

  Widget _home() {
    if (!store.isLoaded) return const SplashScreen();
    if (store.onboarded) return const AppShell();
    if (!splashTimeUp) return const SplashScreen();
    return const _OnboardingFlow();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'Paisa Flow',
          debugShowCheckedModeBanner: false,
          themeMode: store.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // Status bar icons follow the theme on screens without an app bar;
          // the green splash overrides this with light icons.
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: child!,
          ),
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: KeyedSubtree(
              key: ValueKey(_home().runtimeType),
              child: _home(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Onboarding runs in its own navigator so finishing setup swaps the whole
/// flow (cards, profile, setup) for the app in one step.
class _OnboardingFlow extends StatefulWidget {
  const _OnboardingFlow();

  @override
  State<_OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<_OnboardingFlow> {
  final navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => navigator.currentState?.maybePop(),
      child: Navigator(
        key: navigator,
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      ),
    );
  }
}

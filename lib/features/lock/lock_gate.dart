import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/brand.dart';
import '../../widgets/pf.dart';
import 'pin_pad.dart';

/// Hides the app's content from the recent-apps preview (Android).
class AppPrivacy {
  static const _channel = MethodChannel('paisaflow/privacy');

  static Future<void> hideInRecents(bool hide) async {
    try {
      await _channel.invokeMethod<void>('hideInRecents', hide);
    } on MissingPluginException {
      // Tests and platforms without the channel.
    } on PlatformException {
      // Not critical; the in-app cover still hides content.
    }
  }
}

/// Puts the lock screen over the app when it starts and when it comes back
/// after the chosen time in the background. The app underneath keeps its
/// place.
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});

  final Widget child;

  /// Locks straight away ("Lock now" in settings).
  static void lockNow(BuildContext context) =>
      context.findAncestorStateOfType<_LockGateState>()?._lock();

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  late final AppStore store = AppScope.read(context);
  late bool locked = store.isLoaded && store.appLockEnabled;

  /// Whether the start-up lock has been decided (the store loads async).
  late bool started = store.isLoaded;
  bool covered = false;
  bool authenticating = false;
  DateTime? leftAt;
  bool? hiddenInRecents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    store.addListener(_syncPrivacy);
    _syncPrivacy();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    store.removeListener(_syncPrivacy);
    super.dispose();
  }

  void _syncPrivacy() {
    if (!started && store.isLoaded) {
      started = true;
      if (store.appLockEnabled) setState(() => locked = true);
    }
    final hide = store.appLockEnabled;
    if (hide != hiddenInRecents) {
      hiddenInRecents = hide;
      AppPrivacy.hideInRecents(hide);
    }
    if (!hide && locked) setState(() => locked = false);
  }

  void _lock() {
    if (store.appLockEnabled) setState(() => locked = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The fingerprint prompt itself pauses the app; don't relock for it.
    if (authenticating || !store.appLockEnabled) return;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        setState(() => covered = true);
      case AppLifecycleState.paused:
        leftAt ??= DateTime.now();
        setState(() => covered = true);
      case AppLifecycleState.resumed:
        final away = leftAt == null
            ? Duration.zero
            : DateTime.now().difference(leftAt!);
        setState(() {
          covered = false;
          if (leftAt != null && away >= store.lockAfter) locked = true;
          leftAt = null;
        });
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<bool> _authenticate(String reason) async {
    authenticating = true;
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    } finally {
      // Let the lifecycle events from the prompt settle first.
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        authenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (locked)
          Positioned.fill(
            child: LockScreen(
              onUnlocked: () => setState(() => locked = false),
              authenticate: _authenticate,
            ),
          )
        else if (covered)
          const Positioned.fill(child: _PrivacyCover()),
      ],
    );
  }
}

/// Shown over the app while it's in the background, so the app switcher
/// shows the logo instead of balances.
class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return ColoredBox(
      color: c.bg,
      child: Center(
        child: PaisaDrop(size: 64, color: c.btn, coin: const Color(0xFFF5B83D)),
      ),
    );
  }
}

/// PIN pad with fingerprint / face unlock.
class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.onUnlocked,
    required this.authenticate,
  });

  final VoidCallback onUnlocked;
  final Future<bool> Function(String reason) authenticate;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String typed = '';
  String? error;
  bool forgot = false;
  bool canUseBiometrics = false;
  Timer? cooldown;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics());
  }

  @override
  void dispose() {
    cooldown?.cancel();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final store = AppScope.read(context);
    if (!store.lockBiometrics) return;
    var ok = false;
    try {
      ok = await LocalAuthentication().canCheckBiometrics;
    } catch (_) {}
    if (!mounted || !ok) return;
    setState(() => canUseBiometrics = true);
    if (_secondsLeft(store) == 0) await _biometric();
  }

  Future<void> _biometric() async {
    final store = AppScope.read(context);
    final ok = await widget.authenticate(context.l10n.lockBiometricReason);
    if (!ok || !mounted) return;
    await store.resetPinAttempts();
    widget.onUnlocked();
  }

  int _secondsLeft(AppStore store) {
    final until = store.pinLockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds + 1;
    return left > 0 ? left : 0;
  }

  void _startCooldownTimer() {
    cooldown?.cancel();
    cooldown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_secondsLeft(AppScope.read(context)) == 0) cooldown?.cancel();
    });
  }

  Future<void> _digit(String digit) async {
    if (typed.length >= pinLength) return;
    setState(() {
      typed += digit;
      error = null;
    });
    if (typed.length < pinLength) return;
    final store = AppScope.read(context);
    final l = context.l10n;
    final result = await store.checkPin(typed);
    if (!mounted) return;
    if (result == PinCheck.ok) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      typed = '';
      error = result == PinCheck.lockedOut
          ? null
          : l.lockWrongPin(AppStore.maxPinAttempts - store.failedPinAttempts);
    });
    if (result == PinCheck.lockedOut) _startCooldownTimer();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final left = _secondsLeft(store);
    return Material(
      color: c.bg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 64),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    PaisaDrop(
                      size: 60,
                      color: PfColors.light.btn,
                      coin: const Color(0xFFF5B83D),
                      semanticLabel: null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.appName,
                      style: pfText(15, weight: w900, color: c.sub),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.lockEnterPin,
                      textAlign: TextAlign.center,
                      style: pfText(24, weight: w900),
                    ),
                    const SizedBox(height: 18),
                    PinDots(filled: typed.length, error: error != null),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: Text(
                        left > 0 ? l.lockTooMany(left) : error ?? '',
                        textAlign: TextAlign.center,
                        style: pfText(14, weight: w900, color: c.cashOut),
                      ),
                    ),
                    const Spacer(),
                    PinKeypad(
                      enabled: left == 0,
                      onDigit: _digit,
                      onDelete: () => setState(() {
                        if (typed.isNotEmpty) {
                          typed = typed.substring(0, typed.length - 1);
                        }
                      }),
                      onBiometric: canUseBiometrics ? _biometric : null,
                    ),
                    TextButton(
                      onPressed: () => setState(() => forgot = !forgot),
                      child: Text(
                        l.lockForgot,
                        style: pfText(14, weight: w800, color: c.sub),
                      ),
                    ),
                    if (forgot)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: c.goldSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.triangleAlert,
                              size: 18,
                              color: c.gold,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.lockNoRecoveryTitle,
                                    style: pfText(14, weight: w900),
                                  ),
                                  Text(
                                    l.lockNoRecoveryBody,
                                    style: pfText(
                                      12.5,
                                      weight: w700,
                                      color: c.sub,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

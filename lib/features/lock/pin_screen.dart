import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'pin_pad.dart';

/// What the PIN screen is for.
enum PinFlow {
  /// Turn the lock on: new PIN, then confirm.
  set,

  /// Current PIN, then a new one twice.
  change,

  /// Current PIN, then the lock is turned off.
  turnOff,
}

enum _Step { current, choose, confirm }

/// Sets, changes or checks the app-lock PIN. Pops true when done.
class PinScreen extends StatefulWidget {
  const PinScreen({super.key, required this.flow});

  final PinFlow flow;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  late _Step step = widget.flow == PinFlow.set ? _Step.choose : _Step.current;
  String typed = '';
  String chosen = '';
  String? error;
  Timer? cooldown;

  @override
  void initState() {
    super.initState();
    _tickCooldown();
  }

  @override
  void dispose() {
    cooldown?.cancel();
    super.dispose();
  }

  int _secondsLeft(AppStore store) {
    final until = store.pinLockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds + 1;
    return left > 0 ? left : 0;
  }

  void _tickCooldown() {
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
    if (typed.length == pinLength) await _complete();
  }

  Future<void> _complete() async {
    final store = AppScope.read(context);
    final l = context.l10n;
    final pin = typed;
    switch (step) {
      case _Step.current:
        final result = await store.checkPin(pin);
        if (!mounted) return;
        if (result != PinCheck.ok) {
          setState(() {
            typed = '';
            error = result == PinCheck.lockedOut
                ? null
                : l.lockWrongPin(
                    AppStore.maxPinAttempts - store.failedPinAttempts,
                  );
          });
          if (result == PinCheck.lockedOut) _tickCooldown();
          return;
        }
        if (widget.flow == PinFlow.turnOff) {
          await store.disableAppLock();
          if (!mounted) return;
          showPfToast(context, l.lockOffToast);
          Navigator.pop(context, true);
          return;
        }
        setState(() {
          step = _Step.choose;
          typed = '';
        });
      case _Step.choose:
        setState(() {
          chosen = pin;
          step = _Step.confirm;
          typed = '';
        });
      case _Step.confirm:
        if (pin != chosen) {
          setState(() {
            step = _Step.choose;
            typed = '';
            chosen = '';
            error = l.lockPinsDiffer;
          });
          return;
        }
        await store.setPin(pin);
        if (!mounted) return;
        showPfToast(
          context,
          widget.flow == PinFlow.change ? l.lockChangedToast : l.lockOnToast,
        );
        Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final left = step == _Step.current ? _secondsLeft(store) : 0;
    final title = switch (step) {
      _Step.current => l.lockCurrentPin,
      _Step.choose =>
        widget.flow == PinFlow.change ? l.lockNewPin : l.lockSetPin,
      _Step.confirm => l.lockConfirmPin,
    };
    final stepNumber = switch (step) {
      _Step.choose => 1,
      _Step.confirm => 2,
      _Step.current => null,
    };
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
          child: Column(
            children: [
              const PfHeader(title: ''),
              const SizedBox(height: 12),
              if (stepNumber != null)
                Text(
                  l.lockStep(stepNumber),
                  style: pfText(
                    12.5,
                    weight: w900,
                    color: c.pri,
                    letterSpacing: .5,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: pfText(24, weight: w900, height: 1.2),
              ),
              if (step == _Step.choose && widget.flow == PinFlow.set) ...[
                const SizedBox(height: 8),
                Text(
                  l.lockNoRecoveryBody,
                  textAlign: TextAlign.center,
                  style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
                ),
              ],
              const SizedBox(height: 20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

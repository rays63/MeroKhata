import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../backup/backup_screen.dart';
import 'lock_gate.dart';
import 'pin_screen.dart';

/// Settings → App lock: turn it on with a PIN, fingerprint or face, when it
/// locks, change the PIN, or turn it off (needs the PIN).
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    var ok = false;
    try {
      ok =
          await LocalAuthentication().canCheckBiometrics &&
          (await LocalAuthentication().getAvailableBiometrics()).isNotEmpty;
    } catch (_) {}
    if (mounted) setState(() => biometricsAvailable = ok);
  }

  Future<void> _pin(PinFlow flow) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => PinScreen(flow: flow)));

  String _afterLabel(AppLocalizations l, Duration after) =>
      switch (after.inSeconds) {
        0 => l.lockImmediately,
        60 => l.lockAfter1,
        _ => l.lockAfter5,
      };

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.lockTitle),
            const SizedBox(height: 16),
            if (!store.appLockEnabled) ..._off(c, l) else ..._on(store, c, l),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _off(PfColors c, AppLocalizations l) => [
    PfCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfIconTile(
            icon: LucideIcons.lockKeyhole,
            background: c.soft,
            foreground: c.cashIn,
            size: 52,
            radius: 18,
            iconSize: 24,
          ),
          const SizedBox(height: 12),
          Text(l.lockIntro, style: pfText(16, weight: w800, height: 1.4)),
          const SizedBox(height: 12),
          for (final (icon, text) in [
            (LucideIcons.grid3x3, l.lockFeaturePin),
            (LucideIcons.fingerprint, l.lockFeatureBiometrics),
            (LucideIcons.eyeOff, l.lockFeatureSwitcher),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: c.sub),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(text, style: pfText(14, weight: w700)),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.triangleAlert, size: 18, color: c.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.lockNoRecoveryTitle, style: pfText(14, weight: w900)),
                const SizedBox(height: 2),
                Text(
                  l.lockNoRecoveryBody,
                  style: pfText(12.5, weight: w700, color: c.sub, height: 1.45),
                ),
                const SizedBox(height: 8),
                PfSmallButton(
                  label: l.lockGoToBackup,
                  height: 36,
                  radius: 12,
                  fontSize: 13,
                  background: c.card,
                  foreground: c.ink,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BackupScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    PfButton(
      label: l.lockSetPin,
      icon: LucideIcons.lock,
      onPressed: () => _pin(PinFlow.set),
    ),
  ];

  List<Widget> _on(AppStore store, PfColors c, AppLocalizations l) => [
    PfCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          PfIconTile(
            icon: LucideIcons.shieldCheck,
            background: c.soft,
            foreground: c.cashIn,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.lockOn, style: pfText(16, weight: w900)),
                Text(
                  l.lockStatus(
                    store.lockBiometrics ? l.lockMethodPinBio : l.lockMethodPin,
                    _afterLabel(l, store.lockAfter),
                  ),
                  style: pfText(12.5, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    if (biometricsAvailable) ...[
      PfCard(
        child: SwitchListTile(
          value: store.lockBiometrics,
          onChanged: store.setLockBiometrics,
          secondary: Icon(LucideIcons.fingerprint, color: c.ink),
          title: Text(l.lockBiometrics, style: pfText(15, weight: w800)),
        ),
      ),
      const SizedBox(height: 14),
    ],
    PfSectionLabel(l.lockAfterLabel),
    const SizedBox(height: 8),
    RadioGroup<Duration>(
      groupValue: store.lockAfter,
      onChanged: (value) {
        if (value != null) store.setLockAfter(value);
      },
      child: PfCard(
        child: Column(
          children: [
            for (final (i, after) in const [
              Duration.zero,
              Duration(minutes: 1),
              Duration(minutes: 5),
            ].indexed) ...[
              if (i > 0) const PfDivider(),
              RadioListTile<Duration>(
                value: after,
                activeColor: c.btn,
                title: Text(
                  _afterLabel(l, after),
                  style: pfText(15, weight: w800),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    const SizedBox(height: 14),
    PfCard(
      child: Column(
        children: [
          PfPickerRow(
            icon: LucideIcons.keyRound,
            label: l.lockChangePin,
            value: '••••',
            chevron: false,
            onTap: () => _pin(PinFlow.change),
          ),
          const PfDivider(),
          PfPickerRow(
            icon: LucideIcons.smartphone,
            label: l.lockNow,
            value: l.appName,
            chevron: false,
            onTap: () => LockGate.lockNow(context),
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    PfButton(
      label: l.lockTurnOff,
      icon: LucideIcons.lockOpen,
      style: PfButtonStyle.outlineDanger,
      height: 50,
      radius: 18,
      fontSize: 15,
      onPressed: () => _pin(PinFlow.turnOff),
    ),
    const SizedBox(height: 10),
    PfNote(icon: LucideIcons.info, text: l.lockOffNeedsPin),
  ];
}

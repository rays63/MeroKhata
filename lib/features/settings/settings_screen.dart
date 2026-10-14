import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';
import '../onboarding/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportAll(BuildContext context, AppStore store) async {
    final l = context.l10n;
    await store.persist();
    final raw =
        (await SharedPreferences.getInstance()).getString(
          'hissabkitab_data_v1',
        ) ??
        '{}';
    final name =
        'paisaflow_backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
    try {
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: l.settingsExportAll,
        fileName: name,
        bytes: Uint8List.fromList(utf8.encode(raw)),
      );
      if (saved != null && context.mounted) {
        showPfToast(context, l.readyToShare(name));
      }
    } catch (error) {
      if (context.mounted) showPfToast(context, l.exportFailed('$error'));
    }
  }

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
            PfHeader(title: l.settings),
            const SizedBox(height: 16),
            PfSectionLabel(l.settingsAppearance),
            const SizedBox(height: 8),
            PfSegment<ThemeMode>(
              value: store.themeMode,
              onChanged: store.setThemeMode,
              height: 44,
              radius: 18,
              fontSize: 14,
              items: [
                (
                  ThemeMode.system,
                  l.settingsThemeSystem,
                  LucideIcons.smartphone,
                ),
                (ThemeMode.light, l.settingsThemeLight, LucideIcons.sun),
                (ThemeMode.dark, l.settingsThemeDark, LucideIcons.moon),
              ],
            ),
            const SizedBox(height: 16),
            PfSectionLabel(l.settingsLanguage),
            const SizedBox(height: 8),
            PfSegment<String>(
              value: store.language,
              height: 44,
              radius: 18,
              fontSize: 15,
              onChanged: store.setLanguage,
              items: const [('en', 'English', null), ('ne', 'नेपाली', null)],
            ),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: LucideIcons.userRound,
                    label: l.profileTitle,
                    value: store.profile.name.trim().isEmpty
                        ? l.add
                        : store.profile.name.trim(),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.tags,
                    label: l.settingsCategories,
                    value: l.settingsItemCount(store.categories.length),
                    onTap: () => pickCategory(context, manageOnly: true),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.wallet,
                    label: l.settingsPaymentModes,
                    value: l.settingsItemCount(store.paymentModes.length),
                    onTap: () => pickPaymentMode(context, manageOnly: true),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.coins,
                    label: l.settingsDefaultCurrency,
                    value: store.defaultCurrency,
                    chevron: false,
                    onTap: () async {
                      final picked = await pickCurrency(
                        context,
                        selected: store.defaultCurrency,
                        title: l.settingsDefaultCurrencyTitle,
                      );
                      if (picked != null) {
                        await store.setDefaultCurrency(picked);
                      }
                    },
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.hardDriveDownload,
                    label: l.settingsExportAll,
                    onTap: () => _exportAll(context, store),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.scanFace,
                    label: l.settingsAppLock,
                    badge: l.settingsSoon,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfNote(
              icon: LucideIcons.shieldCheck,
              green: true,
              title: l.settingsStoredTitle,
              text: l.settingsStoredBody,
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${l.appName} 1.0.0',
                style: pfText(12, color: c.mute),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.value,
    this.badge,
    this.onTap,
    this.chevron = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? badge;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 19, color: c.sub),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: pfText(15))),
            if (value != null)
              Text(
                value!,
                style: pfText(13, weight: w700, color: c.sub),
              ),
            if (badge != null) PfBadge(label: badge!, fontSize: 11),
            if (onTap != null && chevron) ...[
              const SizedBox(width: 8),
              Icon(LucideIcons.chevronRight, size: 16, color: c.mute),
            ],
          ],
        ),
      ),
    );
  }
}

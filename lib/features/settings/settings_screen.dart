import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_store.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportAll(BuildContext context, AppStore store) async {
    await store.persist();
    final raw = (await SharedPreferences.getInstance()).getString(
          'hissabkitab_data_v1',
        ) ??
        '{}';
    final name =
        'paisaflow_backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
    try {
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: 'Export all data',
        fileName: name,
        bytes: Uint8List.fromList(utf8.encode(raw)),
      );
      if (saved != null && context.mounted) {
        showPfToast(context, '$name ready to share');
      }
    } catch (error) {
      if (context.mounted) showPfToast(context, 'Export failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            const PfHeader(title: 'Settings'),
            const SizedBox(height: 16),
            const PfSectionLabel('Appearance'),
            const SizedBox(height: 8),
            PfSegment<ThemeMode>(
              value: store.themeMode,
              onChanged: store.setThemeMode,
              height: 44,
              radius: 18,
              fontSize: 14,
              items: const [
                (ThemeMode.system, 'System', LucideIcons.smartphone),
                (ThemeMode.light, 'Light', LucideIcons.sun),
                (ThemeMode.dark, 'Dark', LucideIcons.moon),
              ],
            ),
            const SizedBox(height: 16),
            const PfSectionLabel('Language'),
            const SizedBox(height: 8),
            PfSegment<String>(
              value: 'en',
              height: 44,
              radius: 18,
              fontSize: 15,
              onChanged: (value) {
                if (value == 'ne') {
                  showPfToast(context, 'नेपाली is coming in the next update');
                }
              },
              items: const [('en', 'English', null), ('ne', 'नेपाली', null)],
            ),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: LucideIcons.tags,
                    label: 'Categories',
                    value: '${store.categories.length} items',
                    onTap: () => pickCategory(context, manageOnly: true),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.wallet,
                    label: 'Payment modes',
                    value: '${store.paymentModes.length} items',
                    onTap: () => pickPaymentMode(context, manageOnly: true),
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.coins,
                    label: 'Default currency for new books',
                    value: store.defaultCurrency,
                    chevron: false,
                    onTap: () async {
                      final picked = await pickCurrency(
                        context,
                        selected: store.defaultCurrency,
                        title: 'Default currency',
                      );
                      if (picked != null) await store.setDefaultCurrency(picked);
                    },
                  ),
                  const PfDivider(),
                  _SettingsRow(
                    icon: LucideIcons.hardDriveDownload,
                    label: 'Export all data',
                    onTap: () => _exportAll(context, store),
                  ),
                  const PfDivider(),
                  const _SettingsRow(
                    icon: LucideIcons.scanFace,
                    label: 'App lock',
                    badge: 'SOON',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const PfNote(
              icon: LucideIcons.shieldCheck,
              green: true,
              title: 'Stored only on this phone',
              text: 'No account, no cloud. Export regularly to keep a backup.',
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Paisa Flow 1.0.0',
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
              Text(value!, style: pfText(13, weight: w700, color: c.sub)),
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

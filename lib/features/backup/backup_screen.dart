import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'backup_create_screen.dart';
import 'restore_screen.dart';

/// Settings → Backup & restore: when the last backup was made, make a new
/// one, or restore from a file.
class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  /// Lets the user pick a file and starts the restore flow with it.
  static Future<void> pickAndRestore(BuildContext context) async {
    // Android can't filter by ".pfbak", so every file is offered and the
    // restore screen checks what was picked.
    final result = await FilePicker.platform.pickFiles(withData: true);
    final file = result?.files.singleOrNull;
    if (file?.bytes == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestoreScreen(bytes: file!.bytes!, fileName: file.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final last = store.lastBackupAt;
    final days = last == null
        ? null
        : DateUtils.dateOnly(
            DateTime.now(),
          ).difference(DateUtils.dateOnly(last)).inDays;
    final old = last == null || days! >= 30;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.backupTitle),
            const SizedBox(height: 16),
            PfCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  PfIconTile(
                    icon: old
                        ? LucideIcons.triangleAlert
                        : LucideIcons.shieldCheck,
                    background: old ? c.goldSoft : c.soft,
                    foreground: old ? c.gold : c.cashIn,
                    size: 48,
                    radius: 16,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.backupLast,
                          style: pfText(12.5, weight: w800, color: c.sub),
                        ),
                        Text(
                          last == null ? l.backupNever : l.backupDaysAgo(days!),
                          style: pfText(18, weight: w900),
                        ),
                        if (last != null)
                          Text(
                            DateFormat('d MMM y · h:mm a').format(last),
                            style: pfText(12.5, weight: w700, color: c.sub),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (old) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: c.goldSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.hardDrive, size: 18, color: c.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.backupNudgeBody,
                        style: pfText(13, weight: w700, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            PfButton(
              label: l.backupCreate,
              icon: LucideIcons.hardDriveDownload,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupCreateScreen()),
              ),
            ),
            const SizedBox(height: 10),
            PfButton(
              label: l.backupRestore,
              icon: LucideIcons.rotateCcw,
              style: PfButtonStyle.neutral,
              onPressed: () => pickAndRestore(context),
            ),
            const SizedBox(height: 16),
            PfCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.backupOnPhone,
                    style: pfText(12.5, weight: w800, color: c.sub),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      l.bookCount(store.books.length),
                      l.entryCount(store.transactions.length),
                      l.tagCount(store.allTags.length),
                    ].join(' · '),
                    style: pfText(15, weight: w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.backupIncludes,
                    style: pfText(13, weight: w600, color: c.sub, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PfNote(icon: LucideIcons.lock, text: l.backupEncrypted),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

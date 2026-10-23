import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/app_info.dart';
import '../../data/app_store.dart';
import '../../data/backup.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';

/// Makes a backup file, optionally protected with a password, and lets the
/// user save it where they like (Drive, Downloads…).
class BackupCreateScreen extends StatefulWidget {
  const BackupCreateScreen({super.key});

  @override
  State<BackupCreateScreen> createState() => _BackupCreateScreenState();
}

class _BackupCreateScreenState extends State<BackupCreateScreen> {
  final password = TextEditingController();
  final again = TextEditingController();
  bool protect = true;
  bool show = false;
  bool busy = false;
  String? error;

  late final fileName =
      'Paisa Flow ${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pfbak';

  @override
  void dispose() {
    password.dispose();
    again.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l = context.l10n;
    if (protect) {
      if (password.text.length < 6) {
        setState(() => error = l.backupPasswordTooShort);
        return;
      }
      if (password.text != again.text) {
        setState(() => error = l.backupPasswordsDiffer);
        return;
      }
    }
    setState(() {
      busy = true;
      error = null;
    });
    final store = AppScope.read(context);
    try {
      final bytes = await BackupCodec.encode(
        store.snapshot(),
        password: protect ? password.text : null,
        appVersion: appVersion,
      );
      final saved = await FilePicker.platform.saveFile(
        dialogTitle: l.backupCreate,
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted) return;
      if (saved == null) {
        setState(() => busy = false);
        return;
      }
      await store.recordBackup();
      if (!mounted) return;
      showPfToast(context, l.backupSaved(fileName));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        busy = false;
        error = l.backupSaveFailed('$e');
      });
    }
  }

  ({String label, Color color, double value}) _strength(PfColors c) {
    final l = context.l10n;
    final text = password.text;
    var score = 0;
    if (text.length >= 8) score++;
    if (text.length >= 12) score++;
    if (RegExp(r'\d').hasMatch(text) && RegExp(r'[A-Za-z]').hasMatch(text)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(text)) score++;
    return switch (score) {
      <= 1 => (label: l.backupStrengthWeak, color: c.cashOut, value: .33),
      2 => (label: l.backupStrengthOkay, color: c.gold, value: .66),
      _ => (label: l.backupStrengthStrong, color: c.cashIn, value: 1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final strength = _strength(c);
    final matches = password.text.isNotEmpty && password.text == again.text;

    Widget field(TextEditingController controller, String label) => PfField(
      label: label,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !show,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (_) => setState(() => error = null),
              style: pfText(16, weight: w800, color: c.ink),
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: pfText(16, weight: w800, color: c.mute),
              ),
            ),
          ),
          IconButton(
            tooltip: show ? l.backupHidePassword : l.backupShowPassword,
            onPressed: () => setState(() => show = !show),
            icon: Icon(
              show ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: c.sub,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.backupCreate),
            const SizedBox(height: 16),
            PfCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PfIconTile(
                    icon: LucideIcons.fileLock,
                    background: c.soft,
                    foreground: c.cashIn,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fileName, style: pfText(15, weight: w900)),
                        Text(
                          [
                            l.bookCount(store.books.length),
                            l.entryCount(store.transactions.length),
                            l.tagCount(store.allTags.length),
                          ].join(' · '),
                          style: pfText(12.5, weight: w700, color: c.sub),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    value: protect,
                    onChanged: (value) => setState(() {
                      protect = value;
                      error = null;
                    }),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    secondary: Icon(LucideIcons.keyRound, color: c.ink),
                    title: Text(
                      l.backupProtect,
                      style: pfText(15, weight: w900),
                    ),
                    subtitle: Text(
                      l.backupProtectBody,
                      style: pfText(12.5, weight: w700, color: c.sub),
                    ),
                  ),
                  if (protect) ...[
                    const PfDivider(),
                    field(password, l.backupPassword),
                    if (password.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: strength.value,
                                  minHeight: 5,
                                  color: strength.color,
                                  backgroundColor: c.card2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              strength.label,
                              style: pfText(
                                12,
                                weight: w800,
                                color: strength.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const PfDivider(),
                    field(again, l.backupPasswordAgain),
                    if (matches)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.circleCheck,
                              size: 15,
                              color: c.cashIn,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l.backupPasswordsMatch,
                              style: pfText(
                                12.5,
                                weight: w800,
                                color: c.cashIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (protect)
              _Warning(
                icon: LucideIcons.triangleAlert,
                color: c.gold,
                background: c.goldSoft,
                text: l.backupPasswordLost,
              )
            else
              _Warning(
                icon: LucideIcons.shieldAlert,
                color: c.cashOut,
                background: c.outSoft,
                title: l.backupNoPasswordTitle,
                text: l.backupNoPasswordBody,
              ),
            if (error != null) ...[
              const SizedBox(height: 14),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 14),
            PfButton(
              label: protect ? l.backupCreateProtected : l.backupCreate,
              icon: LucideIcons.hardDriveDownload,
              onPressed: busy ? null : _create,
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

class _Warning extends StatelessWidget {
  const _Warning({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
    this.title,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: pfText(13.5, weight: w900, color: color),
                  ),
                Text(
                  text,
                  style: pfText(13, weight: w700, color: c.ink, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

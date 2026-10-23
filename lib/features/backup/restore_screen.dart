import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/backup.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'backup_screen.dart';

enum _Stage { reading, password, preview, confirm, progress, done, error }

/// Restores a backup: unlock it if protected, preview what's inside, choose
/// Merge or Replace, then restore. Nothing changes until the last step, and
/// every error says so.
class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key, required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  final password = TextEditingController();
  _Stage stage = _Stage.reading;
  BackupInfo? info;
  AppStore? backup;
  BackupException? problem;
  bool wrongPassword = false;
  bool unlocking = false;
  bool replace = false;
  bool agreed = false;
  int step = 0;
  int added = 0;

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  Future<void> _read() async {
    try {
      info = BackupCodec.readInfo(widget.bytes);
    } on BackupException catch (e) {
      _fail(e);
      return;
    }
    if (info!.protected) {
      setState(() => stage = _Stage.password);
    } else {
      await _open();
    }
  }

  Future<void> _open({String? withPassword}) async {
    try {
      final data = await BackupCodec.decode(
        widget.bytes,
        password: withPassword,
      );
      final read = AppStore.readBackupData(data);
      if (!mounted) return;
      setState(() {
        backup = read;
        stage = _Stage.preview;
      });
    } on BackupException catch (e) {
      if (e.problem == BackupProblem.wrongPassword) {
        setState(() {
          wrongPassword = true;
          unlocking = false;
        });
      } else {
        _fail(e);
      }
    } catch (_) {
      _fail(const BackupException(BackupProblem.damaged));
    }
  }

  void _fail(BackupException e) {
    if (!mounted) return;
    setState(() {
      problem = e;
      stage = _Stage.error;
    });
  }

  Future<void> _unlock() async {
    if (password.text.isEmpty || unlocking) return;
    setState(() {
      unlocking = true;
      wrongPassword = false;
    });
    await _open(withPassword: password.text);
  }

  Future<void> _restore() async {
    final store = AppScope.read(context);
    setState(() {
      stage = _Stage.progress;
      step = 1;
    });
    // Short pauses so each step is readable; the work itself is quick.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => step = 2);
    if (replace) {
      await store.restoreReplace(backup!);
    } else {
      added = await store.restoreMerge(backup!);
    }
    if (!mounted) return;
    setState(() => step = 3);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => stage = _Stage.done);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return PopScope(
      // A running restore can't be left halfway.
      canPop: stage != _Stage.progress,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: pagePadding,
            children: [
              PfHeader(title: l.backupRestore),
              const SizedBox(height: 16),
              ...switch (stage) {
                _Stage.reading => [_Reading(text: l.restoreReading)],
                _Stage.password => _passwordStage(),
                _Stage.preview => _previewStage(),
                _Stage.confirm => _confirmStage(),
                _Stage.progress => _progressStage(),
                _Stage.done => _doneStage(),
                _Stage.error => _errorStage(),
              },
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String get _fileMeta {
    final kb = (widget.bytes.length / 1024).ceil();
    final created = info == null
        ? null
        : DateFormat('d MMM y').format(info!.createdAt);
    return [?created, '$kb KB'].join(' · ');
  }

  Widget _fileCard(IconData icon) {
    final c = context.pf;
    return PfCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          PfIconTile(icon: icon, background: c.card2, foreground: c.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(15, weight: w900),
                ),
                Text(
                  _fileMeta,
                  style: pfText(12.5, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _unchanged() {
    final c = context.pf;
    return Row(
      children: [
        Icon(LucideIcons.shieldCheck, size: 16, color: c.cashIn),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.restoreUnchanged,
            style: pfText(13, weight: w800, color: c.cashIn),
          ),
        ),
      ],
    );
  }

  List<Widget> _passwordStage() {
    final c = context.pf;
    final l = context.l10n;
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: PfIconTile(
          icon: LucideIcons.fileLock,
          background: c.goldSoft,
          foreground: c.gold,
          size: 56,
          radius: 18,
          iconSize: 26,
        ),
      ),
      const SizedBox(height: 12),
      Text(l.restoreLockedTitle, style: pfText(20, weight: w900)),
      const SizedBox(height: 4),
      Text(
        l.restoreLockedBody,
        style: pfText(14, weight: w600, color: c.sub, height: 1.45),
      ),
      const SizedBox(height: 14),
      _fileCard(LucideIcons.fileLock),
      const SizedBox(height: 14),
      PfCard(
        child: PfField(
          label: l.backupPassword,
          child: TextField(
            controller: password,
            obscureText: true,
            autofocus: true,
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (_) => _unlock(),
            onChanged: (_) {
              if (wrongPassword) setState(() => wrongPassword = false);
            },
            style: pfText(16, weight: w800, color: c.ink),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: pfText(16, weight: w800, color: c.mute),
            ),
          ),
        ),
      ),
      if (wrongPassword) ...[
        const SizedBox(height: 12),
        PfErrorBanner(l.restoreWrongPassword),
      ],
      const SizedBox(height: 14),
      PfButton(
        label: l.restoreUnlock,
        icon: LucideIcons.lockOpen,
        onPressed: unlocking ? null : _unlock,
      ),
      if (unlocking) ...[
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
      ],
      const SizedBox(height: 12),
      PfNote(icon: LucideIcons.info, text: l.restoreForgotPassword),
      const SizedBox(height: 12),
      _unchanged(),
    ];
  }

  List<Widget> _previewStage() {
    final c = context.pf;
    final l = context.l10n;
    final b = backup!;
    final dates = b.transactions.map((e) => e.occurredAt).toList()..sort();
    final range = dates.isEmpty
        ? '—'
        : '${DateFormat('d MMM y').format(dates.first)} – ${DateFormat('d MMM y').format(dates.last)}';
    final store = AppScope.read(context);
    final merge = store.mergePreview(b);
    final facts = [
      (l.restoreAccountsLabel, '${b.books.length}'),
      (l.restoreEntriesLabel, '${b.transactions.length}'),
      (l.tags, '${b.allTags.length}'),
      (l.restoreRange, range),
      (
        l.restoreCreated,
        DateFormat('d MMM y · h:mm a').format(info!.createdAt),
      ),
      (l.restoreVersion, info!.appVersion),
    ];
    return [
      _fileCard(LucideIcons.fileArchive),
      const SizedBox(height: 16),
      PfSectionLabel(l.restoreFileHas),
      const SizedBox(height: 8),
      PfCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < facts.length; i++) ...[
              if (i > 0) const PfDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      facts[i].$1,
                      style: pfText(14, weight: w700, color: c.sub),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        facts[i].$2,
                        textAlign: TextAlign.end,
                        style: pfText(14, weight: w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      PfSectionLabel(l.restoreHow),
      const SizedBox(height: 8),
      _Choice(
        selected: !replace,
        title: l.restoreMerge,
        badge: l.restoreRecommended,
        body: l.restoreMergeBody,
        stat: l.restoreMergeStat(
          l.entryCount(merge.entries),
          '${merge.alreadyHere}',
        ),
        onTap: () => setState(() => replace = false),
      ),
      const SizedBox(height: 10),
      _Choice(
        selected: replace,
        danger: true,
        title: l.restoreReplace,
        body: l.restoreReplaceBody,
        stat: l.restoreReplaceStat(store.transactions.length),
        onTap: () => setState(() => replace = true),
      ),
      const SizedBox(height: 16),
      PfButton(
        label: l.restoreContinue,
        icon: LucideIcons.arrowRight,
        onPressed: () => replace
            ? setState(() {
                stage = _Stage.confirm;
                agreed = false;
              })
            : _restore(),
      ),
      const SizedBox(height: 12),
      _unchanged(),
    ];
  }

  List<Widget> _confirmStage() {
    final c = context.pf;
    final l = context.l10n;
    final store = AppScope.read(context);
    return [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: c.outSoft,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.triangleAlert, size: 26, color: c.cashOut),
            const SizedBox(height: 10),
            Text(
              l.restoreReplaceWarnTitle,
              style: pfText(19, weight: w900, color: c.cashOut),
            ),
            const SizedBox(height: 4),
            Text(
              l.restoreReplaceWarnBody,
              style: pfText(14, weight: w700, height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              l.restoreReplaceStat(store.transactions.length),
              style: pfText(13.5, weight: w900, color: c.cashOut),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      PfNote(icon: LucideIcons.lightbulb, text: l.restoreNotSure),
      const SizedBox(height: 12),
      PfCard(
        child: CheckboxListTile(
          value: agreed,
          onChanged: (value) => setState(() => agreed = value ?? false),
          activeColor: c.cashOut,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l.restoreUnderstand, style: pfText(14.5, weight: w800)),
        ),
      ),
      const SizedBox(height: 14),
      PfButton(
        label: l.restoreReplace,
        icon: LucideIcons.trash2,
        style: PfButtonStyle.danger,
        onPressed: agreed ? _restore : null,
      ),
      const SizedBox(height: 10),
      PfButton(
        label: l.back,
        style: PfButtonStyle.neutral,
        onPressed: () => setState(() => stage = _Stage.preview),
      ),
    ];
  }

  List<Widget> _progressStage() {
    final c = context.pf;
    final l = context.l10n;
    final steps = [
      l.restoreStepCheck,
      l.restoreStepData,
      l.restoreStepBalances,
    ];
    return [
      Text(l.restoreRunning, style: pfText(20, weight: w900)),
      const SizedBox(height: 14),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: step / steps.length,
          minHeight: 8,
          color: c.pri,
          backgroundColor: c.card2,
        ),
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(
                i < step ? LucideIcons.circleCheck : LucideIcons.circle,
                size: 18,
                color: i < step ? c.cashIn : c.mute,
              ),
              const SizedBox(width: 10),
              Text(steps[i], style: pfText(14.5, weight: w800)),
            ],
          ),
        ),
      const SizedBox(height: 8),
      Text(
        l.restoreKeepOpen,
        style: pfText(13, weight: w700, color: c.sub),
      ),
    ];
  }

  List<Widget> _doneStage() {
    final c = context.pf;
    final l = context.l10n;
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Icon(LucideIcons.circleCheckBig, size: 56, color: c.cashIn),
      ),
      const SizedBox(height: 12),
      Text(l.restoreDone, style: pfText(22, weight: w900)),
      const SizedBox(height: 6),
      Text(
        replace
            ? l.restoreDoneReplace(
                DateFormat('d MMM y').format(info!.createdAt),
              )
            : l.restoreDoneMerge(added),
        style: pfText(14.5, weight: w600, color: c.sub, height: 1.45),
      ),
      const SizedBox(height: 20),
      PfButton(
        label: l.restoreGoHome,
        icon: LucideIcons.house,
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    ];
  }

  List<Widget> _errorStage() {
    final c = context.pf;
    final l = context.l10n;
    final p = problem!;
    final (icon, title, body) = switch (p.problem) {
      BackupProblem.notBackup => (
        LucideIcons.fileX,
        l.restoreErrWrongTitle,
        l.restoreErrWrongBody,
      ),
      BackupProblem.newerVersion => (
        LucideIcons.circleArrowUp,
        l.restoreErrNewTitle,
        l.restoreErrNewBody(p.appVersion ?? ''),
      ),
      _ => (LucideIcons.fileWarning, l.restoreErrBadTitle, l.restoreErrBadBody),
    };
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: PfIconTile(
          icon: icon,
          background: c.outSoft,
          foreground: c.cashOut,
          size: 56,
          radius: 18,
          iconSize: 26,
        ),
      ),
      const SizedBox(height: 12),
      Text(title, style: pfText(20, weight: w900)),
      const SizedBox(height: 6),
      Text(
        body,
        style: pfText(14, weight: w600, color: c.sub, height: 1.45),
      ),
      const SizedBox(height: 14),
      _fileCard(LucideIcons.file),
      const SizedBox(height: 12),
      _unchanged(),
      const SizedBox(height: 16),
      PfButton(
        label: l.restoreTryOther,
        icon: LucideIcons.folderOpen,
        onPressed: () async {
          // This screen closes first, so pick from the navigator's context.
          final navigator = Navigator.of(context)..pop();
          await BackupScreen.pickAndRestore(navigator.context);
        },
      ),
    ];
  }
}

class _Reading extends StatelessWidget {
  const _Reading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(
            text,
            style: pfText(14, weight: w800, color: c.sub),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.title,
    required this.body,
    required this.stat,
    required this.onTap,
    this.badge,
    this.danger = false,
  });

  final bool selected;
  final String title;
  final String body;
  final String stat;
  final String? badge;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final accent = danger ? c.cashOut : c.btn;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? accent : c.line,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected ? LucideIcons.circleDot : LucideIcons.circle,
                  size: 20,
                  color: selected ? accent : c.mute,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: pfText(15.5, weight: w900)),
                          if (badge != null)
                            PfBadge(
                              label: badge!,
                              background: c.soft,
                              foreground: c.cashIn,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: pfText(
                          13,
                          weight: w600,
                          color: c.sub,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat,
                        style: pfText(
                          12.5,
                          weight: w900,
                          color: danger ? c.cashOut : c.cashIn,
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
    );
  }
}

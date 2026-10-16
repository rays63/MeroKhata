import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'setup_screen.dart';

final _phonePattern = RegExp(r'^9\d{9}$');
final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// "Tell us about you": name, mobile and optional email. Step 1 of 2 during
/// onboarding; also opened from Settings to edit the details later.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserProfile saved = AppScope.read(context).profile;
  late final name = TextEditingController(text: saved.name);
  late final phone = TextEditingController(text: saved.phone);
  late final email = TextEditingController(text: saved.email);
  String? error;
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    super.dispose();
  }

  String? _validate() {
    final l = context.l10n;
    if (name.text.trim().isEmpty) return l.profileNameRequired;
    if (!_phonePattern.hasMatch(phone.text)) {
      return l.profilePhoneRule;
    }
    final mail = email.text.trim();
    if (mail.isNotEmpty && !_emailPattern.hasMatch(mail)) {
      return l.profileEmailInvalid;
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    if (saving) return;
    saving = true;
    final navigator = Navigator.of(context);
    await AppScope.read(context).saveProfile(
      UserProfile(
        name: name.text.trim(),
        phone: phone.text,
        email: email.text.trim(),
      ),
    );
    if (!mounted) return;
    if (widget.onboarding) {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const SetupScreen()),
      );
      saving = false;
    } else {
      showPfToast(context, context.l10n.profileSaved);
      navigator.pop();
    }
  }

  void _changed(String _) => setState(() => error = null);

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final phoneOk = _phonePattern.hasMatch(phone.text);
    final emailOk = _emailPattern.hasMatch(email.text.trim());
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: max(0, constraints.maxHeight - 36),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.onboarding)
                      const StepHeader(step: 1)
                    else
                      PfHeader(title: l.profileTitle),
                    const SizedBox(height: 22),
                    if (widget.onboarding) ...[
                      StepTitle(
                        step: 1,
                        title: l.profileStepTitle,
                        body: l.profileStepBody,
                      ),
                      const SizedBox(height: 22),
                    ],
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: PfColors.avatar,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            initials(name.text),
                            style: pfText(
                              22,
                              weight: w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l.profileAvatarHint,
                            style: pfText(
                              13,
                              weight: w700,
                              color: c.sub,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PfCard(
                      child: Column(
                        children: [
                          _ProfileField(
                            icon: LucideIcons.userRound,
                            label: l.profileFullName,
                            child: TextField(
                              controller: name,
                              autofocus:
                                  widget.onboarding && saved.name.isEmpty,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              onChanged: _changed,
                              style: pfText(17, color: c.ink),
                              decoration: InputDecoration(
                                hintText: l.profileNameHint,
                                hintStyle: pfText(17, color: c.mute),
                              ),
                            ),
                          ),
                          const PfDivider(),
                          _ProfileField(
                            icon: LucideIcons.phone,
                            label: l.profileMobile,
                            ok: phoneOk,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text('+977', style: pfText(17, color: c.sub)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: phone,
                                    keyboardType: TextInputType.phone,
                                    autofillHints: const [
                                      AutofillHints.telephoneNumberNational,
                                    ],
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    onChanged: _changed,
                                    style: pfText(
                                      17,
                                      color: c.ink,
                                      letterSpacing: .5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '98XXXXXXXX',
                                      hintStyle: pfText(17, color: c.mute),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PfDivider(),
                          _ProfileField(
                            icon: LucideIcons.mail,
                            label: l.profileEmail,
                            optional: true,
                            ok: emailOk,
                            child: TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              onChanged: _changed,
                              style: pfText(17, color: c.ink),
                              decoration: InputDecoration(
                                hintText: 'you@example.com',
                                hintStyle: pfText(17, color: c.mute),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 22),
                      PfErrorBanner(error!),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.lock, size: 16, color: c.cashIn),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.profilePrivacy,
                            style: pfText(
                              13,
                              weight: w700,
                              color: c.sub,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(height: 22),
                    PfButton(
                      label: widget.onboarding ? l.continueLabel : l.save,
                      trailingIcon: widget.onboarding
                          ? LucideIcons.arrowRight
                          : null,
                      spread: widget.onboarding,
                      onPressed: _save,
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

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.icon,
    required this.label,
    required this.child,
    this.optional = false,
    this.ok = false,
  });

  final IconData icon;
  final String label;
  final Widget child;
  final bool optional;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 19, color: c.sub),
          const SizedBox(width: 14),
          Expanded(
            child: PfField(
              label: label,
              optional: optional,
              padding: EdgeInsets.zero,
              child: child,
            ),
          ),
          if (ok) ...[
            const SizedBox(width: 10),
            Semantics(
              label: context.l10n.profileValid,
              child: Icon(LucideIcons.circleCheck, size: 19, color: c.pri),
            ),
          ],
        ],
      ),
    );
  }
}

/// Back button + two-segment progress bar used by the setup steps.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      children: [
        PfIconButton(
          icon: LucideIcons.arrowLeft,
          tooltip: context.l10n.back,
          onPressed: () => Navigator.maybePop(context),
        ),
        const SizedBox(width: 12),
        for (var i = 1; i <= 2; i++) ...[
          if (i > 1) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i <= step ? c.pri : c.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "STEP n OF 2" eyebrow, big title and supporting copy.
class StepTitle extends StatelessWidget {
  const StepTitle({
    super.key,
    required this.step,
    required this.title,
    required this.body,
  });

  final int step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.setupStepOf(step, 2),
          style: pfText(13, color: c.pri, letterSpacing: .4),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: pfText(30, weight: w900, letterSpacing: -.6, height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: pfText(15, weight: w600, color: c.sub, height: 1.5),
        ),
      ],
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';
import 'profile_screen.dart';

/// Step 2 of 2: language and the first book (name, currency, opening
/// balance). Finishing it ends onboarding.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final name = TextEditingController(text: 'Personal');
  final opening = TextEditingController();
  String currency = 'NPR';
  bool saving = false;

  @override
  void dispose() {
    name.dispose();
    opening.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (saving) return;
    setState(() => saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final welcome = context.l10n.setupWelcome;
    try {
      await AppScope.read(context).finishSetup(
        name: name.text,
        currency: currency,
        openingBalance:
            double.tryParse(opening.text.replaceAll(',', '').trim()) ?? 0,
      );
    } catch (error) {
      if (mounted) {
        setState(() => saving = false);
        showPfToast(context, context.l10n.setupSaveFailed('$error'));
      }
      return;
    }
    // The app swaps onboarding for the main shell, unmounting this screen;
    // the app-level messenger carries the welcome across.
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(pfToast(welcome));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final store = AppScope.watch(context);
    final info = Currency.of(currency);
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
                    const StepHeader(step: 2),
                    const SizedBox(height: 22),
                    StepTitle(step: 2, title: l.setupTitle, body: l.setupBody),
                    const SizedBox(height: 22),
                    Text(l.setupLanguage, style: pfText(13, color: c.sub)),
                    const SizedBox(height: 8),
                    PfSegment<String>(
                      value: store.language,
                      height: 44,
                      radius: 18,
                      fontSize: 15,
                      onChanged: store.setLanguage,
                      items: const [
                        ('en', 'English', null),
                        ('ne', 'नेपाली', null),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PfField(
                            label: l.setupBookName,
                            child: TextField(
                              controller: name,
                              textCapitalization: TextCapitalization.words,
                              style: pfText(17, color: c.ink),
                              decoration: InputDecoration(
                                hintText: l.setupBookNameHint,
                                hintStyle: pfText(17, color: c.mute),
                              ),
                            ),
                          ),
                          const PfDivider(),
                          InkWell(
                            onTap: () async {
                              final picked = await pickCurrency(
                                context,
                                selected: currency,
                              );
                              if (picked != null) {
                                setState(() => currency = picked);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l.setupCurrency,
                                          style: pfText(12, color: c.sub),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(info.label, style: pfText(17)),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    LucideIcons.chevronDown,
                                    size: 20,
                                    color: c.sub,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const PfDivider(),
                          PfField(
                            label: l.setupOpeningBalance,
                            optional: true,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  info.symbol,
                                  style: pfText(17, color: c.sub),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: opening,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      const AmountInputFormatter(),
                                    ],
                                    style: pfText(17, color: c.ink),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: pfText(17, color: c.mute),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 22),
                    PfButton(
                      label: l.getStarted,
                      trailingIcon: LucideIcons.arrowRight,
                      spread: true,
                      onPressed: saving ? null : _finish,
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

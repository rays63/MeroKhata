import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';

/// Shared building blocks for the Paisa Flow design. Measurements come from
/// the design file (px == logical pixels).

TextStyle pfText(
  double size, {
  FontWeight weight = FontWeight.w800,
  Color? color,
  double? letterSpacing,
  double? height,
}) => TextStyle(
  fontSize: size,
  fontWeight: weight,
  color: color,
  letterSpacing: letterSpacing,
  height: height,
);

const w600 = FontWeight.w600;
const w700 = FontWeight.w700;
const w800 = FontWeight.w800;
const w900 = FontWeight.w900;

/// Standard page padding used by every screen.
const pagePadding = EdgeInsets.fromLTRB(20, 6, 20, 0);

/// Space reserved under scrolling content for the tab bar / bottom actions.
const bottomClearance = 110.0;

/// 44 × 44 rounded square button (back, close, header actions).
class PfIconButton extends StatelessWidget {
  const PfIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 20,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final button = Material(
      color: background ?? c.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: size, color: foreground ?? c.ink),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Back/close button + title (+ optional subtitle) + trailing actions.
class PfHeader extends StatelessWidget {
  const PfHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.close = false,
    this.onBack,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final bool close;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      children: [
        PfIconButton(
          icon: close ? LucideIcons.x : LucideIcons.arrowLeft,
          tooltip: close ? 'Close' : 'Back',
          onPressed: onBack ?? () => Navigator.maybePop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: pfText(20, weight: w900, color: c.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: pfText(12, weight: w800, color: c.sub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: 10), action],
      ],
    );
  }
}

/// Rounded card surface.
class PfCard extends StatelessWidget {
  const PfCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 24,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.pf.card,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );
  }
}

enum PfButtonStyle { primary, danger, softDanger, soft, outlineDanger, gold, neutral }

/// Full-width action button (58 high by default).
class PfButton extends StatelessWidget {
  const PfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = PfButtonStyle.primary,
    this.height = 58,
    this.fontSize = 17,
    this.radius = 20,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PfButtonStyle style;
  final double height;
  final double fontSize;
  final double radius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final (bg, fg, border) = switch (style) {
      PfButtonStyle.primary => (c.btn, c.onBtn, null),
      PfButtonStyle.danger => (c.cashOut, Colors.white, null),
      PfButtonStyle.softDanger => (c.outSoft, c.cashOut, null),
      PfButtonStyle.soft => (c.soft, c.cashIn, null),
      PfButtonStyle.outlineDanger => (Colors.transparent, c.cashOut, c.cashOut),
      PfButtonStyle.gold => (c.goldSoft, c.gold, null),
      PfButtonStyle.neutral => (c.card2, c.ink, null),
    };
    final disabled = onPressed == null;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: fontSize + 3, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: pfText(fontSize, weight: w900, color: fg),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return Opacity(
      opacity: disabled ? .5 : 1,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: border == null
              ? BorderSide.none
              : BorderSide(color: border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Compact pill/rounded button used inside cards and headers
/// (e.g. "+ New book", "Edit list", "Clear filters").
class PfSmallButton extends StatelessWidget {
  const PfSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 44,
    this.background,
    this.foreground,
    this.radius = 16,
    this.fontSize = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color? background;
  final Color? foreground;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = foreground ?? c.onBtn;
    return Material(
      color: background ?? c.btn,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onPressed,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 4, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label, style: pfText(fontSize, weight: w900, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Segmented control: the selected item is filled with ink.
class PfSegment<T> extends StatelessWidget {
  const PfSegment({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.height = 38,
    this.radius = 16,
    this.fontSize = 13.5,
  });

  final List<(T, String, IconData?)> items;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        children: [
          for (final (key, label, icon) in items) ...[
            if (key != items.first.$1) const SizedBox(width: 4),
            Expanded(
              child: _SegmentItem(
                label: label,
                icon: icon,
                selected: key == value,
                height: height,
                radius: radius - 4,
                fontSize: fontSize,
                onTap: () => onChanged(key),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.height,
    required this.radius,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final double height;
  final double radius;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = selected ? c.bg : c.sub;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize + 2, color: fg),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: pfText(fontSize, weight: w800, color: fg),
                    overflow: TextOverflow.ellipsis,
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

/// Selectable pill (goal chips, deadline chips, report types).
class PfChoiceChip extends StatelessWidget {
  const PfChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = selected ? c.cashIn : c.sub;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.soft : c.card,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? c.pri : c.line, width: 1.5),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(label, style: pfText(13, weight: w800, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Square-ish rounded tile holding an icon (entry rows, list leading icons).
class PfIconTile extends StatelessWidget {
  const PfIconTile({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 42,
    this.radius = 14,
    this.iconSize = 19,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: foreground),
    );
  }
}

/// Colored initial tile for a book.
class BookAvatar extends StatelessWidget {
  const BookAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 48,
  });

  final String name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: pfText(size * .41, weight: w900, color: Colors.white),
      ),
    );
  }
}

/// Small rounded label, e.g. currency code or "REACHED".
class PfBadge extends StatelessWidget {
  const PfBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.fontSize = 10.5,
    this.pill = false,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final double fontSize;
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pill ? 10 : 7, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? c.card2,
        borderRadius: BorderRadius.circular(pill ? 99 : 7),
      ),
      child: Text(
        label,
        style: pfText(fontSize, weight: w900, color: foreground ?? c.sub),
      ),
    );
  }
}

/// Horizontal rule between rows inside a card.
class PfDivider extends StatelessWidget {
  const PfDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.pf.line);
}

/// Small grey heading above a group of content ("Today", "Deadline").
class PfSectionLabel extends StatelessWidget {
  const PfSectionLabel(this.text, {super.key, this.optional = false, this.trailing});

  final String text;
  final bool optional;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                children: [
                  if (optional)
                    TextSpan(
                      text: ' · optional',
                      style: pfText(13, weight: w800, color: c.mute),
                    ),
                ],
              ),
              style: pfText(13, weight: w800, color: c.sub),
            ),
          ),
          if (trailing != null)
            Text(trailing!, style: pfText(13, weight: w800, color: c.sub)),
        ],
      ),
    );
  }
}

/// Red inline validation message.
class PfErrorBanner extends StatelessWidget {
  const PfErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.outSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 18, color: c.cashOut),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: pfText(13.5, weight: w800, color: c.cashOut),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue/green informational callout.
class PfNote extends StatelessWidget {
  const PfNote({
    super.key,
    required this.icon,
    required this.text,
    this.title,
    this.green = false,
  });

  final IconData icon;
  final String text;
  final String? title;
  final bool green;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = green ? c.cashIn : c.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: green ? c.soft : c.blueSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(title!, style: pfText(14.5, weight: w900, color: fg)),
                Text(
                  text,
                  style: pfText(
                    13,
                    weight: w700,
                    color: title == null ? fg : c.sub,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with icon, heading, body and an optional action ("No entries match").
class PfEmptyCard extends StatelessWidget {
  const PfEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return PfCard(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfIconTile(
            icon: icon,
            background: c.card2,
            foreground: c.sub,
            size: 52,
            radius: 18,
            iconSize: 24,
          ),
          const SizedBox(height: 10),
          Text(title, style: pfText(17, weight: w900, color: c.ink)),
          const SizedBox(height: 10),
          Text(body, style: pfText(14, weight: w600, color: c.sub)),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            PfSmallButton(
              label: actionLabel!,
              onPressed: onAction,
              height: 40,
              radius: 14,
              background: c.soft,
              foreground: c.cashIn,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows the design's dark toast with a green check.
void showPfToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: PfColors.toast,
        elevation: 8,
        duration: const Duration(milliseconds: 2600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        content: Row(
          children: [
            const Icon(
              LucideIcons.circleCheck,
              size: 20,
              color: PfColors.toastIcon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: pfText(14, weight: w800, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
}

/// Labelled input block inside a form card ("Title", "Book name"...).
class PfField extends StatelessWidget {
  const PfField({
    super.key,
    required this.label,
    required this.child,
    this.optional = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  final String label;
  final Widget child;
  final bool optional;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: [
                if (optional)
                  TextSpan(
                    text: ' · optional',
                    style: pfText(12, color: c.mute),
                  ),
              ],
            ),
            style: pfText(12, color: c.sub),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

/// Tappable row with a leading icon tile, label/value and a chevron
/// (Category, Payment mode, Date & time).
class PfPickerRow extends StatelessWidget {
  const PfPickerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.chevron = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            PfIconTile(
              icon: icon,
              background: c.card2,
              foreground: c.ink,
              size: 36,
              radius: 12,
              iconSize: 17,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: pfText(12, color: c.sub)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: pfText(16, color: c.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (chevron)
              Icon(LucideIcons.chevronDown, size: 19, color: c.sub),
          ],
        ),
      ),
    );
  }
}

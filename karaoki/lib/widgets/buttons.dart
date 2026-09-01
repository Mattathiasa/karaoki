import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/radius.dart';
import '../theme/typography.dart';

/// Primary lime gradient pill button
class KPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final bool enabled;

  const KPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.enabled = true,
  });

  @override
  State<KPrimaryButton> createState() => _KPrimaryButtonState();
}

class _KPrimaryButtonState extends State<KPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled && widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _controller.forward() : null,
      onTapUp: enabled ? (_) {
        _controller.reverse();
        widget.onPressed?.call();
      } : null,
      onTapCancel: enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: widget.width ?? double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: enabled ? KColors.limeGradient : null,
            color: enabled ? null : KColors.ink600,
            borderRadius: BorderRadius.circular(KRadius.pill),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: KColors.limeShadow,
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                      spreadRadius: -12,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: KTypography.uiButton.copyWith(
              color: enabled ? KColors.onAccent : KColors.bone28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button (bone/7% fill, hairline border)
class KSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;

  const KSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: KColors.panelFill,
          border: Border.all(color: KColors.hairline, width: 1),
          borderRadius: BorderRadius.circular(KRadius.pill),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(label, style: KTypography.uiButton),
          ],
        ),
      ),
    );
  }
}

/// Text-only button
class KTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const KTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        label,
        style: KTypography.uiButton.copyWith(
          color: color ?? KColors.bone55,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// Icon button (34-38px square, radius 12, panel fill)
class KIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const KIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: KColors.ink600,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: KColors.bone, size: size * 0.5),
      ),
    );
  }
}

/// Danger button
class KDangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const KDangerButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: KColors.red.withOpacity(0.2),
          border: Border.all(color: KColors.red.withOpacity(0.4), width: 1),
          borderRadius: BorderRadius.circular(KRadius.pill),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: KTypography.uiButton.copyWith(color: KColors.red),
        ),
      ),
    );
  }
}

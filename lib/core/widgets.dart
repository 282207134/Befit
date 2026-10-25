import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'theme.dart';

class Art extends StatelessWidget {
  const Art(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });
  final String path;
  final double? width, height;
  final BoxFit fit;
  final Color? color;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/$path',
    width: width,
    height: height,
    fit: fit,
    color: color,
    excludeFromSemantics: true,
  );
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.size = 30,
    this.weight = FontWeight.w800,
    this.gradient = Palette.heading,
    this.align,
  });
  final String text;
  final double size;
  final FontWeight weight;
  final Gradient gradient;
  final TextAlign? align;
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (bounds) => gradient.createShader(bounds),
    child: Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: size,
        height: 1.18,
        color: Colors.white,
        fontWeight: weight,
      ),
    ),
  );
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.contours = false});
  final Widget child;
  final bool contours;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/${contours ? 'bg.png' : 'bg3.png'}'),
        fit: BoxFit.cover,
      ),
    ),
    child: child,
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = 16,
    this.back = true,
    this.bottom,
    this.contours = false,
  });
  final Widget child;
  final String? title;
  final Widget? trailing, bottom;
  final double padding;
  final bool back, contours;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppBackground(
      contours: contours,
      child: SafeArea(
        child: Column(
          children: [
            if (back || title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    if (back) const BackCircle(),
                    if (title != null)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: back ? 16 : 0),
                          child: GradientText(title!),
                        ),
                      ),
                    if (title == null) const Spacer(),
                    ?trailing,
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: child,
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    ),
  );
}

class BackCircle extends StatelessWidget {
  const BackCircle({super.key});
  @override
  Widget build(BuildContext context) => IconCircle(
    icon: Icons.chevron_left_rounded,
    label: 'Back',
    onTap: () => Navigator.maybePop(context),
  );
}

class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 44,
    this.gradient,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;
  final Gradient? gradient;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            color: gradient == null
                ? Palette.panel.withValues(alpha: .28)
                : null,
            border: Border.all(color: Palette.muted.withValues(alpha: .15)),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, size: size * .55, color: Palette.text),
          ),
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool compact;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? .5 : 1,
    child: Container(
      height: compact ? 45 : 60,
      decoration: BoxDecoration(
        gradient: Palette.button,
        borderRadius: BorderRadius.circular(compact ? 13 : 18),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 16 : 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              if (label.isNotEmpty) const SizedBox(width: 8),
            ],
            if (label.isNotEmpty)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 14 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.gradient,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient:
          gradient ??
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF53557F), Color(0xFF3C3E68)],
          ),
      border: Border.all(color: Palette.muted.withValues(alpha: .22)),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class Segment extends StatelessWidget {
  const Segment({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 36,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Palette.panel,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        labels.length,
        (i) => InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 17),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == index ? Palette.background : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 13,
                color: i == index ? Colors.white : Palette.muted,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image = 'avatars/avatar.png',
    this.size = 50,
    this.ring = false,
    this.onTap,
  });
  final String image;
  final double size;
  final bool ring;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring ? 3 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: ring ? Palette.heading : null,
      ),
      child: ClipOval(child: Art(image, fit: BoxFit.cover)),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action});
  final String text;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      ?action,
    ],
  );
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class PersistenceBanner extends StatelessWidget {
  const PersistenceBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final error = AppScope.of(context).storageError;
    return error == null
        ? const SizedBox.shrink()
        : MaterialBanner(
            content: Text(error),
            actions: [
              TextButton(
                onPressed: AppScope.of(context).retrySave,
                child: const Text('Retry'),
              ),
            ],
          );
  }
}

class RingPainter extends CustomPainter {
  const RingPainter({
    required this.progress,
    this.color = Palette.purple,
    this.stroke = 10,
    this.start = -math.pi / 2,
    this.sweep = math.pi * 2,
  });
  final double progress, stroke, start, sweep;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bounds = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      bounds,
      start,
      sweep,
      false,
      paint..color = Palette.muted.withValues(alpha: .28),
    );
    canvas.drawArc(
      bounds,
      start,
      sweep * progress.clamp(0, 1),
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      progress != old.progress || color != old.color;
}

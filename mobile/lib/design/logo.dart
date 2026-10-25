import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// DARMAN symbol: a medical cross whose upper-right arm sprouts a leaf. Pure vector, scales to any size.
class DarmanSymbol extends StatelessWidget {
  const DarmanSymbol({super.key, this.size = 40, this.onDark = false});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: SymbolPainter(onDark: onDark),
    isComplex: false,
  );
}

class SymbolPainter extends CustomPainter {
  SymbolPainter({this.onDark = false, this.withBackground = true});
  final bool onDark;
  final bool withBackground;

  @override
  void paint(Canvas canvas, Size s) {
    final u = s.width / 100;
    if (withBackground) {
      final bg = RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(24 * u));
      canvas.drawRRect(
        bg,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DmPalette.mint, DmPalette.emerald],
          ).createShader(Offset.zero & s),
      );
    }
    final white = Paint()..color = Colors.white;
    // cross
    final arm = 22 * u;
    final len = 56 * u;
    final c = s.center(Offset.zero).translate(-2 * u, 3 * u);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: arm, height: len), Radius.circular(7 * u)), white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: len, height: arm), Radius.circular(7 * u)), white);
    // leaf growing from the upper-right
    final base = Offset(c.dx + 12 * u, c.dy - 12 * u);
    final leaf = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(base.dx + 2 * u, base.dy - 20 * u, base.dx + 20 * u, base.dy - 30 * u, base.dx + 34 * u, base.dy - 28 * u)
      ..cubicTo(base.dx + 36 * u, base.dy - 12 * u, base.dx + 22 * u, base.dy + 2 * u, base.dx, base.dy)
      ..close();
    canvas.drawPath(leaf, Paint()..color = withBackground ? const Color(0xFFD9F7EE) : DmPalette.mint);
    canvas.drawPath(
      Path()
        ..moveTo(base.dx + 2 * u, base.dy - 2 * u)
        ..quadraticBezierTo(base.dx + 16 * u, base.dy - 10 * u, base.dx + 30 * u, base.dy - 24 * u),
      Paint()
        ..color = DmPalette.emerald.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * u
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(SymbolPainter old) => old.onDark != onDark || old.withBackground != withBackground;
}

/// Symbol + DARMAN wordmark.
class DarmanLogo extends StatelessWidget {
  const DarmanLogo({super.key, this.height = 36, this.showWordmark = true, this.color});
  final double height;
  final bool showWordmark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? DmPalette.deepGreen;
    return Semantics(
      label: 'DARMAN',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DarmanSymbol(size: height),
            if (showWordmark) ...[
              SizedBox(width: height * 0.28),
              Text(
                'DARMAN',
                style: TextStyle(
                  fontSize: height * 0.62,
                  fontWeight: FontWeight.w800,
                  letterSpacing: height * 0.06,
                  color: textColor,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Soft botanical flourishes for hero areas (splash, onboarding, login, home header).
class BotanicalDecor extends StatelessWidget {
  const BotanicalDecor({super.key, this.opacity = 0.14, this.alignment = Alignment.topRight, this.size = 180});
  final double opacity;
  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: Align(
        alignment: alignment,
        child: CustomPaint(size: Size.square(size), painter: _LeavesPainter(opacity)),
      ),
    ),
  );
}

class _LeavesPainter extends CustomPainter {
  _LeavesPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = DmPalette.mint.withValues(alpha: opacity);
    final p2 = Paint()..color = DmPalette.emerald.withValues(alpha: opacity * 0.8);
    void leaf(Offset o, double len, double angle, Paint paint) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(len * 0.25, -len * 0.45, len * 0.8, -len * 0.4, len, 0)
        ..cubicTo(len * 0.8, len * 0.4, len * 0.25, len * 0.45, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    final w = s.width;
    leaf(Offset(w * 0.9, w * 0.05), w * 0.7, math.pi * 0.72, p);
    leaf(Offset(w * 0.95, w * 0.25), w * 0.55, math.pi * 0.95, p2);
    leaf(Offset(w * 0.7, w * 0.0), w * 0.5, math.pi * 0.55, p2);
  }

  @override
  bool shouldRepaint(_LeavesPainter old) => old.opacity != opacity;
}

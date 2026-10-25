import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// Local, licence-free product artwork. Real photos (http/https URLs) are used when present; otherwise a pack illustration is drawn
/// from the category and dosage form, so the UI never depends on third-party image hosts.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.categorySlug,
    this.form,
    this.label,
    this.imageUrl,
    this.size = 96,
    this.radius = 16,
    this.semanticLabel,
  });
  final String categorySlug;
  final String? form;
  final String? label;
  final String? imageUrl;
  final double size;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final Widget art = (url != null && url.startsWith('http'))
        ? Image.network(url, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, _, _) => _painted(context))
        : _painted(context);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(width: size, height: size, child: art),
      ),
    );
  }

  Widget _painted(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: PackPainter(
      accent: accentFor(categorySlug),
      shape: shapeFor(form, categorySlug),
      label: label,
      background: context.dm.paleAqua,
    ),
  );

  static Color accentFor(String slug) => switch (slug) {
    'pain-relief' => const Color(0xFFE5704F),
    'cold-flu' => const Color(0xFF4C9BE0),
    'vitamins' => const Color(0xFFF0A22E),
    'digestive' => const Color(0xFF8E6BD1),
    'first-aid' => const Color(0xFFD94F52),
    'skin-care' => const Color(0xFFE17FA6),
    'baby-care' => const Color(0xFF53B5C9),
    'personal-care' => const Color(0xFF3FAE7A),
    'medical-devices' => const Color(0xFF4A6FA5),
    'prescription' => const Color(0xFF17865B),
    _ => DmPalette.emerald,
  };

  static PackShape shapeFor(String? form, String slug) {
    final f = (form ?? '').toLowerCase();
    if (slug == 'medical-devices' || f.contains('прибор')) return PackShape.device;
    if (RegExp(r'сироп|капли|спрей|раствор|шампунь').hasMatch(f)) return PackShape.bottle;
    if (RegExp(r'крем|гель|мазь|паста').hasMatch(f)) return PackShape.tube;
    if (RegExp(r'подгузн|салфет|вата|бинт|пластыр|маски|чай|порошок|пустышка|леденц').hasMatch(f)) return PackShape.box;
    return PackShape.box;
  }
}

enum PackShape { box, bottle, tube, device }

class PackPainter extends CustomPainter {
  PackPainter({required this.accent, required this.shape, this.label, required this.background});
  final Color accent;
  final PackShape shape;
  final String? label;
  final Color background;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    canvas.drawRect(Offset.zero & s, Paint()..color = background);
    // soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, w * 0.86), width: w * 0.5, height: w * 0.06),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    final body = Paint()..color = Colors.white;
    final band = Paint()..color = accent;
    final outline = Paint()
      ..color = accent.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;

    switch (shape) {
      case PackShape.box:
        final r = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, w * 0.2, w * 0.6, w * 0.62), Radius.circular(w * 0.05));
        canvas.drawRRect(r, body);
        canvas.drawRRect(r, outline);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(w * 0.2, w * 0.2, w * 0.6, w * 0.2),
            topLeft: Radius.circular(w * 0.05),
            topRight: Radius.circular(w * 0.05),
          ),
          band,
        );
        _pill(canvas, Offset(w * 0.5, w * 0.62), w * 0.2, accent);
        _label(canvas, Rect.fromLTWH(w * 0.2, w * 0.2, w * 0.6, w * 0.2), Colors.white);
      case PackShape.bottle:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.38, w * 0.1, w * 0.24, w * 0.12), Radius.circular(w * 0.02)), band);
        canvas.drawRect(Rect.fromLTWH(w * 0.42, w * 0.22, w * 0.16, w * 0.08), body);
        final b = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, w * 0.3, w * 0.44, w * 0.52), Radius.circular(w * 0.08));
        canvas.drawRRect(b, body);
        canvas.drawRRect(b, outline);
        canvas.drawRect(Rect.fromLTWH(w * 0.28, w * 0.46, w * 0.44, w * 0.22), band);
        _label(canvas, Rect.fromLTWH(w * 0.28, w * 0.46, w * 0.44, w * 0.22), Colors.white);
      case PackShape.tube:
        final path = Path()
          ..moveTo(w * 0.3, w * 0.22)
          ..lineTo(w * 0.7, w * 0.22)
          ..lineTo(w * 0.66, w * 0.76)
          ..lineTo(w * 0.34, w * 0.76)
          ..close();
        canvas.drawPath(path, body);
        canvas.drawPath(path, outline);
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.315, w * 0.4)
            ..lineTo(w * 0.685, w * 0.4)
            ..lineTo(w * 0.672, w * 0.6)
            ..lineTo(w * 0.328, w * 0.6)
            ..close(),
          band,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.38, w * 0.1, w * 0.24, w * 0.12), Radius.circular(w * 0.03)), band);
        canvas.drawRect(Rect.fromLTWH(w * 0.34, w * 0.76, w * 0.32, w * 0.05), band);
        _label(canvas, Rect.fromLTWH(w * 0.33, w * 0.4, w * 0.34, w * 0.2), Colors.white);
      case PackShape.device:
        final d = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, w * 0.24, w * 0.56, w * 0.5), Radius.circular(w * 0.1));
        canvas.drawRRect(d, body);
        canvas.drawRRect(d, outline);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, w * 0.32, w * 0.4, w * 0.2), Radius.circular(w * 0.03)), band);
        canvas.drawCircle(Offset(w * 0.5, w * 0.63), w * 0.06, Paint()..color = accent.withValues(alpha: 0.7));
        _label(canvas, Rect.fromLTWH(w * 0.3, w * 0.32, w * 0.4, w * 0.2), Colors.white);
    }
  }

  void _pill(Canvas c, Offset o, double len, Color color) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(-0.6);
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: len, height: len * 0.45), Radius.circular(len * 0.22));
    c.drawRRect(r, Paint()..color = color.withValues(alpha: 0.9));
    c.drawRect(Rect.fromLTWH(0, -len * 0.225, len / 2, len * 0.45), Paint()..color = Colors.white.withValues(alpha: 0.85));
    c.restore();
  }

  void _label(Canvas canvas, Rect rect, Color color) {
    final t = (label ?? '').trim();
    if (t.isEmpty) return;
    final text = t.length > 6 ? t.substring(0, 6) : t;
    final tp = TextPainter(
      text: TextSpan(
        text: text.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: rect.height * 0.42, letterSpacing: 0.4),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.width * 0.92);
    tp.paint(canvas, Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(PackPainter old) => old.accent != accent || old.shape != shape || old.label != label || old.background != background;
}

import 'package:material_ui/material_ui.dart';

/// Значок масти, нарисованный вручную. Символы ♠♥♦♣ из шрифта на Android
/// подменяются цветными эмодзи, поэтому рисуем сами — цвет всегда наш.
class SuitIcon extends StatelessWidget {
  const SuitIcon({
    super.key,
    required this.suit,
    required this.size,
    required this.color,
  });

  final int suit; // 0 ♠, 1 ♥, 2 ♦, 3 ♣
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SuitPainter(suit, color));
}

class _SuitPainter extends CustomPainter {
  _SuitPainter(this.suit, this.color);
  final int suit;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    canvas.save();
    canvas.scale(s, s);
    final p = Paint()
      ..color = color
      ..isAntiAlias = true;
    switch (suit) {
      case 0: // ♠
        canvas.drawPath(
          Path()
            ..moveTo(50, 4)
            ..cubicTo(78, 34, 100, 48, 92, 68)
            ..cubicTo(85, 85, 62, 86, 55, 72)
            ..lineTo(62, 96)
            ..lineTo(38, 96)
            ..lineTo(45, 72)
            ..cubicTo(38, 86, 15, 85, 8, 68)
            ..cubicTo(0, 48, 22, 34, 50, 4)
            ..close(),
          p,
        );
      case 1: // ♥
        canvas.drawPath(
          Path()
            ..moveTo(50, 92)
            ..cubicTo(22, 68, 2, 50, 6, 30)
            ..cubicTo(10, 10, 40, 4, 50, 26)
            ..cubicTo(60, 4, 90, 10, 94, 30)
            ..cubicTo(98, 50, 78, 68, 50, 92)
            ..close(),
          p,
        );
      case 2: // ♦
        canvas.drawPath(
          Path()
            ..moveTo(50, 2)
            ..lineTo(88, 50)
            ..lineTo(50, 98)
            ..lineTo(12, 50)
            ..close(),
          p,
        );
      default: // ♣
        canvas.drawCircle(const Offset(50, 27), 21, p);
        canvas.drawCircle(const Offset(26, 58), 21, p);
        canvas.drawCircle(const Offset(74, 58), 21, p);
        canvas.drawPath(
          Path()
            ..moveTo(50, 45)
            ..lineTo(63, 97)
            ..lineTo(37, 97)
            ..close(),
          p,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SuitPainter o) => o.suit != suit || o.color != color;
}

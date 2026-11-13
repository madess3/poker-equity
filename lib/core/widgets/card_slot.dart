import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Пустое место под карту (пунктир). Карты появятся на этапе функций.
class CardSlot extends StatelessWidget {
  const CardSlot({super.key, this.width = 46, this.height = 62, this.color});

  final double width;
  final double height;
  final Color? color; // цвет рамки (выделенный слот — акцент)

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRect(color ?? context.colors.line),
      child: SizedBox(width: width, height: height),
    );
  }
}

class _DashedRect extends CustomPainter {
  _DashedRect(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRect old) => old.color != color;
}

import 'package:flutter/material.dart';
import 'package:beacon/utils/theme.dart';

class BeaconLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const BeaconLogo({
    Key? key,
    required this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppTheme.primaryColor;
    
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: BeaconLogoPainter(color: logoColor),
      ),
    );
  }
}

class BeaconLogoPainter extends CustomPainter {
  final Color color;

  BeaconLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw the upward arrow
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx, center.dy - radius),
      paint,
    );

    // Draw the downward arrow
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Draw the left arrow
    canvas.drawLine(
      center,
      Offset(center.dx - radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx - radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx - radius, center.dy),
      paint,
    );

    // Draw the right arrow
    canvas.drawLine(
      center,
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      Offset(center.dx + radius, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
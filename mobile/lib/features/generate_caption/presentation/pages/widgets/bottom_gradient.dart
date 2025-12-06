import 'package:flutter/material.dart';

class AnimatedGlowBlob extends StatefulWidget {
  const AnimatedGlowBlob({super.key});

  @override
  State<AnimatedGlowBlob> createState() => _AnimatedGlowBlobState();
}

class _AnimatedGlowBlobState extends State<AnimatedGlowBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GlowBlobPainter(_controller.value),
          size: const Size(double.infinity, 300),
        );
      },
    );
  }
}

class GlowBlobPainter extends CustomPainter {
  GlowBlobPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    // Position the oval center below the canvas to create dome effect
    final center = Offset(size.width / 2, size.height + size.height * 0.3);

    // Animated scale for subtle breathing effect
    final scale = 1.0 + t * 0.05;
    final radiusX = size.width * 0.8 * scale;
    final radiusY = size.height * 1.2 * scale;

    // Draw layered oval glows from outside to inside
    // Outermost - very soft light lavender
    final outerPaint = Paint()
      ..color = const Color(0xFF98A2FA).withOpacity(0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 100 + t * 20);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2.2,
        // width: radiusX * 2.2,
        height: radiusY * 2.2,
        // height: radiusY * 2.2,
      ),
      outerPaint,
    );

    // Middle layer - blue glow
    final middlePaint = Paint()
      ..color = const Color(0xFF6C8AF6).withOpacity(0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 70 + t * 15);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 1.6,
        height: radiusY * 1.6,
      ),
      middlePaint,
    );

    // Inner core - deeper purple/blue gradient
    final gradient = RadialGradient(
      center: const Alignment(0, 0.5),
      radius: 1,
      colors: [
        const Color(0xFF6C8AF6).withOpacity(0),
        const Color(0xFF5F3BD8).withOpacity(0),
        const Color(0xFF98A2FA),
        // const Color(0xFF98A2FA).withOpacity(0.3),
        // Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final rect = Rect.fromCenter(
      center: center,
      width: radiusX * 1.2,
      height: radiusY * 1.2,
    );
    final corePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 40 + t * 10);
    canvas.drawOval(rect, corePaint);
  }

  @override
  bool shouldRepaint(covariant GlowBlobPainter oldDelegate) =>
      oldDelegate.t != t;
}

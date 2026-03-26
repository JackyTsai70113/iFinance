import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const CelebrationOverlay({super.key, required this.onComplete});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiPiece> _pieces;
  final _random = Random();

  static const _colors = [
    Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.purple, Colors.pink,
    Colors.teal, Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _pieces = List.generate(40, (_) => _ConfettiPiece(
      x: _random.nextDouble(),
      speed: 0.3 + _random.nextDouble() * 0.7,
      size: 6 + _random.nextDouble() * 8,
      color: _colors[_random.nextInt(_colors.length)],
      rotation: _random.nextDouble() * 720,
      delay: _random.nextDouble() * 0.3,
      shape: _random.nextInt(3),
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });
    _controller.forward();
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
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ConfettiPainter(
            pieces: _pieces,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double delay;
  final int shape; // 0=circle, 1=rect, 2=diamond

  _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.delay,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2);
      final paint = Paint()..color = piece.color.withOpacity(opacity);

      final x = piece.x * size.width;
      final y = -20 + t * (size.height + 40) * piece.speed;
      final wobble = sin(t * pi * 4) * 20;

      canvas.save();
      canvas.translate(x + wobble, y);
      canvas.rotate(t * piece.rotation * pi / 180);

      switch (piece.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, piece.size / 2, paint);
          break;
        case 1:
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
            paint,
          );
          break;
        default:
          final path = Path()
            ..moveTo(0, -piece.size / 2)
            ..lineTo(piece.size / 2, 0)
            ..lineTo(0, piece.size / 2)
            ..lineTo(-piece.size / 2, 0)
            ..close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

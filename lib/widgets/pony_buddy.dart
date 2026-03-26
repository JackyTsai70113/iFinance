import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PonyBuddy extends StatefulWidget {
  final int transactionCount;
  final double balance;
  final String reaction; // 'idle', 'happy', 'surprised', 'cheerful'

  const PonyBuddy({
    super.key,
    required this.transactionCount,
    required this.balance,
    this.reaction = 'idle',
  });

  @override
  State<PonyBuddy> createState() => _PonyBuddyState();
}

class _PonyBuddyState extends State<PonyBuddy> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  String _currentMessage = '';
  bool _showBubble = true;
  Timer? _messageTimer;
  Timer? _blinkTimer;
  final _random = Random();

  List<String> get _messages {
    switch (widget.reaction) {
      case 'happy':
        return ['太棒了，賺到錢了！', '收入 GET！', '咴咴～好開心！'];
      case 'surprised':
        return ['哇！花了不少耶！', '大筆支出！注意喔～', '噢噢...荷包在哭！'];
      case 'cheerful':
        return ['記帳成功！', '又記了一筆，讚！', '+10 XP！'];
      default:
        break;
    }

    final pool = <String>[
      '記帳是好習慣喔～', '今天也要好好記帳呀！', '小馬陪你一起！',
      '你好棒，繼續加油！', '每一筆都是進步～', '理財從記帳開始！',
      '嘿嘿，我在這陪你～', '存錢錢，買紅蘿蔔！', '你是最棒的記帳達人！',
      '小小記錄，大大改變！', '噠噠噠～小馬來了！', '咴咴～一起加油！',
    ];
    if (widget.transactionCount == 0) {
      pool.addAll(['快來記第一筆吧～', '點右上角 + 開始記帳！', '空空的...快記一筆吧！']);
    }
    if (widget.transactionCount > 5) {
      pool.addAll(['哇，你好認真記帳！', '超棒的！繼續保持！', '記帳達人就是你！']);
    }
    if (widget.balance > 0) {
      pool.addAll(['結餘是正的，太棒了！', '存到錢了耶，好厲害！']);
    }
    if (widget.balance < 0) {
      pool.addAll(['花有點多...注意一下喔', '沒關係，慢慢調整～']);
    }
    return pool;
  }

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _currentMessage = _messages[_random.nextInt(_messages.length)];
    _startMessageLoop();
    _startBlinkLoop();
  }

  @override
  void didUpdateWidget(PonyBuddy oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reaction != widget.reaction && widget.reaction != 'idle') {
      setState(() {
        _currentMessage = _messages[_random.nextInt(_messages.length)];
      });
    }
  }

  void _startMessageLoop() {
    _messageTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _showBubble = false;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentMessage = _messages[_random.nextInt(_messages.length)];
              _showBubble = true;
            });
          }
        });
      }
    });
  }

  void _startBlinkLoop() {
    _scheduleBlink();
  }

  void _scheduleBlink() {
    final delay = Duration(milliseconds: 2000 + _random.nextInt(2500));
    _blinkTimer = Timer(delay, () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _scheduleBlink();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _blinkController.dispose();
    _messageTimer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final bounce = sin(_bounceController.value * pi) * 5;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Speech bubble
              AnimatedOpacity(
                opacity: _showBubble ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: _showBubble ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  alignment: Alignment.bottomRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      _currentMessage,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown.shade600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Pony emoji representation
              _buildPony(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPony() {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, _) {
        final isBlinking = _blinkController.value > 0.3;
        final isHappy =
            widget.reaction == 'happy' || widget.reaction == 'cheerful';
        final isSurprised = widget.reaction == 'surprised';

        return SizedBox(
          width: 70,
          height: 75,
          child: CustomPaint(
            painter: _PonyPainter(
              isBlinking: isBlinking,
              isHappy: isHappy,
              isSurprised: isSurprised,
              cheekGlow: isHappy,
            ),
          ),
        );
      },
    );
  }
}

class _PonyPainter extends CustomPainter {
  final bool isBlinking;
  final bool isHappy;
  final bool isSurprised;
  final bool cheekGlow;

  _PonyPainter({
    required this.isBlinking,
    required this.isHappy,
    required this.isSurprised,
    required this.cheekGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF2BF80), Color(0xFFD99A59)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(
          center: Offset(cx, 50), width: 50, height: 40));
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, 50), width: 50, height: 40),
        bodyPaint);

    // Legs
    final legPaint = Paint()..color = const Color(0xFFCC8C4D);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 15, 62, 8, 14), const Radius.circular(3)),
        legPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 7, 62, 8, 14), const Radius.circular(3)),
        legPaint);

    // Hooves
    final hoofPaint = Paint()..color = const Color(0xFF593D26);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 16, 74, 10, 4), const Radius.circular(2)),
        hoofPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 6, 74, 10, 4), const Radius.circular(2)),
        hoofPaint);

    // Head
    final headPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF2C78D), Color(0xFFE0A666)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(
          center: Offset(cx, 22), width: 40, height: 36));
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, 22), width: 40, height: 36),
        headPaint);

    // Ears
    final earPaint = Paint()..color = const Color(0xFFE6B373);
    final earInnerPaint = Paint()..color = Colors.pink.withOpacity(0.3);
    // Left ear
    _drawEar(canvas, Offset(cx - 14, 4), earPaint, earInnerPaint);
    // Right ear
    _drawEar(canvas, Offset(cx + 14, 4), earPaint, earInnerPaint);

    // Mane
    final manePaint = Paint()..color = const Color(0xFFD98C40);
    final manePath = Path()
      ..moveTo(cx - 8, 6)
      ..quadraticBezierTo(cx, -2, cx + 8, 6)
      ..quadraticBezierTo(cx + 4, 4, cx, 8)
      ..quadraticBezierTo(cx - 4, 4, cx - 8, 6);
    canvas.drawPath(manePath, manePaint);

    // Eyes
    if (isBlinking) {
      final blinkPaint = Paint()
        ..color = const Color(0xFF33261A)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(cx - 8, 20), Offset(cx - 4, 20), blinkPaint);
      canvas.drawLine(
          Offset(cx + 4, 20), Offset(cx + 8, 20), blinkPaint);
    } else {
      final eyeWhite = Paint()..color = Colors.white;
      final eyePupil = Paint()..color = const Color(0xFF33261A);
      final eyeHighlight = Paint()..color = Colors.white;

      final eyeH = isSurprised ? 7.0 : (isHappy ? 4.0 : 6.0);

      // Left eye
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 6, 20), width: 10, height: eyeH),
          eyeWhite);
      canvas.drawCircle(Offset(cx - 6, 20), isSurprised ? 3.5 : 3, eyePupil);
      canvas.drawCircle(Offset(cx - 7, 19), 1.2, eyeHighlight);

      // Right eye
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 6, 20), width: 10, height: eyeH),
          eyeWhite);
      canvas.drawCircle(Offset(cx + 6, 20), isSurprised ? 3.5 : 3, eyePupil);
      canvas.drawCircle(Offset(cx + 5, 19), 1.2, eyeHighlight);
    }

    // Snout
    final snoutPaint = Paint()..color = const Color(0xFFF8D9B3);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, 30), width: 18, height: 10),
        snoutPaint);

    // Nostrils
    final nostrilPaint = Paint()..color = const Color(0xFFB3805A);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 3, 30), width: 3, height: 2),
        nostrilPaint);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 3, 30), width: 3, height: 2),
        nostrilPaint);

    // Mouth
    if (isSurprised) {
      final mouthPaint = Paint()
        ..color = const Color(0xFFA67348)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 34), width: 8, height: 6),
          mouthPaint);
    } else {
      final mouthPaint = Paint()
        ..color = const Color(0xFFA67348)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      final mouthPath = Path()
        ..moveTo(cx - 4, 33)
        ..quadraticBezierTo(cx, isHappy ? 38 : 36, cx + 4, 33);
      canvas.drawPath(mouthPath, mouthPaint);
    }

    // Cheeks
    final cheekPaint = Paint()
      ..color = Colors.pink.withOpacity(cheekGlow ? 0.45 : 0.2);
    canvas.drawCircle(Offset(cx - 14, 26), 3.5, cheekPaint);
    canvas.drawCircle(Offset(cx + 14, 26), 3.5, cheekPaint);

    // Sparkles when happy
    if (isHappy) {
      final sparklePaint = Paint()..color = Colors.amber;
      _drawStar(canvas, Offset(cx + 22, 8), 3, sparklePaint);
      _drawStar(canvas, Offset(cx - 20, 12), 2, sparklePaint);
    }

    // Tail
    final tailPaint = Paint()..color = const Color(0xFFD98C40);
    final tailPath = Path()
      ..moveTo(cx - 25, 44)
      ..quadraticBezierTo(cx - 38, 50, cx - 30, 60)
      ..quadraticBezierTo(cx - 28, 52, cx - 25, 44);
    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawEar(Canvas canvas, Offset center, Paint outer, Paint inner) {
    final earPath = Path()
      ..moveTo(center.dx, center.dy - 8)
      ..lineTo(center.dx - 5, center.dy + 4)
      ..lineTo(center.dx + 5, center.dy + 4)
      ..close();
    canvas.drawPath(earPath, outer);
    final innerPath = Path()
      ..moveTo(center.dx, center.dy - 4)
      ..lineTo(center.dx - 3, center.dy + 2)
      ..lineTo(center.dx + 3, center.dy + 2)
      ..close();
    canvas.drawPath(innerPath, inner);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - pi / 2;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final midAngle = angle + pi / 4;
      final mx = center.dx + cos(midAngle) * (radius * 0.4);
      final my = center.dy + sin(midAngle) * (radius * 0.4);
      path.lineTo(mx, my);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PonyPainter oldDelegate) =>
      isBlinking != oldDelegate.isBlinking ||
      isHappy != oldDelegate.isHappy ||
      isSurprised != oldDelegate.isSurprised ||
      cheekGlow != oldDelegate.cheekGlow;
}

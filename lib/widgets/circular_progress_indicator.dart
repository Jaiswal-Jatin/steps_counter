import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomCircularProgressIndicator extends StatefulWidget {
  final double progress;
  final int currentSteps;
  final int goalSteps;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    required this.currentSteps,
    required this.goalSteps,
  });

  @override
  State<CustomCircularProgressIndicator> createState() =>
      _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState
    extends State<CustomCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(250, 250),
          painter: CircularProgressPainter(
            progress: widget.progress * _animation.value,
            currentSteps: widget.currentSteps,
            goalSteps: widget.goalSteps,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final int currentSteps;
  final int goalSteps;
  final bool isDarkMode;

  CircularProgressPainter({
    required this.progress,
    required this.currentSteps,
    required this.goalSteps,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final backgroundPaint = Paint()
      ..color = isDarkMode
          ? Colors.grey.withOpacity(0.2)
          : Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFFFF6B35), const Color(0xFFFF8A50)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Center content
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Step count
    textPainter.text = TextSpan(
      text: currentSteps.toString(),
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 10,
      ),
    );

    // Goal text
    textPainter.text = TextSpan(
      text: 'Goal: ${goalSteps.toString()}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 20),
    );

    // Pause and more options buttons
    final buttonRadius = 20.0;
    final buttonY = center.dy - radius - 40;

    // Pause button
    final pauseButtonCenter = Offset(center.dx - 60, buttonY);
    final pauseButtonPaint = Paint()
      ..color = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pauseButtonCenter, buttonRadius, pauseButtonPaint);

    // Pause icon
    final pauseIconPaint = Paint()
      ..color = isDarkMode ? Colors.white : Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(pauseButtonCenter.dx - 4, pauseButtonCenter.dy - 6, 3, 12),
      pauseIconPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(pauseButtonCenter.dx + 1, pauseButtonCenter.dy - 6, 3, 12),
      pauseIconPaint,
    );

    // More options button
    final moreButtonCenter = Offset(center.dx + 60, buttonY);
    canvas.drawCircle(moreButtonCenter, buttonRadius, pauseButtonPaint);

    // More icon (three dots)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(moreButtonCenter.dx - 4 + (i * 4), moreButtonCenter.dy),
        1.5,
        pauseIconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:steps_counter_app/src/theme.dart';

class ProgressRing extends StatelessWidget {
  final int steps;
  final int goal;
  final Widget? child;
  const ProgressRing({super.key, required this.steps, required this.goal, this.child});

  @override
  Widget build(BuildContext context) {
    final pct = ((steps / goal).clamp(0.0, 1.0)).toDouble();
    return CustomPaint(
      painter: _RingPainter(progress: pct),
      child: SizedBox(
        height: 220,
        width: 220,
        child: Center(
          child: child ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$steps', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: StepGoTheme.primary)),
                  const SizedBox(height: 4),
                  const Text('steps'),
                  const SizedBox(height: 4),
                  Text('${(goal - steps).clamp(0, goal)} to go', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StepGoTheme.muted)),
                ],
              ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - stroke) / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = Colors.orange.shade100;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = StepGoTheme.primary;

    canvas.drawCircle(center, radius, bg);

    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/constants/app_colors.dart';

class StepCounterWidget extends StatefulWidget {
  final int currentSteps;
  final int dailyGoal;
  final double progress;
  final VoidCallback? onGoalTap;

  const StepCounterWidget({
    super.key,
    required this.currentSteps,
    required this.dailyGoal,
    required this.progress,
    this.onGoalTap,
  });

  @override
  State<StepCounterWidget> createState() => _StepCounterWidgetState();
}

class _StepCounterWidgetState extends State<StepCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(StepCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(
            begin: _progressAnimation.value,
            end: widget.progress,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date and weather
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_left,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.wb_cloudy, color: Colors.blue, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '25°C',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),

              // Progress circle
              SizedBox(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CircularProgressPainter(
                        progress: _progressAnimation.value,
                        strokeWidth: 8,
                        progressColor: AppColors.primaryOrange,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      ),
                    );
                  },
                ),
              ),

              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Walking icon
                  Icon(
                    Icons.directions_walk,
                    size: 40,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(height: 8),

                  // Step count
                  Text(
                    widget.currentSteps.toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),

                  // Goal
                  GestureDetector(
                    onTap: widget.onGoalTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Goal: ${widget.dailyGoal}',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.pause,
                onPressed: () {
                  // Pause tracking
                },
              ),
              _buildControlButton(
                icon: Icons.more_horiz,
                onPressed: () {
                  // More options
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

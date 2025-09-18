import 'package:flutter/material.dart';

class SimpleBars extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  final Color color;
  final int maxHint; // upper bound hint for y-axis

  const SimpleBars({super.key, required this.values, required this.labels, required this.color, required this.maxHint});

  @override
  Widget build(BuildContext context) {
    final maxV = (values.fold<int>(0, (p, e) => e > p ? e : p)).clamp(1, 999999);
    final bound = maxHint > 0 ? maxHint : maxV;
    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final v = values[i];
          final h = (v / bound) * 180;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: h.clamp(4, 180),
                    decoration: BoxDecoration(
                      color: i == values.length - 1 ? color : color.withOpacity(.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(labels[i], style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

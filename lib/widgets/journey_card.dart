import 'package:flutter/material.dart';

class JourneyCard extends StatelessWidget {
  final String title;
  final double remainingDistance;
  final double totalDistance;
  final double progress;

  const JourneyCard({
    super.key,
    required this.title,
    required this.remainingDistance,
    required this.totalDistance,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4FC3F7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${(totalDistance - remainingDistance).toStringAsFixed(0)}km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${remainingDistance.toStringAsFixed(0)} km left',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

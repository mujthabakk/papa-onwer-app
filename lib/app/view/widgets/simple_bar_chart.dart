import 'package:flutter/material.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class SimpleBarPoint {
  final String label;
  final double value;

  const SimpleBarPoint({required this.label, required this.value});
}

/// Lightweight bar chart. Avoids Syncfusion fade-transition crashes when a
/// route is pushed/popped over the tab IndexedStack.
class SimpleBarChart extends StatelessWidget {
  final String title;
  final String valueSuffix;
  final List<SimpleBarPoint> points;

  const SimpleBarChart({
    super.key,
    required this.title,
    required this.valueSuffix,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(0, (m, p) {
      final v = p.value;
      return v > m ? v : m;
    });
    final maxY = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontFamily: 'medium'),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: points.isEmpty
              ? const Center(child: Text('-'))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final point in points)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor:
                                        (point.value / maxY).clamp(0.0, 1.0),
                                    widthFactor: 0.72,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: ThemeProvider.appColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                point.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 9),
                              ),
                              Text(
                                '${point.value.toStringAsFixed(point.value % 1 == 0 ? 0 : 1)}$valueSuffix',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'bold',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

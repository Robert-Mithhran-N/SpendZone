import 'package:flutter/material.dart';

/// Animated number counter that smoothly transitions between values.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final int decimalDigits;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
    this.decimalDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        String formatted;
        if (decimalDigits == 0) {
          formatted = _formatIndianNumber(animatedValue.round());
        } else {
          formatted = animatedValue.toStringAsFixed(decimalDigits);
        }
        return Text(
          '$prefix$formatted$suffix',
          style: style ?? Theme.of(context).textTheme.displayLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// Format number in Indian numbering system: 1,23,456
  String _formatIndianNumber(int number) {
    final isNegative = number < 0;
    final absStr = number.abs().toString();

    if (absStr.length <= 3) {
      return '${isNegative ? '-' : ''}$absStr';
    }

    final lastThree = absStr.substring(absStr.length - 3);
    String remaining = absStr.substring(0, absStr.length - 3);

    final buffer = StringBuffer();
    while (remaining.length > 2) {
      buffer.write('${remaining.substring(remaining.length - 2)},');
      remaining = remaining.substring(0, remaining.length - 2);
    }

    final result = '$remaining,${buffer.toString().split('').reversed.join('')}$lastThree';
    return '${isNegative ? '-' : ''}$result';
  }
}

import 'package:flutter/material.dart';

class DJLinearProgressIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final LinearGradient gradient;
  final BorderRadius? borderRadius;
  final Color backgroundColor;

  const DJLinearProgressIndicator({
    super.key,
    required this.width,
    required this.height,
    required this.progress,
    required this.gradient,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFECECEC),
  });

  DJLinearProgressIndicator.colors({
    super.key,
    required this.width,
    required this.height,
    required this.progress,
    List<Color> colors = const [Color(0xFFFF0400), Color(0xFFFF4336)],
    this.borderRadius,
    this.backgroundColor = const Color(0xFFECECEC),
  }) : gradient = LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: _GradientProgressBarPainter(
          progress: progress,
          gradient: gradient,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _GradientProgressBarPainter extends CustomPainter {
  final double progress;
  final LinearGradient gradient;
  final BorderRadius? borderRadius;
  final Color backgroundColor;

  _GradientProgressBarPainter({
    required this.progress,
    required this.gradient,
    this.borderRadius,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final _bgColor = backgroundColor;
    final _borderRadius = borderRadius ?? BorderRadius.circular(size.height / 2);
    final contentW = size.width;
    // 画背景
    if (_bgColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = _bgColor
        ..style = PaintingStyle.fill;
      final backgroundRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, contentW, size.height),
        topLeft: _borderRadius.topLeft,
        topRight: _borderRadius.topRight,
        bottomLeft: _borderRadius.bottomLeft,
        bottomRight: _borderRadius.bottomRight,
      );
      canvas.drawRRect(backgroundRect, backgroundPaint);
    }

    // 画进度条
    final _value = progress.clamp(.0, 1.0);
    if (_value > 0) {
      final paint = Paint()..style = PaintingStyle.fill;
      final progressW = contentW * _value;
      paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, progressW, size.height));
      final progressRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, progressW, size.height),
        topLeft: _borderRadius.topLeft,
        topRight: _borderRadius.topRight,
        bottomLeft: _borderRadius.bottomLeft,
        bottomRight: _borderRadius.bottomRight,
      );
      canvas.drawRRect(progressRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

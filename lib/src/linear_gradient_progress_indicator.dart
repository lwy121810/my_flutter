import 'package:flutter/material.dart';

/// 渐变背景色的进度条
class LinearGradientProgressIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final LinearGradient gradient;
  final BorderRadius? borderRadius;
  final Color backgroundColor;

  const LinearGradientProgressIndicator({
    super.key,
    required this.width,
    required this.height,
    required this.progress,
    required this.gradient,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFECECEC),
  });

  LinearGradientProgressIndicator.colors({
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
    final bgColor = backgroundColor;
    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(size.height / 2);
    final contentW = size.width;
    // 画背景
    if (bgColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill;
      final backgroundRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, contentW, size.height),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
      canvas.drawRRect(backgroundRect, backgroundPaint);
    }

    // 画进度条
    final value = progress.clamp(.0, 1.0);
    if (value > 0) {
      final paint = Paint()..style = PaintingStyle.fill;
      final progressW = contentW * value;
      paint.shader =
          gradient.createShader(Rect.fromLTWH(0, 0, progressW, size.height));
      final progressRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, progressW, size.height),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
      canvas.drawRRect(progressRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

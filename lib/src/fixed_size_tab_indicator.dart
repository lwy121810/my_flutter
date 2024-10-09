import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
/// 固定大小的tab指示器
class FixedSizeTabIndicator extends Decoration {
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Gradient? gradient;
  final double width;
  final double height;

  const FixedSizeTabIndicator({
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(1)),
    this.gradient = const LinearGradient(
      colors: [
        Color(0xFFFF3100),
        Color(0xFFFF5C57),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    this.width = 22,
    this.height = 4,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FixedBoxDecorationPainter(this, onChanged);
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    if (borderRadius != null) {
      return Path()
        ..addRRect(borderRadius!.resolve(textDirection).toRRect(rect));
    }
    return Path()..addRect(rect);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FixedSizeTabIndicator &&
        other.color == color &&
        other.borderRadius == borderRadius &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(
        color,
        borderRadius,
        gradient,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.whitespace
      ..emptyBodyDescription = '<no decorations specified>';

    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<BorderRadiusGeometry>(
        'borderRadius', borderRadius,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Gradient>('gradient', gradient,
        defaultValue: null));
  }

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) {
    assert((Offset.zero & size).contains(position));
    if (borderRadius != null) {
      final RRect bounds =
          borderRadius!.resolve(textDirection).toRRect(Offset.zero & size);
      return bounds.contains(position);
    }
    return true;
  }
}

class _FixedBoxDecorationPainter extends BoxPainter {
  _FixedBoxDecorationPainter(this._decoration, VoidCallback? onChanged)
      : super(onChanged);

  final FixedSizeTabIndicator _decoration;

  Paint? _cachedBackgroundPaint;
  Rect? _rectForCachedBackgroundPaint;

  DecorationImagePainter? _imagePainter;

  @override
  void dispose() {
    _imagePainter?.dispose();
    super.dispose();
  }

  void _paintBox(
      Canvas canvas, Rect rect, Paint paint, TextDirection? textDirection) {
    if (_decoration.borderRadius == null ||
        _decoration.borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(
          _decoration.borderRadius!.resolve(textDirection).toRRect(rect),
          paint);
    }
  }

  void _paintBackgroundColor(
      Canvas canvas, Rect rect, TextDirection? textDirection) {
    if (_decoration.color != null || _decoration.gradient != null) {
      _paintBox(canvas, rect, _getBackgroundPaint(rect, textDirection),
          textDirection);
    }
  }

  Paint _getBackgroundPaint(Rect rect, TextDirection? textDirection) {
    assert(
        _decoration.gradient != null || _rectForCachedBackgroundPaint == null);

    if (_cachedBackgroundPaint == null ||
        (_decoration.gradient != null &&
            _rectForCachedBackgroundPaint != rect)) {
      final Paint paint = Paint();

      if (_decoration.color != null) {
        paint.color = _decoration.color!;
      }
      if (_decoration.gradient != null) {
        paint.shader = _decoration.gradient!
            .createShader(rect, textDirection: textDirection);
        _rectForCachedBackgroundPaint = rect;
      }
      _cachedBackgroundPaint = paint;
    }

    return _cachedBackgroundPaint!;
  }

  /// Paint the box decoration into the given location on the given canvas.
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    Rect rect = offset & configuration.size!;

    final TextDirection? textDirection = configuration.textDirection;
    final width = _decoration.width;
    final height = _decoration.height;
    final left = rect.left + (rect.width - width) / 2;
    final top = rect.bottom - height;

    rect = Rect.fromLTWH(left, top, width, height);
    _paintBackgroundColor(canvas, rect, textDirection);
  }

  @override
  String toString() {
    return 'BoxPainter for $_decoration';
  }
}

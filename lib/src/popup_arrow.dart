import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum PopupArrowPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension Direction on PopupArrowPosition {
  bool get isTop =>
      this == PopupArrowPosition.topLeft || this == PopupArrowPosition.topRight || this == PopupArrowPosition.topCenter;

  bool get isBottom =>
      this == PopupArrowPosition.bottomCenter ||
      this == PopupArrowPosition.bottomRight ||
      this == PopupArrowPosition.bottomLeft;

  bool get isLeft => this == PopupArrowPosition.topLeft || this == PopupArrowPosition.bottomLeft;

  bool get isCenter => this == PopupArrowPosition.topCenter || this == PopupArrowPosition.bottomCenter;

  bool get isRight => this == PopupArrowPosition.topRight || this == PopupArrowPosition.bottomRight;

  bool get isBottomLeft => this == PopupArrowPosition.bottomLeft;

  bool get isBottomRight => this == PopupArrowPosition.bottomRight;

  bool get isTopLeft => this == PopupArrowPosition.topLeft;

  bool get isTopRight => this == PopupArrowPosition.topRight;

  bool get isCorner => isTopLeft || isTopRight || isBottomLeft || isBottomRight;
}

class PopupArrowWidget extends StatelessWidget {
  final Color fillColor;
  final Size arrowSize;
  final PopupArrowPosition arrowPosition;
  final Offset? origin;
  final BorderRadius? borderRadius;

  final Gradient? gradient;

  /// 是否是直角三角形的箭头
  final bool autoRightAngle;
  final Size size;
  final Widget? child;

  const PopupArrowWidget({
    Key? key,
    this.fillColor = const Color(0xFFFF0400),
    this.arrowSize = const Size(5, 3),
    this.size = Size.zero,
    this.arrowPosition = PopupArrowPosition.bottomCenter,
    this.origin,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.autoRightAngle = false,
    this.child,
    this.gradient,
  }) : super(key: key);

  const PopupArrowWidget.rightAngle({
    Key? key,
    this.fillColor = const Color(0xFFFF0400),
    this.arrowSize = const Size(8, 4),
    this.size = Size.zero,
    this.arrowPosition = PopupArrowPosition.bottomCenter,
    this.origin,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.child,
    this.gradient,
  })  : autoRightAngle = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _PopupContainerPaintWidget(
        size: size,
        arrowSize: arrowSize,
        arrowPosition: arrowPosition,
        painter: PopupArrowPainter(
          fillColor: fillColor,
          gradient: gradient,
          arrowSize: arrowSize,
          arrowPosition: arrowPosition,
          origin: origin,
          borderRadius: borderRadius,
          autoRightAngle: autoRightAngle,
        ),
        child: child,
      ),
    );
  }
}

class _PopupContainerPaintWidget extends SingleChildRenderObjectWidget {
  /// Creates a widget that delegates its painting.
  const _PopupContainerPaintWidget({
    Key? key,
    this.painter,
    this.foregroundPainter,
    this.size = Size.zero,
    this.isComplex = false,
    this.willChange = false,
    Widget? child,
    required this.arrowSize,
    required this.arrowPosition,
  })  : assert(painter != null || foregroundPainter != null || (!isComplex && !willChange)),
        super(key: key, child: child);

  final CustomPainter? painter;
  final CustomPainter? foregroundPainter;
  final Size size;
  final bool isComplex;
  final bool willChange;
  final Size arrowSize;
  final PopupArrowPosition arrowPosition;

  @override
  RenderCustomPaint createRenderObject(BuildContext context) {
    return _PopupContainerRenderCustomPaint(
      painter: painter,
      foregroundPainter: foregroundPainter,
      preferredSize: size,
      isComplex: isComplex,
      willChange: willChange,
      arrowSize: arrowSize,
      arrowPosition: arrowPosition,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _PopupContainerRenderCustomPaint renderObject) {
    renderObject
      ..painter = painter
      ..foregroundPainter = foregroundPainter
      ..preferredSize = size
      ..isComplex = isComplex
      ..willChange = willChange
      ..arrowSize = arrowSize
      ..arrowPosition = arrowPosition;
  }

  @override
  void didUnmountRenderObject(_PopupContainerRenderCustomPaint renderObject) {
    renderObject
      ..painter = null
      ..foregroundPainter = null;
  }
}

class _PopupContainerRenderCustomPaint extends RenderCustomPaint {
  _PopupContainerRenderCustomPaint({
    CustomPainter? painter,
    CustomPainter? foregroundPainter,
    Size preferredSize = Size.zero,
    bool isComplex = false,
    bool willChange = false,
    RenderBox? child,
    required PopupArrowPosition arrowPosition,
    required Size arrowSize,
  })  : _arrowSize = arrowSize,
        _arrowPosition = arrowPosition,
        super(
          painter: painter,
          foregroundPainter: foregroundPainter,
          preferredSize: preferredSize,
          isComplex: isComplex,
          willChange: willChange,
          child: child,
        );

  Size get arrowSize => _arrowSize;
  Size _arrowSize;

  set arrowSize(Size value) {
    if (arrowSize == value) {
      return;
    }
    _arrowSize = value;
    markNeedsLayout();
  }

  PopupArrowPosition get arrowPosition => _arrowPosition;
  PopupArrowPosition _arrowPosition;

  set arrowPosition(PopupArrowPosition value) {
    if (arrowPosition == value) {
      return;
    }
    _arrowPosition = value;
    markNeedsLayout();
  }

  @override
  Size get size => Size(super.size.width, super.size.height + arrowSize.height);

  /// 组件在在屏幕坐标中的起始偏移坐标
  Offset get offset => localToGlobal(Offset.zero);

  /// 组件在屏幕上占有的矩形空间区域
  Rect get rect => offset & size;

  @override
  double computeMaxIntrinsicHeight(double width) {
    return super.computeMaxIntrinsicHeight(width) + arrowSize.height;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final h = super.computeMinIntrinsicHeight(width);
    return h + arrowSize.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (painter != null) {
      _paintWithPainter(context.canvas, offset, painter!);
      _setRasterCacheHints(context);
    }
    _superPaint(context, offset);

    if (foregroundPainter != null) {
      _paintWithPainter(context.canvas, offset, foregroundPainter!);
      _setRasterCacheHints(context);
    }
  }

  void _superPaint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }
    if (arrowPosition.isTop) {
      offset = offset + Offset(0, arrowSize.height);
    }
    context.paintChild(child, offset);
  }

  void _paintWithPainter(Canvas canvas, Offset offset, CustomPainter painter) {
    late int debugPreviousCanvasSaveCount;
    canvas.save();
    assert(() {
      debugPreviousCanvasSaveCount = canvas.getSaveCount();
      return true;
    }());
    if (offset != Offset.zero) {
      canvas.translate(offset.dx, offset.dy);
    }
    painter.paint(canvas, size);
    assert(() {
      // This isn't perfect. For example, we can't catch the case of
      // someone first restoring, then setting a transform or whatnot,
      // then saving.
      // If this becomes a real problem, we could add logic to the
      // Canvas class to lock the canvas at a particular save count
      // such that restore() fails if it would take the lock count
      // below that number.
      final int debugNewCanvasSaveCount = canvas.getSaveCount();
      if (debugNewCanvasSaveCount > debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.save() or canvas.saveLayer() at least '
            '${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount} more '
            'time${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.restore().',
          ),
          ErrorDescription(
              'This leaves the canvas in an inconsistent state and will probably result in a broken display.'),
          ErrorHint('You must pair each call to save()/saveLayer() with a later matching call to restore().'),
        ]);
      }
      if (debugNewCanvasSaveCount < debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'The $painter custom painter called canvas.restore() '
            '${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount} more '
            'time${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount == 1 ? '' : 's'} '
            'than it called canvas.save() or canvas.saveLayer().',
          ),
          ErrorDescription('This leaves the canvas in an inconsistent state and will result in a broken display.'),
          ErrorHint('You should only call restore() if you first called save() or saveLayer().'),
        ]);
      }
      return debugNewCanvasSaveCount == debugPreviousCanvasSaveCount;
    }());
    canvas.restore();
  }

  void _setRasterCacheHints(PaintingContext context) {
    if (isComplex) {
      context.setIsComplexHint();
    }
    if (willChange) {
      context.setWillChangeHint();
    }
  }
}

class PopupArrowPainter extends CustomPainter {
  final Color fillColor;
  final Size arrowSize;
  final PopupArrowPosition arrowPosition;
  final Offset? origin;
  final BorderRadius? borderRadius;
  final bool autoRightAngle;
  final Gradient? gradient;
  final double? flatWidth;

  PopupArrowPainter({
    this.fillColor = const Color(0xFFFFF7F5),
    this.arrowSize = const Size(16, 8),
    this.arrowPosition = PopupArrowPosition.bottomCenter,
    this.origin,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.autoRightAngle = false,
    this.gradient,
    this.flatWidth,
  });

  PopupArrowPainter.rightAngle({
    this.fillColor = const Color(0xFFFFF7F5),
    this.arrowSize = const Size(8, 8),
    this.arrowPosition = PopupArrowPosition.bottomCenter,
    this.origin,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.gradient,
    this.flatWidth,
  }) : autoRightAngle = true;

  bool get isFlatArrow => flatWidth != null && flatWidth! > 0;

  @override
  void paint(Canvas canvas, Size size) {
    final contentY = arrowPosition.isTop ? arrowSize.height : 0.0;
    double left = 0.0;
    double top = contentY;
    if (origin != null) {
      left = origin!.dx;
      top += origin!.dy;
    }
    final contentH = size.height - arrowSize.height;
    final Rect contentRect = Rect.fromLTWH(left, top, size.width, contentH);
    final rect = (origin ?? const Offset(0, 0)) & size;
    _drawContent(canvas, contentRect, rect);
  }

  void _drawContent(Canvas canvas, Rect contentRect, Rect rect) {
    Path path = Path();
    BorderRadius radius = borderRadius ?? BorderRadius.zero;
    final position = arrowPosition;
    if (autoRightAngle) {
      if (position.isTopLeft) {
        radius = radius.copyWith(topLeft: Radius.zero);
      } else if (position.isTopRight) {
        radius = radius.copyWith(topRight: Radius.zero);
      } else if (position.isBottomLeft) {
        radius = radius.copyWith(bottomLeft: Radius.zero);
      } else if (position.isBottomRight) {
        radius = radius.copyWith(bottomRight: Radius.zero);
      }
    }

    // 四个角的圆角矩形
    final Rect arcTopLeftRect = Rect.fromLTWH(
      contentRect.left,
      contentRect.top,
      radius.topLeft.x,
      radius.topLeft.y,
    );
    final Rect arcTopRightRect = Rect.fromLTWH(
      contentRect.right - radius.topRight.x,
      contentRect.top,
      radius.topRight.x,
      radius.topRight.y,
    );
    final Rect arcBottomLeftRect = Rect.fromLTWH(
      contentRect.left,
      contentRect.bottom - radius.bottomLeft.y,
      radius.bottomLeft.x,
      radius.bottomLeft.y,
    );
    final Rect arcBottomRightRect = Rect.fromLTWH(
      contentRect.right - radius.bottomRight.x,
      contentRect.bottom - radius.bottomRight.y,
      radius.bottomRight.x,
      radius.bottomRight.y,
    );

    double arrowWidth = arrowSize.width;
    if (autoRightAngle && position.isCorner) {
      arrowWidth = arrowWidth / 2;
    }

    final double arrowStartX;
    switch (position) {
      case PopupArrowPosition.topLeft:
        arrowStartX = arcTopLeftRect.right;
        break;
      case PopupArrowPosition.topCenter:
        arrowStartX = contentRect.size.width / 2 - arrowWidth / 2;
        break;
      case PopupArrowPosition.topRight:
        arrowStartX = arcTopRightRect.left - arrowWidth;
        break;
      case PopupArrowPosition.bottomLeft:
        arrowStartX = arcBottomLeftRect.right;
        break;
      case PopupArrowPosition.bottomRight:
        arrowStartX = arcBottomRightRect.left - arrowWidth;
        break;
      case PopupArrowPosition.bottomCenter:
        arrowStartX = contentRect.left + contentRect.size.width / 2 - arrowWidth / 2;
        break;
    }
    final arrowEndX = arrowStartX + arrowWidth;
    final double arrowY = (position.isTop ? 0.0 : rect.height) + rect.top;
    // final Offset arrowTopPosition;
    final Offset arrowTopStartPosition;
    final Offset? arrowTopEndPosition;
    final flatWidth = isFlatArrow ? this.flatWidth! : 0.0;
    // final offset = 5.0;
    if (autoRightAngle) {
      // 直角
      if (position.isLeft) {
        arrowTopStartPosition = Offset(arrowStartX, arrowY);
        arrowTopEndPosition = Offset(arrowStartX + flatWidth, arrowY);
      } else if (position.isRight) {
        arrowTopStartPosition = Offset(arrowEndX, arrowY);
        arrowTopEndPosition = Offset(arrowEndX - flatWidth, arrowY);
      } else {
        arrowTopStartPosition = Offset(arrowStartX + arrowWidth / 2 - flatWidth / 2, arrowY);
        arrowTopEndPosition = Offset(arrowTopStartPosition.dx + flatWidth, arrowTopStartPosition.dy);
      }
    } else {
      // arrowTopLeftPosition = Offset(arrowStartX + arrowWidth / 2, arrowY);
      final start = Offset(arrowStartX + arrowWidth / 2 - flatWidth / 2, arrowY);
      final end = Offset(start.dx + flatWidth, start.dy);
      if (position.isBottom) {
        arrowTopEndPosition = start;
        arrowTopStartPosition = end;
      } else {
        arrowTopStartPosition = start;
        arrowTopEndPosition = end;
      }
    }
    final lineTop = contentRect.top;
    path.moveTo(arcTopLeftRect.right, lineTop);
    final isFlatten = flatWidth >= 0;
    if (position.isTop) {
      // 三角形
      path
        ..lineTo(arrowStartX, lineTop)
        ..lineTo(arrowTopStartPosition.dx, arrowTopStartPosition.dy);
      if (isFlatten) {
        path.lineTo(arrowTopEndPosition.dx, arrowTopEndPosition.dy);
      }
      path.lineTo(arrowEndX, lineTop);
    }

    path
      ..lineTo(arcTopRightRect.left, lineTop)
      ..arcTo(arcTopRightRect, -90 * pi / 180, 90 * pi / 180, false) // 右上角圆角
      ..lineTo(arcBottomRightRect.right, arcBottomRightRect.top);

    path.arcTo(arcBottomRightRect, 0, 90 * pi / 180, false);

    final lineBottomY = contentRect.bottom;

    if (position.isBottom) {
      // 底部三角形
      path
        ..lineTo(arrowEndX, lineBottomY)
        // ..lineTo(arrowTopPosition.dx, arrowTopPosition.dy)
        ..lineTo(arrowTopStartPosition.dx, arrowTopStartPosition.dy);
      if (isFlatten) {
        path.lineTo(arrowTopEndPosition.dx, arrowTopEndPosition.dy);
      }
      path.lineTo(arrowStartX, lineBottomY);
    }

    path
      ..lineTo(arcBottomLeftRect.right, lineBottomY)
      ..arcTo(arcBottomLeftRect, 90 * pi / 180, 90 * pi / 180, false)
      ..lineTo(arcTopLeftRect.left, arcTopLeftRect.bottom)
      ..arcTo(arcTopLeftRect, 180 * pi / 180, 90 * pi / 180, false);

    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..color = fillColor
      ..isAntiAlias = true;
    if (gradient != null) {
      paint.shader = gradient!.createShader(rect);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

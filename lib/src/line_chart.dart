import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_flutter/src/popup_arrow.dart';

class DJChartPointData {
  final num yValue;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final String? text;

  String get yValueDesc => text ?? '$yValue';

  TextStyle get style =>
      textStyle ?? const TextStyle(color: Colors.white, fontSize: 12);

  DJChartPointData({
    required this.yValue,
    required this.backgroundColor,
    this.textStyle,
    this.text,
  });
}

/// 坐标系刻度
class AxisTickMark {
  // final num value;
  final String text;
  final TextStyle? style;

  // String get desc => text ?? '$value';
  String get desc => text ?? '';

  AxisTickMark({
    // required this.value,
    required this.text,
    this.style,
  });
}

class DJLineChart extends StatelessWidget {
  const DJLineChart({
    Key? key,
    required this.points,
    required this.xAxisMarks,
    required this.yAxisMarks,
    required this.xDesc,
    required this.yDesc,
    required this.yGap,
    this.tickNumEqualMarks = false,
  }) : super(key: key);
  final List<DJChartPointData> points;
  final List<AxisTickMark> xAxisMarks;
  final List<AxisTickMark> yAxisMarks;
  final String xDesc;
  final String yDesc;
  final num yGap;
  final bool tickNumEqualMarks;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(300, 200),
        painter: _DJLineChartPainter(
          points: points,
          xAxisMarks: xAxisMarks,
          yAxisMarks: yAxisMarks,
          xDesc: xDesc,
          yDesc: yDesc,
          yGap: yGap,
          tickNumEqualMarks: tickNumEqualMarks,
        ),
      ),
    );
  }
}

class _DJLineChartPainter extends CustomPainter {
  _DJLineChartPainter({
    required this.xAxisMarks,
    required this.yAxisMarks,
    required this.points,
    required this.xDesc,
    required this.yDesc,
    this.xAxisColor = const Color(0xFFE3E4E5),
    this.yAxisColor = const Color(0xFFE3E4E5),
    this.axisLineWidth = 0.5,
    this.yAxisStyle =
        const TextStyle(color: const Color(0xFF000000), fontSize: 11),
    this.xAxisStyle =
        const TextStyle(color: const Color(0xFF000000), fontSize: 11),
    TextStyle? xDescStyle,
    TextStyle? yDescStyle,
    this.lineWidth = 4,
    required this.yGap,
    this.tickNumEqualMarks = false,
  })  : xDescStyle = xDescStyle ?? yAxisStyle,
        yDescStyle = yDescStyle ?? yAxisStyle;

  final List<AxisTickMark> xAxisMarks;
  final List<AxisTickMark> yAxisMarks;

  final List<DJChartPointData> points;
  final double axisLineWidth;
  final Color xAxisColor;
  final Color yAxisColor;
  final TextStyle yAxisStyle;
  final TextStyle xAxisStyle;
  final String xDesc;
  final String yDesc;
  final TextStyle xDescStyle;
  final TextStyle yDescStyle;
  final double lineWidth;
  final num yGap;

// x轴的刻度数量是否等于x轴的文本
  final bool tickNumEqualMarks;

  Paint get xAxisPaint => Paint()
    ..strokeWidth = axisLineWidth
    ..color = xAxisColor;

  Paint get yAxisPaint => Paint()
    ..strokeWidth = axisLineWidth
    ..color = yAxisColor;

  /// x轴刻度的高度
  final double _xTickHeight = 4.0;

  // x轴文本的最大高度
  final double _xTextMaxHeight = 30.0;

  // y轴文本的宽度
  final double _yTextWidth = 40.0;

  /// y轴顶部超出x轴横线的高度
  final double _yOverXMaxHeight = 20.0;
  final _arrowSize = const Size(16, 6);
  final _pointDataRadius = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final left = _yTextWidth;
    // y轴线条距离顶部的间距
    final top = 20.0;
    final right = size.width;
    final bottom = size.height - _xTextMaxHeight - _xTickHeight;

    final coordinateRect = Rect.fromLTRB(left, top, right, bottom);

    final tickH = _drawXAxis(canvas, coordinateRect);
    final xOffsets = _drawYAxis(canvas, coordinateRect);
    assert(xOffsets.length >= points.length, 'x轴坐标的刻度数量应该大于点的数量');
    if (points.isNotEmpty) {
      final pointCoordinates = _convertDataToCoordinate(
        coordinateRect,
        xOffsets,
        tickH: tickH,
        gap: yGap,
        dataList: points,
      );
      _drawValues(canvas, coordinateRect, pointCoordinates, points);
    }
  }

  /// 画数据
  void _drawValues(
    Canvas canvas,
    Rect coordinateRect,
    List<Offset> pointCoordinates,
    List<DJChartPointData> points,
  ) {
    // 画折线
    _renderLine(canvas, coordinateRect, pointCoordinates, points);
    // 画数据
    _renderPointData(canvas, pointCoordinates, points);
    // 画点
    _renderDataDot(canvas, pointCoordinates, points);
  }

  void _renderLine(Canvas canvas, Rect coordinateRect,
      List<Offset> pointCoordinates, List<DJChartPointData> dataList) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    Offset lastOffset = Offset(coordinateRect.left, coordinateRect.bottom);
    for (int i = 0; i < pointCoordinates.length; i++) {
      final offset = pointCoordinates[i];
      final point = points[i];
      if (i == 0) {
        linePaint.color = point.backgroundColor;
      } else {
        linePaint.color = points[i - 1].backgroundColor;
      }
      canvas.drawLine(lastOffset, offset, linePaint);
      lastOffset = offset;
    }
  }

  void _renderDataDot(Canvas canvas, List<Offset> pointCoordinates,
      List<DJChartPointData> dataList) {
    const strokeWidth = 2.0;
    final Paint innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final Paint outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const double radius = 6;
    for (int i = 0; i < pointCoordinates.length; i++) {
      final offset = pointCoordinates[i];
      final data = dataList[i];
      outerPaint.color = data.backgroundColor;
      canvas.drawCircle(offset, radius, innerPaint);
      canvas.drawCircle(offset, radius, outerPaint);
    }
  }

  // 计算数据容器的大小
  List _calcPointDataSize(DJChartPointData data) {
    final minW = max(_arrowSize.width + 2 * _pointDataRadius, 40.0);
    final text = data.yValueDesc;
    final textPainter = _buildTextPainter(text, data.style);
    final textW = textPainter.width;
    final size = Size(max(textW + _pointDataRadius, minW), 30);
    return [size, textPainter];
  }

  void _renderPointData(Canvas canvas, List<Offset> pointCoordinates,
      List<DJChartPointData> dataList) {
    const space = 10.0; // 箭头距离dot的间距

    for (int i = 0; i < pointCoordinates.length; i++) {
      final position = pointCoordinates[i];
      final data = points[i];
      final tuple = _calcPointDataSize(data);
      final textPainter = tuple.last as TextPainter;
      final _size = tuple.first as Size;
      final textW = textPainter.width;
      final y = position.dy - space - _size.height;
      final x = position.dx - _size.width / 2;
      final origin = Offset(x, y);

      PopupArrowPainter(
        origin: origin,
        arrowSize: _arrowSize,
        fillColor: data.backgroundColor,
        borderRadius: BorderRadius.circular(_pointDataRadius),
      ).paint(canvas, _size);

      final Offset center = (origin & _size).center;
      final h = textPainter.size.height;
      final dx = center.dx - textW / 2;
      final dy = center.dy - h / 2 - _arrowSize.height / 2;
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  // 将数据转为坐标
  List<Offset> _convertDataToCoordinate(
      Rect coordinateRect, List<double> xOffsets,
      {required double tickH,
      required num gap,
      required List<DJChartPointData> dataList}) {
    final maxY = coordinateRect.bottom;
    return dataList.mapIndexed((index, e) {
      final x = xOffsets[index];
      final v = (e.yValue / gap) * tickH;
      final y = maxY - v;
      return Offset(x, y);
    }).toList();
  }

  double _drawXAxis(Canvas canvas, Rect coordinateRect) {
    final xPaint = xAxisPaint;
    double startY = coordinateRect.bottom;
    final totalH = coordinateRect.height - _yOverXMaxHeight;
    final lineNum = yAxisMarks.length;
    final tick = totalH / (lineNum - 1);
    final startX = coordinateRect.left;
    final endX = coordinateRect.right;
    for (int i = 0; i < lineNum; i++) {
      final p1 = Offset(startX, startY);
      final p2 = Offset(endX, startY);
      final mark = yAxisMarks[i];

      _drawYAxisText(canvas, startY, mark.desc, coordinateRect);

      startY = startY - tick;

      canvas.drawLine(p1, p2, xPaint);
    }
    _drawYDesc(canvas, coordinateRect);

    return tick;
  }

  void _drawYDesc(Canvas canvas, Rect coordinateRect) {
    _drawYText(canvas, yDesc, yDescStyle, coordinateRect,
        dyCb: (h) => max(coordinateRect.top - h, .0));
  }

  TextPainter _buildTextPainter(String desc, TextStyle style) {
    return TextPainter(
        text: TextSpan(text: desc, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout();
  }

  void _drawYText(
    Canvas canvas,
    String desc,
    TextStyle style,
    Rect coordinateRect, {
    required double Function(double textH) dyCb,
  }) {
    final textPainter = _buildTextPainter(desc, style);
    final left = coordinateRect.left;
    final textW = textPainter.width;
    final double dx = max((left - textW) / 2, .0);
    final dy = dyCb.call(textPainter.size.height);
    textPainter.paint(canvas, Offset(dx, dy));
  }

  void _drawYAxisText(
      Canvas canvas, double startY, String desc, Rect coordinateRect) {
    _drawYText(canvas, desc, yAxisStyle, coordinateRect,
        dyCb: (h) => startY - h / 2);
  }

  List<double> _drawYAxis(Canvas canvas, Rect coordinateRect) {
    double startY = coordinateRect.top;
    double startX = coordinateRect.left;
    final endY = coordinateRect.bottom + _xTickHeight;
    Offset p1 = Offset(startX, startY);
    Offset p2 = Offset(startX, endY);
    canvas.drawLine(p1, p2, yAxisPaint);
    // right
    startX = coordinateRect.right;
    p1 = Offset(startX, startY);
    p2 = Offset(startX, endY);
    canvas.drawLine(p1, p2, yAxisPaint);

    void renderText(TextPainter textPainter, double centerX) {
      final h = textPainter.size.height;
      final double space = max((_xTextMaxHeight - h) / 2, 0);
      final textW = textPainter.width;
      final dy = endY + space;
      final half = textW / 2;
      final double dx = centerX > half ? centerX - half : .0;
      textPainter.paint(canvas, Offset(dx, dy));
    }

    // 画字
    void _drawText(String desc, TextStyle style, double centerX) {
      final textPainter = _buildTextPainter(desc, style);
      renderText(textPainter, centerX);
    }

    final List<TextPainter> textPainterList = xAxisMarks
        .map((e) => _buildTextPainter(e.desc, e.style ?? xDescStyle))
        .toList();

    // tick
    final tickNum =
        tickNumEqualMarks ? xAxisMarks.length : xAxisMarks.length + 1;
    final lastDataWidth = points.isEmpty
        ? 0.0
        : (_calcPointDataSize(points.last).first as Size).width;
    final lastMarkWidth = textPainterList.last.width;

    final minRight = max((lastDataWidth / 2 + 8), 30.0);
    final right = max(minRight, lastMarkWidth / 2);
    final tickWidth = (coordinateRect.width - right) / tickNum;
    startY = coordinateRect.bottom;
    startX = coordinateRect.left;
    for (int i = 0; i < tickNum; i++) {
      startX = startX + tickWidth;
      final p1 = Offset(startX, startY);
      final p2 = Offset(startX, endY);
      canvas.drawLine(p1, p2, yAxisPaint);
    }
    // 画单位
    _drawText(xDesc, xDescStyle, coordinateRect.left);

    double centerX = coordinateRect.left;
    final List<double> xTextOffsets = [];
    for (int i = 0; i < textPainterList.length; i++) {
      centerX = centerX + tickWidth;
      final double x;
      if (i == 0) {
        x = centerX;
      } else if (i == xAxisMarks.length - 1) {
        // 最后一个
        x = startX;
      } else {
        x = tickNumEqualMarks ? centerX : centerX + tickWidth / 2;
      }
      final textPainter = textPainterList[i];
      renderText(textPainter, x);
      xTextOffsets.add(x);
    }
    return xTextOffsets;
  }

  @override
  bool shouldRepaint(covariant _DJLineChartPainter oldDelegate) {
    return tickNumEqualMarks != oldDelegate.tickNumEqualMarks ||
        xAxisMarks != oldDelegate.xAxisMarks ||
        yAxisMarks != oldDelegate.yAxisMarks ||
        points != oldDelegate.points ||
        axisLineWidth != oldDelegate.axisLineWidth ||
        xAxisColor != oldDelegate.xAxisColor ||
        yAxisColor != oldDelegate.yAxisColor ||
        yAxisStyle != oldDelegate.yAxisStyle ||
        xAxisStyle != oldDelegate.xAxisStyle ||
        xDesc != oldDelegate.xDesc ||
        yDesc != oldDelegate.yDesc ||
        xDescStyle != oldDelegate.xDescStyle ||
        yDescStyle != oldDelegate.yDescStyle ||
        lineWidth != oldDelegate.lineWidth ||
        yGap != oldDelegate.yGap;
  }
}

extension _IterableMapIndexed<E> on Iterable<E> {
  /// Returns a new lazy [Iterable] containing the results of applying the
  /// given [transform] function to each element and its index in the original
  /// collection.
  Iterable<R> mapIndexed<R>(R Function(int index, E) transform) sync* {
    var index = 0;
    for (final element in this) {
      yield transform(index++, element);
    }
  }
}

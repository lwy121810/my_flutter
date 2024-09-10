import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DJSlider extends StatefulWidget {
  const DJSlider({
    Key? key,
    required this.imageProvider,
    this.defaultValue,
    this.onChanged,
    this.sideWidth = 1,
    this.thumbSize = const Size(24, 24),
    this.activeColor = const Color(0xFFFF3200),
    this.inactiveColor = const Color(0xFFE5E5E5),
  }) : super(key: key);
  final ImageProvider imageProvider;
  final double? defaultValue;
  final ValueChanged<double>? onChanged;
  final Size thumbSize;
  final Color activeColor;
  final Color inactiveColor;
  final double? sideWidth;

  @override
  State<DJSlider> createState() => _DJSliderState();
}

class _DJSliderState extends State<DJSlider> {
  double _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null) {
      _sliderValue = widget.defaultValue!;
    }
  }

  @override
  void didUpdateWidget(covariant DJSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != null) {
      _sliderValue = widget.defaultValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AssertsImageBuilder(widget.imageProvider, builder: (context, imageInfo) {
      return SliderTheme(
          // overlayShape, //滑块按下的浮层显示
          // tickMarkShape, //单滑块的刻度
          // thumbShape, //单滑块的按钮
          // trackShape, //单滑块的轨道
          // valueIndicatorShape, //单滑块指示器
          data: SliderThemeData(
            trackHeight: 10,
            thumbShape: imageInfo?.image == null
                ? RoundSliderThumbShape(enabledThumbRadius: widget.thumbSize.width / 2)
                : DJImageSliderThumbShape(image: imageInfo!.image, size: widget.thumbSize),

            trackShape: DJRectangularSliderTrackShape(sideWidth: widget.sideWidth),

            // trackShape: TDRoundedRectSliderTrackShape(),
            // tickMarkShape: RoundSliderTickMarkShape(),
            // tickMarkShape: TDRoundSliderTickMarkShape(
            //   themeData:  TDSliderThemeData.capsule()
            // ),
            overlayShape: SliderComponentShape.noOverlay,
            // valueIndicatorShape:PaddleSliderValueIndicatorShape(),
            valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
          ),
          child: Slider(
              value: _sliderValue,
              activeColor: widget.activeColor,
              inactiveColor: widget.inactiveColor,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
                widget.onChanged?.call(value);
              }));
    });
  }
}

class DJImageSliderThumbShape extends SliderComponentShape {
  final ui.Image image;
  final Size size;

  const DJImageSliderThumbShape({required this.image, required this.size});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return size;
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final canvas = context.canvas;
    final offset = Offset(0, 0);
    final paint = Paint()..isAntiAlias = true;
    // canvas.drawImage(image, offset, paint);

    final dx = size.width / 2;
    final dy = size.height / 2;
    final src = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());

    final left = center.dx - dx;
    final top = center.dy - dy;
    final right = center.dx + dx;
    final bottom = center.dy + dy;
    final dst = Rect.fromLTRB(left, top, right, bottom);

    canvas.drawImageRect(image, src, dst, paint);
    // canvas.drawImageNine(image, center, dst, paint)
  }
}

typedef AssertsWidgetBuilder = Widget Function(BuildContext context, ImageInfo? imageInfo);

class AssertsImageBuilder extends StatefulWidget {
  final ImageProvider imageProvider;
  final AssertsWidgetBuilder builder;

  const AssertsImageBuilder(
    this.imageProvider, {
    Key? key,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _AssertsImageBuilderState();
}

class _AssertsImageBuilderState extends State<AssertsImageBuilder> {
  ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _loadAssertsImage().then((value) {
      setState(() {
        _imageInfo = value;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AssertsImageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageProvider != widget.imageProvider) {
      _loadAssertsImage().then((value) {
        setState(() {
          _imageInfo = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder!.call(context, _imageInfo);
  }

  Future<ImageInfo?> _loadAssertsImage() {
    final Completer<ImageInfo?> completer = Completer<ImageInfo?>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ImageConfiguration config = createLocalImageConfiguration(context);
      final ImageStream stream = widget.imageProvider.resolve(config);
      ImageStreamListener? listener;
      listener = ImageStreamListener(
        (ImageInfo? image, bool sync) {
          if (!completer.isCompleted) {
            completer.complete(image);
          }

          SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
            stream.removeListener(listener!);
          });
        },
        onError: (Object exception, StackTrace? stackTrace) {
          stream.removeListener(listener!);
          completer.completeError(exception, stackTrace);
        },
      );
      stream.addListener(listener);
    });

    return completer.future;
  }
}

class DJRectangularSliderTrackShape extends RectangularSliderTrackShape {
  final double? sideWidth;

  DJRectangularSliderTrackShape({this.sideWidth});

  @override
  void paint(PaintingContext context, ui.Offset offset,
      {required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required ui.TextDirection textDirection,
      required ui.Offset thumbCenter,
      ui.Offset? secondaryOffset,
      bool isDiscrete = false,
      bool isEnabled = false}) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween =
        ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
        ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint;
    final Paint rightTrackPaint;
    final Paint leftSidePaint;
    final Paint rightSidePaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        leftSidePaint = activePaint;
        rightSidePaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        leftSidePaint = inactivePaint;
        rightSidePaint = activePaint;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    if (!leftTrackSegment.isEmpty) {
      context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    }
    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);
    if (!rightTrackSegment.isEmpty) {
      context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
    }

    final bool showSecondaryTrack = (secondaryOffset != null) &&
        ((textDirection == TextDirection.ltr)
            ? (secondaryOffset.dx > thumbCenter.dx)
            : (secondaryOffset.dx < thumbCenter.dx));

    if (showSecondaryTrack) {
      final ColorTween secondaryTrackColorTween =
          ColorTween(begin: sliderTheme.disabledSecondaryActiveTrackColor, end: sliderTheme.secondaryActiveTrackColor);
      final Paint secondaryTrackPaint = Paint()..color = secondaryTrackColorTween.evaluate(enableAnimation)!;
      final Rect secondaryTrackSegment = Rect.fromLTRB(
        (textDirection == TextDirection.ltr) ? thumbCenter.dx : secondaryOffset.dx,
        trackRect.top,
        (textDirection == TextDirection.ltr) ? secondaryOffset.dx : thumbCenter.dx,
        trackRect.bottom,
      );
      if (!secondaryTrackSegment.isEmpty) {
        context.canvas.drawRect(secondaryTrackSegment, secondaryTrackPaint);
      }
    }

    final double thumbHeight = sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete).height;
    final double trackHeight = trackRect.height;

    if (sideWidth != null && sideWidth! > 0) {
      final strokeWidth = sideWidth!;
      leftSidePaint.strokeWidth = strokeWidth;
      rightSidePaint.strokeWidth = strokeWidth;

      double left = trackRect.left + strokeWidth / 2;
      final maxY = math.max(thumbHeight, trackHeight); // startY + thumbHeight / 2 - trackHeight/2
      final startY = math.min(trackRect.bottom, thumbHeight);

      Offset p1 = Offset(left, startY);
      Offset p2 = Offset(left, maxY);
      context.canvas.drawLine(p1, p2, leftSidePaint);

      left = trackRect.right - strokeWidth / 2;
      p1 = Offset(left, startY);
      p2 = Offset(left, maxY);
      context.canvas.drawLine(p1, p2, rightSidePaint);
    }
  }
}

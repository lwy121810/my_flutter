import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// [childSize] 当前child的大小
/// [previousChildRect] 前一个child的rect
/// [index] 当前child所在的下标
/// [constraints] 组件本身的约束
typedef ManualLayoutChildCallBack = Offset Function(
  Size childSize,
  Rect? previousChildRect,
  int index,
  BoxConstraints constraints,
);

/// 手动布局children
/// [layoutChild] 返回对应child的位置
class ManualLayoutWidget extends MultiChildRenderObjectWidget {
  final ManualLayoutChildCallBack layoutChild;

  /// 可以通过该对象拿到组件布局之后的 offset size rect 等信息
  final ValueSetter<ManualRenderBox>? afterLayout;

  const ManualLayoutWidget({
    Key? key,
    required this.layoutChild,
    this.afterLayout,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ManualRenderBox(
      layoutChild: layoutChild,
      afterLayout: afterLayout,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant ManualRenderBox renderObject) {
    renderObject
      ..afterLayout = afterLayout
      ..layoutChild = layoutChild;
  }
}

class _ManualRenderParentData extends ContainerBoxParentData<RenderBox> {}

class ManualRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ManualRenderParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ManualRenderParentData> {
  ManualRenderBox({
    List<RenderBox>? children,
    required ManualLayoutChildCallBack layoutChild,
    this.afterLayout,
  }) : _layoutChild = layoutChild {
    addAll(children);
  }

  ManualLayoutChildCallBack _layoutChild;

  set layoutChild(ManualLayoutChildCallBack layoutChild) {
    assert(layoutChild != null);
    if (_layoutChild == layoutChild) return;
    _layoutChild = layoutChild;
    markNeedsLayout();
  }

  ValueSetter<ManualRenderBox>? afterLayout;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ManualRenderParentData) {
      child.parentData = _ManualRenderParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    final constraints = this.constraints;

    if (child == null) {
      size = constraints.smallest;
      return;
    }

    Rect? previousChildRect;

    final BoxConstraints childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);

    double maxX = .0;
    double maxY = .0;
    int index = 0;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final childSize = child.size;
      final childParentData = child.parentData as _ManualRenderParentData;

      final offset = _layoutChild(childSize, previousChildRect, index, constraints);

      childParentData.offset = offset;

      previousChildRect = offset & childSize;

      maxX = math.max(maxX, previousChildRect.right);
      maxY = math.max(maxY, previousChildRect.bottom);

      child = childParentData.nextSibling;
      index = index + 1;
    }

    size = constraints.constrain(Size(constraints.maxWidth, maxY));

    _callBack();
  }

  _callBack() {
    // 不能直接回调callback，原因是当前组件布局完成后可能还有其它组件未完成布局,
    // 如果callback中又触发了UI更新（比如调用了 setState）则会报错。因此，我们
    // 在 frame 结束的时候再去触发回调。
    // callback(this);
    if (afterLayout != null) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) => afterLayout!(this));
    }
  }

  /// 组件在在屏幕坐标中的起始偏移坐标
  Offset get offset => localToGlobal(Offset.zero);

  /// 组件在屏幕上占有的矩形空间区域
  Rect get rect => offset & size;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class LimitedWrap extends MultiChildRenderObjectWidget {
  final double spacing;
  final double runSpacing;
  final int maxLine;

  final ValueSetter<LimitRenderWrap>? afterLayout;

  LimitedWrap({
    Key? key,
    this.maxLine = 0,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    List<Widget> children = const <Widget>[],
    this.afterLayout,
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return LimitRenderWrap(
      maxLine: maxLine,
      runSpacing: runSpacing,
      spacing: spacing,
      afterLayout: afterLayout,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant LimitRenderWrap renderObject) {
    renderObject
      ..spacing = spacing
      ..runSpacing = runSpacing
      ..maxLine = maxLine
      ..afterLayout = afterLayout;
  }
}

class _LimitedWrapParentData extends ContainerBoxParentData<RenderBox> {
  bool _limit = false;
}

class LimitRenderWrap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LimitedWrapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LimitedWrapParentData> {
  LimitRenderWrap({
    int maxLine = 0,
    double spacing = 0.0,
    double runSpacing = 0.0,
    List<RenderBox>? children,
    this.afterLayout,
  })  : _maxLine = maxLine,
        _spacing = spacing,
        _runSpacing = spacing {
    addAll(children);
  }

  ValueSetter<LimitRenderWrap>? afterLayout;

  int get maxLine => _maxLine;
  int _maxLine;

  set maxLine(int value) {
    assert(value != null);
    if (_maxLine == value) return;
    _maxLine = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;

  set spacing(double value) {
    assert(value != null);
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  double get runSpacing => _runSpacing;
  double _runSpacing;

  set runSpacing(double value) {
    assert(value != null);
    if (_runSpacing == value) return;
    _runSpacing = value;
    markNeedsLayout();
  }

  // 显示的子元素的数量
  int get displayChildCount => _displayChildCount;
  int _displayChildCount = 0;

  // 显示的行数
  int get displayLineCount => _displayLineCount;
  int _displayLineCount = 0;

  Offset get offset => localToGlobal(Offset.zero);

  Rect get rect => offset & size;

  // 剩余没有显示的子节点个数
  int get remainChildCount => childCount - displayChildCount;

  // 对不显示的子组件布局
  void _layoutRemainChildren(
      RenderBox? widget, BoxConstraints childConstraints) {
    RenderBox? child = widget;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final childParentData = child.parentData as _LimitedWrapParentData;
      child = childParentData.nextSibling;
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    final constraints = this.constraints;
    _displayChildCount = 0;
    _displayLineCount = 0;

    if (child == null) {
      size = constraints.smallest;
      _callBack();
      return;
    }
    final mainAxisLimit = constraints.maxWidth;
    final spacing = this.spacing;
    final runSpacing = this.runSpacing;
    final maxLine = this.maxLine;
    final BoxConstraints childConstraints =
    BoxConstraints(maxWidth: constraints.maxWidth);
    // 当前显示的是第几行
    int runLine = 0;
    // 当前行子元素的个数
    int childCount = 0;
    // 当前行横向占据的空间
    double runMainAxisExtent = 0.0;
    // 当前行最大的高度
    double runCrossAxisExtent = 0.0;
    // 计算size使用
    // 整个组件横向最大的空间
    double mainAxisExtent = 0.0;
    // 整个组件纵向最大的高度
    double crossAxisExtent = 0.0;

    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final childWidth = child.size.width;
      final childHeight = child.size.height;
      final childParentData = child.parentData as _LimitedWrapParentData;
      if (childCount > 0 &&
          runMainAxisExtent + spacing + childWidth > mainAxisLimit) {
        // 换行
        if (maxLine > 0 && runLine >= maxLine - 1) {
          childParentData._limit = true;
          _layoutRemainChildren(child, childConstraints);
          break;
        }

        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runLine > 0) crossAxisExtent += runSpacing;

        runLine += 1;
        childCount = 0;
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
      }
      // 计算offset
      double dx = runMainAxisExtent;
      double dy = crossAxisExtent;
      if (childCount > 0) dx += spacing;
      if (runLine > 0) dy += runSpacing;
      childParentData.offset = Offset(dx, dy);

      // 记录当前行的最高、最宽
      runMainAxisExtent += childWidth;
      if (childCount > 0) runMainAxisExtent += spacing;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childHeight);

      childCount += 1;
      childParentData._limit = false;
      child = childParentData.nextSibling;
      _displayChildCount += 1;
    } // while done
    // 计算size
    if (childCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runLine > 0) crossAxisExtent += runSpacing;
    }
    // 显示的行数
    _displayLineCount = runLine + 1;
    size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));

    _callBack();
  }

  _callBack() {
    // 不能直接回调callback，原因是当前组件布局完成后可能还有其它组件未完成布局,
    // 如果callback中又触发了UI更新（比如调用了 setState）则会报错。因此，我们
    // 在 frame 结束的时候再去触发回调。
    // callback(this);
    if (afterLayout != null) {
      SchedulerBinding.instance
          .addPostFrameCallback((timeStamp) => afterLayout!(this));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void defaultPaint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    final maxLine = this.maxLine;
    while (child != null) {
      final childParentData = child.parentData as _LimitedWrapParentData;
      if (maxLine > 0 && childParentData._limit) break;
      child.paint(context, offset + childParentData.offset);
      child = childParentData.nextSibling;
    }
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _LimitedWrapParentData) {
      child.parentData = _LimitedWrapParentData();
    }
  }
}

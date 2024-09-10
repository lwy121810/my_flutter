import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class RegionData {
  List<RegionData>? children;
  String? name;

  RegionData({this.children, this.name});
}

enum AddressRegionLevel {
  province,
  city,
  country,
  town,
}

typedef NextLevelDataFetcher = FutureOr<List<RegionData>?> Function(
    RegionData data, int level, int index);

class AddressWidget extends StatefulWidget {
  const AddressWidget({
    super.key,
    required this.province,
    this.fetchNextLevelData,
    this.onFinished,
    this.onChange,
    this.provinceHasAllData = false,
    this.textStyle = const TextStyle(fontSize: 14, color: Colors.black87),
    this.selectedTextStyle = const TextStyle(fontSize: 14, color: Colors.red),
    this.showLoadingWidget = true,
    this.loadingWidget,
    this.showCheckWidget = true,
    this.checkWidget,
    this.cacheData = false,
    this.itemBuilder,
    this.compareRegionData,
    this.indicatorWidth = 10.0,
    this.indicatorHeight = 2.0,
    this.indicatorColor,
    this.regionLevel = AddressRegionLevel.town,
    this.duration = const Duration(milliseconds: 200),
    this.contentPadding = const EdgeInsets.only(left: 10, right: 10),
    this.tabPadding,
    this.tabItemMargin,
    this.tabItemPadding = const EdgeInsets.only(left: 10, right: 10),
    this.tabHeight = 40.0,
  }) : assert(!provinceHasAllData && fetchNextLevelData != null,
            '当provinceHasAllData为false时fetchNextLevelData不能为null');

  /// 获取下一级地区数据
  /// 返回Future认为是异步获取 默认有loading效果
  /// 返回List<RegionData> 认为是同步数据 不会有loading
  /// 如果下级数据为空 应该返回空数组 null认为是请求下级数据失败
  final NextLevelDataFetcher? fetchNextLevelData;

  /// 省级数据
  final List<RegionData> province;

  /// 传入的province是不是所有的数据 如果是全部数据 组件不会再向外界索取下一级地区
  final bool provinceHasAllData;

  /// 选择结束 将选择的数据按照省市区镇的顺序放到result数组中
  final Function(List<RegionData> result)? onFinished;
  final Function(List<RegionData> result)? onChange;

  /// 非选中字体（包括tabBar以及列表）
  final TextStyle textStyle;

  /// 选中的字体（包括tabBar以及列表）
  final TextStyle selectedTextStyle;

  /// 异步获取下级数据时是否显示loading
  final bool showLoadingWidget;
  final bool showCheckWidget;

  /// [showLoadingWidget]为true时有效 loading组件
  final Widget? loadingWidget;

  /// [showCheckWidget]为true时有效 check组件
  final Widget? checkWidget;

  /// 是否缓存数据 true的话会将下级数据缓存到RegionData的children中 再次选择时将不会请求
  final bool cacheData;
  final double indicatorWidth;
  final double indicatorHeight;
  final double tabHeight;
  final Color? indicatorColor;

  /// 选择到哪一级地区
  final AddressRegionLevel regionLevel;
  final Widget Function(RegionData data, bool selected, int level)? itemBuilder;

  /// 比较两个地区是否是同一个 默认使用==判断 外界可以自定义（比如通过code）
  final bool Function(RegionData data, RegionData other)? compareRegionData;

  /// 动画时间
  final Duration duration;
  final EdgeInsets? contentPadding;
  final EdgeInsets? tabPadding;
  final EdgeInsets? tabItemPadding;
  final EdgeInsets? tabItemMargin;

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget>
    with SingleTickerProviderStateMixin {
  List<String> tabs = ['请选择'];
  int _currentTab = 0;
  int? _selectedIndex;
  double _indicatorLeft = 0.0;

  late int regionMaxCount;

  // 正在显示的省市区镇数据列表
  late List<List<RegionData>> regionDataList;

  // 当前选中的地区列表
  late List<RegionData?> _selectedRegions;

  // 当前选中的地区集合
  List<RegionData> get currentSelectedRegion =>
      _selectedRegions.whereType<RegionData>().toList();

  // 当前显示的列表数据
  List<RegionData> get currentList => regionDataList[_currentTab];
  bool isLoading = false;
  double? _defaultIndicatorWidth;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    regionMaxCount = widget.regionLevel.index + 1;
    regionDataList = List.generate(regionMaxCount, (index) => []);
    // 当前选中的地区列表
    _selectedRegions = List.generate(regionMaxCount, (index) => null);

    regionDataList[0] = [...widget.province];
  }

  @override
  void didUpdateWidget(covariant AddressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.regionLevel != oldWidget.regionLevel) {
      regionMaxCount = widget.regionLevel.index + 1;
      regionDataList = List.generate(regionMaxCount, (index) => []);
      // 当前选中的地区列表
      _selectedRegions = List.generate(regionMaxCount, (index) => null);
    }
    if (widget.province != oldWidget.province) {
      regionDataList[0] = [...widget.province];
    }
  }

  Color get indicatorColor => widget.indicatorColor ?? selectedColor;

  Color get selectedColor => widget.selectedTextStyle.color ?? Colors.red;

  double get tabOffset {
    final tabLeft = (widget.tabPadding?.left ?? 0) +
        (widget.tabItemMargin?.left ?? 0) +
        (widget.tabItemPadding?.left ?? 0);
    final tabRight = (widget.tabPadding?.right ?? 0) +
        (widget.tabItemMargin?.right ?? 0) +
        (widget.tabItemPadding?.right ?? 0);
    final offset = (tabRight - tabLeft) / 2;
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(),
        AnimatedContainer(
          duration: widget.duration,
          curve: Curves.ease,
          margin: EdgeInsets.only(left: _indicatorLeft),
          padding: const EdgeInsets.only(),
          color: indicatorColor,
          width: widget.indicatorWidth,
          height: widget.indicatorHeight,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  TextStyle _styleForSelected(bool selected) =>
      selected ? widget.selectedTextStyle : widget.textStyle;

  Widget _buildTabBar() {
    final child = SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: widget.tabPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...tabs.mapIndexed((index, title) => _TabBarItem(
                title: title,
                height: widget.tabHeight,
                padding: widget.tabItemPadding,
                margin: widget.tabItemMargin,
                selected: _currentTab == index,
                style: _styleForSelected(_currentTab == index),
                onPressed: () {
                  _handleTabPressed(index);
                },
              ))
        ],
      ),
    );
    return AfterLayout(
      child: child,
      callback: (val) {
        final width = val.rect.width;
        _defaultIndicatorWidth ??= width;
        final tabW = _defaultIndicatorWidth ?? 52.0;
        final indicatorW = widget.indicatorWidth;
        final left = width - (tabW + indicatorW) / 2 - tabOffset;
        setState(() {
          _indicatorLeft = left;
        });

        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (maxScrollExtent > 0) {
          _scrollController.animateTo(maxScrollExtent,
              duration: widget.duration, curve: Curves.ease);
        }
      },
    );
  }

  Widget _buildContent() {
    return ListView.builder(
        itemCount: currentList.length,
        padding: widget.contentPadding,
        itemBuilder: (_, index) {
          final item = currentList[index];
          final currentItem = _selectedRegions[_currentTab];
          bool selected = false;
          if (currentItem != null) {
            selected = isSameRegion(currentItem, item);
          }
          return InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _clickRegionData(item, index);
            },
            child: widget.itemBuilder?.call(item, selected, _currentTab) ??
                Container(
                  height: 44,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      if (widget.showLoadingWidget && selected && isLoading)
                        widget.loadingWidget ?? defaultLoadingWidget,
                      if (widget.showCheckWidget && selected && !isLoading)
                        widget.checkWidget ?? defaultCheckedWidget,
                      Text(
                        item.name ?? '',
                        textAlign: TextAlign.left,
                        style: _styleForSelected(selected),
                      ),
                    ],
                  ),
                ),
          );
        });
  }

  Widget get defaultLoadingWidget => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(color: selectedColor),
        ),
      );

  Widget get defaultCheckedWidget => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(Icons.check, color: selectedColor, size: 16),
      );

  bool isSameRegion(RegionData regionData, RegionData other) {
    if (widget.compareRegionData != null) {
      return widget.compareRegionData!.call(regionData, other);
    }
    return regionData == other;
  }

  void _handleTabPressed(int index) {
    if (_currentTab == index) return;
    _currentTab = index;
    if (index == tabs.length - 1) return;
    setState(() {
      // 点击的前面的
      tabs.removeRange(index, tabs.length);
      tabs.add('请选择');
      _selectedRegions.fillRange(index + 1, _selectedRegions.length, null);
      regionDataList.fillRange(index + 1, regionDataList.length, []);
    });
    _handleChange();
  }

  void _callBack() {
    widget.onFinished?.call([...currentSelectedRegion]);
    Navigator.of(context).pop();
  }

  void _handleChange() {
    // 通知外界
    widget.onChange?.call([...currentSelectedRegion]);
  }

  void _clickRegionData(RegionData data, int index) async {
    // 保存已选择的数据
    _selectedRegions[_currentTab] = data;
    _handleChange();

    if (_currentTab == regionMaxCount - 1) {
      _callBack();
      return;
    }
    _selectedIndex = index;
    List<RegionData>? resultList;
    // 获取下级数据
    if (widget.provinceHasAllData) {
      resultList = data.children;
    } else {
      final resp = widget.fetchNextLevelData!(data, _currentTab, index);
      if (resp is Future<List<RegionData>?>) {
        final oldTabIndex = _currentTab;
        if (widget.cacheData && data.children != null) {
          // 如果缓存了数据 不用请求
          resultList = data.children;
        } else {
          if (widget.showLoadingWidget) setState(() => isLoading = true);
          resultList = await resp;
          if (widget.showLoadingWidget) setState(() => isLoading = false);
          // resultList为null认为异步出错 外界处理
          if (resultList == null) return;
          if (oldTabIndex != _currentTab) return;
          if (_selectedIndex != index) return;
          if (widget.cacheData) {
            data.children = resultList;
          }
        }
      } else {
        // 同步
        resultList = resp;
      }
    }
    if (resultList == null || resultList.isEmpty) {
      // 最后一级
      _callBack();
      return;
    }
    final newTabs = [...tabs];
    newTabs.insert(tabs.length - 1, data.name!);
    final nextLevel = _currentTab + 1;
    setState(() {
      regionDataList[nextLevel] = resultList!;
      tabs = newTabs;
      _currentTab = nextLevel;
    });
  }
}

class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    super.key,
    required this.title,
    required this.onPressed,
    required this.selected,
    required this.style,
    required this.height,
    this.margin,
    this.padding,
  });

  final String title;
  final VoidCallback onPressed;
  final bool selected;
  final TextStyle style;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        height: height,
        margin: margin,
        padding: padding,
        alignment: Alignment.centerLeft,
        child: Text(title, style: style),
      ),
    );
  }
}

extension IterableMapIndexed<E> on Iterable<E> {
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

typedef AfterLayoutCallback = Function(RenderAfterLayout ral);

/// A widget can retrieve its render object after layout.
///
/// Sometimes we need to do something after the build phase is complete,
/// for example, most of [RenderObject] methods and attributes, such as
/// `renderObject.size`、`renderObject.localToGlobal(...)` only can be used
/// after build.
///
/// Call `setState` in callback is **allowed**, it is safe!
class AfterLayout extends SingleChildRenderObjectWidget {
  const AfterLayout({
    Key? key,
    required this.callback,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAfterLayout(callback);
  }

  @override
  void updateRenderObject(context, RenderAfterLayout renderObject) {
    renderObject.callback = callback;
  }

  /// [callback] will be triggered after the layout phase ends.
  final AfterLayoutCallback callback;
}

class RenderAfterLayout extends RenderProxyBox {
  RenderAfterLayout(this.callback);

  ValueSetter<RenderAfterLayout> callback;

  @override
  void performLayout() {
    super.performLayout();
    // 不能直接回调callback，原因是当前组件布局完成后可能还有其它组件未完成布局,
    // 如果callback中又触发了UI更新（比如调用了 setState）则会报错。因此，我们
    // 在 frame 结束的时候再去触发回调。
    // callback(this);
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) => callback(this));
  }

  /// 组件在在屏幕坐标中的起始偏移坐标
  Offset get offset => localToGlobal(Offset.zero);

  /// 组件在屏幕上占有的矩形空间区域
  Rect get rect => offset & size;
}

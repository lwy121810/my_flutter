import 'package:flutter/material.dart';
import 'package:my_flutter/src/fixed_size_tab_indicator.dart';

class TabIndicatorDemo extends StatelessWidget {
  const TabIndicatorDemo({super.key});

  static const List<Tab> tabs = <Tab>[
    Tab(text: '首页'),
    Tab(text: '名字很长但是指示器固定大小'),
    Tab(text: '资料'),
  ];

  @override
  Widget build(BuildContext context) {
    return const TabControllerExample(tabs: tabs);
  }
}

class TabControllerExample extends StatefulWidget {
  const TabControllerExample({
    required this.tabs,
    super.key,
  });

  final List<Tab> tabs;

  @override
  State<TabControllerExample> createState() => _TabControllerExampleState();
}

class _TabControllerExampleState extends State<TabControllerExample> {
  TabBarIndicatorSize indicatorSize = TabBarIndicatorSize.tab;
  static const List<Tab> fixTabs = <Tab>[
    Tab(text: '固定首页'),
    Tab(text: '名字很长但大小固定'),
    Tab(text: 'fixed size'),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs.length,
      child: DefaultTabControllerListener(
        onTabChanged: (int index) {
          debugPrint('tab changed: $index');
        },
        child: Scaffold(
          appBar: AppBar(
            // title: const Text('固定大小的indicator'),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      final index = indicatorSize.index ^ 1;
                      indicatorSize = TabBarIndicatorSize.values[index];
                    });
                  },
                  child: Text('指示器类型：${indicatorSize.name}'))
            ],
            // bottom: TabBar(
            //   tabs: widget.tabs,
            //   indicatorSize: indicatorSize,
            //   indicator: BoxDecoration(
            //       border: Border(
            //           bottom: BorderSide(
            //     width: 2,
            //     color: Colors.red,
            //   ))),
            //   // indicator: const FixedSizeTabIndicator(),
            // ),
          ),
          body: Column(
            children: [
              TabBar(
                tabs: widget.tabs,
                indicatorSize: indicatorSize,
                indicator: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  width: 4,
                  color: Colors.red,
                ))),
                // indicator: const FixedSizeTabIndicator(),
              ),
              TabBar(
                tabs: fixTabs,
                indicatorSize: indicatorSize,
                indicator: const FixedSizeTabIndicator(),
              ),
              Expanded(
                child: TabBarView(
                  children: widget.tabs.map((Tab tab) {
                    return Center(
                      child: Text(
                        '${tab.text!} Tab',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DefaultTabControllerListener extends StatefulWidget {
  const DefaultTabControllerListener({
    required this.onTabChanged,
    required this.child,
    super.key,
  });

  final ValueChanged<int> onTabChanged;

  final Widget child;

  @override
  State<DefaultTabControllerListener> createState() =>
      _DefaultTabControllerListenerState();
}

class _DefaultTabControllerListenerState
    extends State<DefaultTabControllerListener> {
  TabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final TabController? defaultTabController =
        DefaultTabController.maybeOf(context);

    assert(() {
      if (defaultTabController == null) {
        throw FlutterError(
          'No DefaultTabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.',
        );
      }
      return true;
    }());

    if (defaultTabController != _controller) {
      _controller?.removeListener(_listener);
      _controller = defaultTabController;
      _controller?.addListener(_listener);
    }
  }

  void _listener() {
    final TabController? controller = _controller;

    if (controller == null || controller.indexIsChanging) {
      return;
    }

    widget.onTabChanged(controller.index);
  }

  @override
  void dispose() {
    _controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

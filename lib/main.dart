import 'package:flutter/material.dart';
import 'package:my_flutter/page/limited_wrap_demo.dart';
import 'package:my_flutter/src/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: MyRouter.navigatorKey,
      home: const MyHomePage(title: 'My Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          _buildItem(
            '一个获取行数的Wrap',
            onTap: () =>
                push(child: const LimitedWrapPage(), withScaffold: false),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  void push(
      {required Widget child, bool withScaffold = true, String title = ''}) {
    final page = withScaffold ? PageWrapper(page: child, title: title) : child;
    MyRouter.pushPage(page);
  }
}

class PageWrapper extends StatelessWidget {
  const PageWrapper({super.key, required this.page, required this.title});

  final Widget page;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: page,
    );
  }
}

import 'package:flutter/material.dart';

class MyRouter {
  MyRouter._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get currentContext => navigatorKey.currentContext!;

  static NavigatorState get appNavigatorState => navigatorKey.currentState!;

  static Future<bool> maybePop<T extends Object>([T? result]) {
    return appNavigatorState.maybePop(result);
  }

  static pop<T extends Object>([T? result]) {
    return appNavigatorState.pop();
  }

  static pushPage<T extends Object>(Widget page) {
    return appNavigatorState.push(MaterialPageRoute(builder: (_) => page));
  }
}

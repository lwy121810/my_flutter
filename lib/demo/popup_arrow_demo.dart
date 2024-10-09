import 'package:flutter/material.dart';

import '../src/popup_arrow.dart';

class PopupArrowDemo extends StatelessWidget {
  const PopupArrowDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final size = const Size(80, 40);
    BorderRadius radius = BorderRadius.circular(12);
    // radius = BorderRadius.zero;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PopupArrowDemo'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: _buildWrap(),
        // child: _buildColumn(),
      ),
    );
  }

  Widget _buildColumn() {
    return Column(
      children: children,
    );
  }

  List<Widget> get children {
    final padding = const EdgeInsets.all(10);
    final radius = BorderRadius.circular(10);
    final arrowSize = const Size(30, 15);
    return [
      PopupArrowWidget.rightAngle(
        // size: size,
        // borderRadius: BorderRadius.zero,
        arrowPosition: PopupArrowPosition.bottomRight,
        child: Text('12312341asdasdasd'),
      ),
      PopupArrowWidget.rightAngle(
        // size: size,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
        arrowPosition: PopupArrowPosition.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text('12312341'),
        ),
      ),
      PopupArrowWidget(
        // size: size,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
        arrowPosition: PopupArrowPosition.topCenter,
        child: Container(
          // margin: const EdgeInsets.all(10),
          child: Text('12312341'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.topCenter,
        child: Container(
          padding: padding,
          child: Text('topCenter'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.topLeft,
        child: Container(
          padding: padding,
          child: Text('topLeft'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.topRight,
        size: Size(100, 40),
        arrowSize: arrowSize,
        child: Container(
          padding: padding,
          child: Text('topLeft'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.bottomLeft,
        size: Size(100, 40),
        arrowSize: arrowSize,
        child: Container(
          padding: padding,
          child: Text('topLeft'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.bottomCenter,
        size: Size(100, 40),
        arrowSize: arrowSize,
        child: Container(
          padding: padding,
          child: Text('topLeft'),
        ),
      ),
      PopupArrowWidget(
        borderRadius: radius,
        arrowPosition: PopupArrowPosition.bottomRight,
        size: Size(100, 40),
        arrowSize: arrowSize,
        child: Container(
          padding: padding,
          child: Text('topLeft'),
        ),
      ),
      // PopupArrowWidget(
      //   borderRadius: radius,
      //   arrowPosition: PopupArrowPosition.topRight,
      //   size: Size(100, 40),
      //   arrowSize: arrowSize,
      //   child: Container(
      //     padding: padding,
      //     child: Text('topLeft'),
      //   ),
      // ),
    ];
  }

  Widget _buildWrap() {
    return Wrap(spacing: 10, runSpacing: 20, children: children);
  }
}

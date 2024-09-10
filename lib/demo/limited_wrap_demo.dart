import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter/src/limited_wrap.dart';

class LimitedWrapPage extends StatefulWidget {
  const LimitedWrapPage({Key? key}) : super(key: key);

  @override
  State<LimitedWrapPage> createState() => _LimitedWrapPageState();
}

class _LimitedWrapPageState extends State<LimitedWrapPage> {
  int _counter = 3;
  LimitRenderWrap? _renderWrap;
  int _childCount = 20;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '$_counter');
  }

  List<Widget> _children() {
    Color getRandomColor() {
      Random random = Random();
      return Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      );
    }

    return List.generate(
        _childCount,
        (index) => TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(backgroundColor: getRandomColor()),
              child: Text('$index'),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一个获取行数的wrap'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                hintText: '显示的行数',
                prefixText: '最多显示的行数：',
              ),
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              textInputAction: TextInputAction.done,
              onSubmitted: (val) {
                setState(() {
                  _counter = int.parse(val);
                });
              },
            ),
            LimitedWrap(
              maxLine: _counter,
              children: _children(),
              afterLayout: (val) {
                setState(() {
                  _renderWrap = val;
                });
              },
            ),
            if (_renderWrap != null) Text('''
             size: ${_renderWrap!.size},
             子节点个数：${_renderWrap!.childCount}
             实际显示子节点个数：${_renderWrap!.displayChildCount}
             没有显示的子节点个数：${_renderWrap!.remainChildCount}
             实际显示行数：${_renderWrap!.displayLineCount}
             '''),
          ],
        ),
      ),
      persistentFooterButtons: [
        IconButton(
          onPressed: () {
            setState(() {
              _childCount++;
            });
          },
          icon: const Icon(
            Icons.add,
            color: Colors.blue,
          ),
        ),
        TextButton(
          onPressed: () {
            if (_childCount == 0) return;
            setState(() {
              _childCount--;
            });
          },
          child: const Text('—'),
        ),
      ], // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

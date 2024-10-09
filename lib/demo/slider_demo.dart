import 'package:flutter/material.dart';

import '../src/slider.dart';

class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});

  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _currentSliderPrimaryValue = 0.2;
  double _currentSliderSecondaryValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 10,
        // trackShape: RoundedRectSliderTrackShape(),
        // trackShape: RectangularSliderTrackShape(),
        trackShape: DJRectangularSliderTrackShape(sideWidth: 5),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Slider')),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Slider(
                value: _currentSliderPrimaryValue,
                secondaryTrackValue: _currentSliderSecondaryValue,
                label: _currentSliderPrimaryValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderPrimaryValue = value;
                  });
                },
              ),
              Slider(
                value: _currentSliderSecondaryValue,
                label: _currentSliderSecondaryValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderSecondaryValue = value;
                  });
                },
              ),
              const DJSlider(
                imageProvider: AssetImage('assets/images/icon.jpg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

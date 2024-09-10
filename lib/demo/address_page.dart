import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_flutter/src/address.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AreaModel extends RegionData {
  final String? code;
  // @override
  // final String? name;
  // @override
  // final List<AreaModel>? children;

  AreaModel({this.code, super.name, super.children});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'children': children,
    };
  }

  factory AreaModel.fromJson(Map<String, dynamic> map) {
    return AreaModel(
      code: map['code'],
      name: map['name'] as String,
      children: AreaModel.fromJsonList(map?['children']),
    );
  }

  static List<AreaModel>? fromJsonList(List? list) {
    return list?.map((e) => AreaModel.fromJson(e))?.toList();
  }

  @override
  String toString() {
    return 'AreaModel{code: $code, name: $name}';
  }
}

class AddressDemo extends StatefulWidget {
  const AddressDemo({super.key});

  @override
  State<AddressDemo> createState() => _AddressDemoState();
}

class _AddressDemoState extends State<AddressDemo> {
  String address = '';
  String currentAddress = '';

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  List<AreaModel> allData = [];
  List<RegionData> _currentList = [];

  Future<void> loadJsonData() async {
    String jsonString =
        await rootBundle.loadString('assets/json/pcas-code.json');
    final jsonResponse = json.decode(jsonString);
    allData = AreaModel.fromJsonList(jsonResponse)!;
  }

  void showAddress(BuildContext _) async {
    if (allData.isEmpty) {
      await loadJsonData();
    }
    _currentList = [...allData];
    showModal();
  }

  FutureOr<List<RegionData>?> _handleNextLevelData(
      RegionData data, int level, int index) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentList = data.children ?? [];

    return [..._currentList];
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: AddressWidget(
              province: allData,
              // regionLevel: AddressRegionLevel.city,
              fetchNextLevelData: _handleNextLevelData,
              onChange: (region) {
                setState(() {
                  currentAddress = region.map((e) => e.name).join('-');
                });
              },
              onFinished: (region) {
                setState(() {
                  address = region.map((e) => e.name).join('-');
                });
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('当前选择地址：$currentAddress'),
          Text('地址：$address'),
          TextButton(
            onPressed: () {
              showAddress(context);
            },
            child: const Text('显示'),
          ),
        ],
      ),
    );
  }
}

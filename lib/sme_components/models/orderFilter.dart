import 'package:flutter/material.dart';

final waitOrderNotify = WaitOrderNotify(WaitOrder());

class WaitOrderNotify extends ValueNotifier<WaitOrder> {
  WaitOrderNotify(WaitOrder value) : super(value);

  void onSelectFilter(
    int index,
  ) {
    value.selectIndex = index;
    if (index == 0) {
      value.lastminute = 1440;
    } else if (index == 1) {
      value.lastminute = 15;
    } else if (index == 2) {
      value.lastminute = 30;
    } else if (index == 3) {
      value.lastminute = 60;
    } else if (index == 4) {
      value.lastminute = 1440;
    } else if (index == 5) {
      value.lastminute = 10080;
    } else {
      value.lastminute = 1440;
    }
    notifyListeners();
  }
}

class WaitOrder {
  int lastminute = 1440;
  int selectIndex=0;
}

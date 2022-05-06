import 'package:flutter/material.dart';

final orderCounterNotify = OrderCounterNotify(OrderCounter());

class OrderCounterNotify extends ValueNotifier<OrderCounter> {
  OrderCounterNotify(OrderCounter value) : super(value);

  void onCleanOrderCounter(orderCounterList) {
    value.orderCounter = orderCounterList;
    notifyListeners();
  }

  void discrementCounter(index) {
    if (value.orderCounter[index] == null) {
      null;
    } else if (value.orderCounter[index] == 0) {
      null;
    } else {
      value.orderCounter[index] = value.orderCounter[index] - 1;
    }
    notifyListeners();
  }

  void incrementCounter(index) {
    if (value.orderCounter[index] == null) {
      value.orderCounter[index] = 1;
    } else if (value.orderCounter[index] == 0) {
      value.orderCounter[index] = 1;
    } else {
      value.orderCounter[index] = value.orderCounter[index] + 1;
    }
    notifyListeners();
  }
}

class OrderCounter {
  List orderCounter = List<int>.generate(100, (int index) => 0);
}

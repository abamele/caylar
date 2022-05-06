import 'package:flutter/material.dart';

final showOrderNotify = ShowOrderNotify(ShowOrder());

class ShowOrderNotify extends ValueNotifier<ShowOrder> {
  ShowOrderNotify(ShowOrder value) : super(value);

  void onShowOrder(int index, bool show) {
    value.showOrder[index] = show;
    notifyListeners();
  }

  void onShowOrderComplete(int? index, bool show) {
    value.showOrderComplete[index!] = show;
    notifyListeners();
  }

  void onResetShowOrderComplete() {
    value.showOrderComplete = List<bool>.generate(1000, (int index) => false);
    notifyListeners();
  }

  void onSelectedOrderComplete(int index, bool show) {
    value.selectedOrderComplete[index] = show;
    notifyListeners();
  }

  void onResetSelectedOrderComplete() {
    value.selectedOrderComplete =
        List<bool>.generate(1000, (int index) => false);
    notifyListeners();
  }

  void onOrderIndex(int index) {
    value.showOrderIndex = index;
    notifyListeners();
  }
}

class ShowOrder {
  // late String showOrder = "";
  final List showOrder = List<bool>.generate(1000, (int index) => true);
  List showOrderComplete = List<bool>.generate(1000, (int index) => false);
  int? showOrderIndex;
  List selectedOrderComplete = List<bool>.generate(1000, (int index) => false);
}

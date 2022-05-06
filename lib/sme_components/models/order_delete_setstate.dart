import 'package:flutter/material.dart';

final delOrderSetStateNotify = DelOrderSetStateNotify(DelOrderSetState());

class DelOrderSetStateNotify extends ValueNotifier<DelOrderSetState> {
  DelOrderSetStateNotify(DelOrderSetState value) : super(value);

  void onDelOrderSetState(bool setState) {
    value.delOrderSetState = setState;
    notifyListeners();
  }
}

class DelOrderSetState {
  bool delOrderSetState = false;
}

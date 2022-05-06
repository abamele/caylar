import 'package:flutter/material.dart';

final keyListNotify = KeyListNotify(KeyList());


class KeyListNotify extends ValueNotifier<KeyList>  {
  KeyListNotify(KeyList value) : super(value);
  
  void onKeyList(Size size, int index){
    value.viewSizeList[index] = size;
    notifyListeners();
  }
}

class KeyList {
  
  List viewSizeList = List.generate(100, (int index) => const Size(0.00, 0.00), growable: true);
}
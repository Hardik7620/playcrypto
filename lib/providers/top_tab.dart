import 'package:flutter/material.dart';

class TopTab with ChangeNotifier {
  int _selectedIndex = 3;
  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class UIState extends ChangeNotifier {
  late final playAreaWidth = Property<double>(0, notifyListeners);
  late final playAreaHeight = Property<double>(0, notifyListeners);
  late final stationDiameter = Property<double>(0, notifyListeners);
  late final showMenuAtBottom = Property<bool>(false, notifyListeners);
  late final sideMenuPosition = Property<double>(0, notifyListeners);
  late final sideMenuWidth = Property<double>(0, notifyListeners);
  late final bottomMenuHeight = Property<double>(0, notifyListeners);
}

// helper class to reduce boilerplate code
// sets up standard getters and setters that notify listeners
class Property<T> {
  Property(T initialValue, this.notifyListeners) {
    _value = initialValue;
  }

  late T _value;
  final void Function() notifyListeners;

  T get value => _value;

  set value(T value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}

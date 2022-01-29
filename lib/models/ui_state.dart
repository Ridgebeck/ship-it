import 'package:flutter/material.dart';

class UIState extends ChangeNotifier {
  late final playAreaWidth = Property<double>(0, notifyListeners);
  late final playAreaHeight = Property<double>(0, notifyListeners);
  late final stationDiameter = Property<double>(0, notifyListeners);
}

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

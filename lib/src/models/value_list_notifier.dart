import 'package:flutter/foundation.dart';

/// Similar to [ValueNotifier] but for List and uses value equality.
class ValueListNotifier<T> extends ChangeNotifier
    implements ValueListenable<List<T>> {
  ValueListNotifier(List<T> value) : _value = value;

  @override
  List<T> get value => _value;
  List<T> _value;
  set value(List<T> newValue) {
    if (_equals(_value, newValue)) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';

  static bool _equals<T>(List<T> list1, List<T> list2) {
    if (identical(list1, list2)) return true;
    final length = list1.length;
    if (length != list2.length) return false;
    for (var i = 0; i < length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}

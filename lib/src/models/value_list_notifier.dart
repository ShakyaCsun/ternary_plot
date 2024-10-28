import 'package:flutter/foundation.dart';

/// Similar to [ValueNotifier] but for List and uses value equality and
/// immutability for the List.
class ValueListNotifier<T> extends ChangeNotifier
    implements ValueListenable<List<T>> {
  ValueListNotifier(List<T> value) : _value = List.unmodifiable(value);

  @override
  List<T> get value => _value;
  List<T> _value;
  set value(List<T> newValue) {
    if (listEquals(_value, newValue)) {
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

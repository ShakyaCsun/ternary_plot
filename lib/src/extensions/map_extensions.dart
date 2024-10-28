extension MapSwapKeyValueExtension<K, V> on Map<K, V> {
  /// Swap keys and values of a [Map].
  ///
  /// Since values to keys may create duplicate keys, the original keys are
  /// instead returned as List of keys.
  ///
  /// ```dart
  /// final foo = {1: 'bar', 2: 'baz', 3: 'bar'};
  /// print(foo.swapKV); // prints {'bar': [1, 3], 'baz': [2]}
  /// ```
  Map<V, List<K>> get swapKV {
    return entries.fold(
      <V, List<K>>{},
      (result, entry) {
        final MapEntry(:key, :value) = entry;
        result.update(
          value,
          (value) => [
            ...value,
            key,
          ],
          ifAbsent: () => [key],
        );
        return result;
      },
    );
  }
}

extension NullableStringExtension on String? {
  bool get isNullOrWhiteSpace => this == null || this!.trim().isEmpty;
}

extension NullableIterableExtension<T> on Iterable<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

/// Firebase Analytics event parameters only allow [String] or [num] values.
Map<String, Object>? encodeFirebaseEventParameters(
  Map<String, Object?>? input,
) {
  if (input == null || input.isEmpty) return null;
  final out = <String, Object>{};
  for (final MapEntry(:key, :value) in input.entries) {
    if (value == null) continue;
    final encoded = _encodeFirebaseValue(value);
    if (encoded != null) {
      out[key] = encoded;
    }
  }
  return out.isEmpty ? null : out;
}

Object? _encodeFirebaseValue(Object? value) {
  switch (value) {
    case null:
      return null;
    case String _:
      return value;
    case num _:
      return value;
    case bool b:
      return b ? 'true' : 'false';
    default:
      return value.toString();
  }
}

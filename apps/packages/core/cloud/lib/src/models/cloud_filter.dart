/// Backend-agnostic query predicates.
sealed class CloudFilter {
  const CloudFilter();
}

/// Matches documents where [field] equals [value].
final class WhereEqual extends CloudFilter {
  const WhereEqual(this.field, this.value);

  final String field;
  final Object? value;
}

/// Matches documents where [field] is contained in [values].
final class WhereIn extends CloudFilter {
  const WhereIn(this.field, this.values);

  final String field;
  final List<Object?> values;
}

/// Matches documents where [field] is less than [value].
final class WhereLessThan extends CloudFilter {
  const WhereLessThan(this.field, this.value);

  final String field;
  final Object? value;
}

/// Matches documents where [field] is greater than [value].
final class WhereGreaterThan extends CloudFilter {
  const WhereGreaterThan(this.field, this.value);

  final String field;
  final Object? value;
}

/// Matches documents where [field] contains the string [value].
final class WhereContains extends CloudFilter {
  const WhereContains(this.field, this.value);

  final String field;
  final String value;
}

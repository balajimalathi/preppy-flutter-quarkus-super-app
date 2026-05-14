/// Backend-agnostic query predicates.
sealed class CloudFilter {
  const CloudFilter();
}

final class WhereEqual extends CloudFilter {
  const WhereEqual(this.field, this.value);

  final String field;
  final Object? value;
}

final class WhereIn extends CloudFilter {
  const WhereIn(this.field, this.values);

  final String field;
  final List<Object?> values;
}

final class WhereLessThan extends CloudFilter {
  const WhereLessThan(this.field, this.value);

  final String field;
  final Object? value;
}

final class WhereGreaterThan extends CloudFilter {
  const WhereGreaterThan(this.field, this.value);

  final String field;
  final Object? value;
}

final class WhereContains extends CloudFilter {
  const WhereContains(this.field, this.value);

  final String field;
  final String value;
}

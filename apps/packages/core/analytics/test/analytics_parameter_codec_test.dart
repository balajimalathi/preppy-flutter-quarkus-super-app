import 'package:core_analytics/src/analytics_parameter_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'encodeFirebaseEventParameters keeps String and num, stringifies bool',
    () {
      final out = encodeFirebaseEventParameters({
        's': 'a',
        'i': 2,
        'd': 1.5,
        'b': true,
        'n': null,
      });
      expect(out, {'s': 'a', 'i': 2, 'd': 1.5, 'b': 'true'});
    },
  );
}

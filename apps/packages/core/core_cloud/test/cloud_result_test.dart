import 'package:core_cloud/core_cloud.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CloudResult fold handles success', () {
    const r = CloudSuccess<int>(42);
    expect(r.fold(onSuccess: (v) => v * 2, onError: (msg, code) => -1), 84);
  });

  test('CloudUnit sentinel is unique', () {
    expect(cloudUnit, isA<CloudUnit>());
  });
}

import 'package:core_cloud/core_cloud.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudResult', () {
    test('fold handles success', () {
      const r = CloudSuccess<int>(42);
      expect(r.fold(onSuccess: (v) => v * 2, onError: (msg, code) => -1), 84);
    });

    test('fold handles error', () {
      const r = CloudError<String>(
        message: 'denied',
        code: CloudErrorCode.permissionDenied,
      );
      expect(
        r.fold(
          onSuccess: (_) => 'ok',
          onError: (msg, code) => '$msg:${code.name}',
        ),
        'denied:permissionDenied',
      );
    });

    test('CloudSuccess equality uses data', () {
      const a = CloudSuccess<int>(1);
      const b = CloudSuccess<int>(1);
      const c = CloudSuccess<int>(2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('CloudError equality uses message and code', () {
      const a = CloudError<void>(message: 'x', code: CloudErrorCode.notFound);
      const b = CloudError<void>(message: 'x', code: CloudErrorCode.notFound);
      const c = CloudError<void>(message: 'y', code: CloudErrorCode.notFound);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('CloudUnit', () {
    test('sentinel is unique', () {
      expect(cloudUnit, isA<CloudUnit>());
    });
  });

  group('CloudErrorCode', () {
    test('includes expected values', () {
      expect(CloudErrorCode.values, contains(CloudErrorCode.notFound));
      expect(CloudErrorCode.values, contains(CloudErrorCode.transactionFailed));
    });
  });
}

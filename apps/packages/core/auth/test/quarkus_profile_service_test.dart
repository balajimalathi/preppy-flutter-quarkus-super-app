import 'package:core_auth/src/impl/profile_exceptions.dart';
import 'package:core_auth/src/impl/quarkus_profile_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_test_fakes.dart';

Dio _dioResponding(
  Future<Response<dynamic>> Function(RequestOptions options) respond,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final response = await respond(options);
          handler.resolve(response);
        } on DioException catch (e) {
          handler.reject(e);
        }
      },
    ),
  );
  return dio;
}

void main() {
  late QuarkusProfileService service;

  group('QuarkusProfileService', () {
    test('fetchProfile and syncProfile return parsed AppProfile', () async {
      service = QuarkusProfileService(
        _dioResponding(
          (options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: sampleProfileJson,
          ),
        ),
      );
      expect(await service.fetchProfile(), sampleProfile);
      expect(await service.syncProfile(), sampleProfile);
    });

    test('throws ProfileFetchException with isAuthFailure for 401', () async {
      service = QuarkusProfileService(
        _dioResponding((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'Token rejected'},
            ),
          );
        }),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>()
              .having((e) => e.isAuthFailure, 'isAuthFailure', isTrue)
              .having((e) => e.message, 'message', 'Token rejected'),
        ),
      );
    });

    test('throws ProfileFetchException with isAuthFailure for 403', () async {
      service = QuarkusProfileService(
        _dioResponding((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 403),
          );
        }),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>().having(
            (e) => e.isAuthFailure,
            'isAuthFailure',
            isTrue,
          ),
        ),
      );
    });

    test('400 prefers server message', () async {
      service = QuarkusProfileService(
        _dioResponding((options) async {
          throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'message': 'Bad profile request'},
            ),
          );
        }),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>().having(
            (e) => e.message,
            'message',
            'Bad profile request',
          ),
        ),
      );
    });

    test('connection error message mentions baseUrl', () async {
      service = QuarkusProfileService(
        _dioResponding((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>().having(
            (e) => e.message,
            'message',
            contains('http://localhost:8080'),
          ),
        ),
      );
    });

    test('timeout message mentions baseUrl', () async {
      service = QuarkusProfileService(
        _dioResponding((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        }),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>().having(
            (e) => e.message,
            'message',
            allOf(contains('timed out'), contains('http://localhost:8080')),
          ),
        ),
      );
    });

    test('invalid body throws ProfileFetchException', () async {
      service = QuarkusProfileService(
        _dioResponding(
          (options) async => Response(
            requestOptions: options,
            statusCode: 200,
            data: 'not-a-map',
          ),
        ),
      );
      await expectLater(
        service.fetchProfile(),
        throwsA(
          isA<ProfileFetchException>().having(
            (e) => e.message,
            'message',
            'Invalid profile response',
          ),
        ),
      );
    });
  });
}

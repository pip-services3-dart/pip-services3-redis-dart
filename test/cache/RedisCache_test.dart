import 'dart:io';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_redis/pip_services3_redis.dart';
import '../fixtures/CacheFixture.dart';

void main() {
  group('RedisCache', () {
    late RedisCache _cache;
    late CacheFixture _fixture;

    setUp(() async {
      var host = Platform.environment['REDIS_SERVICE_HOST'] ?? 'localhost';
      var port = Platform.environment['REDIS_SERVICE_PORT'] ?? 6379;

      _cache = RedisCache();

      var config = ConfigParams.fromTuples(
          ['connection.host', host, 'connection.port', port]);
      _cache.configure(config);

      _fixture = CacheFixture(_cache);

      await _cache.open(null);
    });

    tearDown(() async {
      await _cache.close(
        null,
      );
    });

    test('Store and Retrieve', () async {
      await _fixture.testStoreAndRetrieve();
    });

    test('Retrieve Expired', () async {
      await _fixture.testRetrieveExpired();
    });

    test('Remove', () async {
      await _fixture.testRemove();
    });
  });
}

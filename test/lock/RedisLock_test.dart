import 'dart:io';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_redis/pip_services3_redis.dart';
import '../fixtures/LockFixture.dart';

void main() {
  group('RedisLock', () {
    late RedisLock _lock;
    late LockFixture _fixture;

    setUp(() async {
      var host = Platform.environment['REDIS_SERVICE_HOST'] ?? 'localhost';
      var port = Platform.environment['REDIS_SERVICE_PORT'] ?? 6379;

      _lock = RedisLock();

      var config = ConfigParams.fromTuples(
          ['connection.host', host, 'connection.port', port]);
      _lock.configure(config);

      _fixture = LockFixture(_lock);

      await _lock.open(null);
    });

    tearDown(() async {
      await _lock.close(null);
    });

    test('Try Acquire Lock', () async {
      await _fixture.testTryAcquireLock();
    });

    test('Acquire Lock', () async {
      await _fixture.testAcquireLock();
    });

    test('Release Lock', () async {
      await _fixture.testReleaseLock();
    });
  });
}

import 'package:test/test.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

final LOCK1 = 'lock_1';
final LOCK2 = 'lock_2';
final LOCK3 = 'lock_3';

class LockFixture {
  final ILock _lock;

  LockFixture(ILock lock) : _lock = lock;

  Future testTryAcquireLock() async {
    // Try to acquire lock for the first time
    var result = await _lock.tryAcquireLock('123', LOCK1, 3000);
    expect(result, isTrue);

    // Try to acquire lock for the second time
    result = await _lock.tryAcquireLock('123', LOCK1, 3000);
    expect(result, isFalse);

    // Release the lock
    await _lock.releaseLock('123', LOCK1);

    // Try to acquire lock for the third time
    result = await _lock.tryAcquireLock('123', LOCK1, 3000);
    expect(result, isTrue);

    await _lock.releaseLock('123', LOCK1);
  }

  Future testAcquireLock() async {
    // Acquire lock for the first time
    await _lock.acquireLock('123', LOCK2, 3000, 1000);
    // Acquire lock for the second time
    var err;
    try {
      await _lock.acquireLock('123', LOCK2, 3000, 1000);
    } catch (ex) {
      err = ex;
    }
    expect(err, isNotNull);

    // Release the lock
    await _lock.releaseLock('123', LOCK2);

    // Acquire lock for the third time
    await _lock.acquireLock('123', LOCK2, 3000, 1000);

    await _lock.releaseLock('123', LOCK2);
  }

  Future testReleaseLock() async {
    // Acquire lock for the first time
    var result = await _lock.tryAcquireLock('123', LOCK3, 3000);
    expect(result, isTrue);

    // Release the lock for the first time
    await _lock.releaseLock('123', LOCK3);

    // Release the lock for the second time
    await _lock.releaseLock('123', LOCK3);
  }
}

// import { ConfigParams } from 'package:pip_services3_commons-node';

// import { RedisLock } from '../../src/lock/RedisLock';
// import { LockFixture } from '../fixtures/LockFixture';

// suite('RedisLock', ()=> {
//     var _lock: RedisLock;
//     var _fixture: LockFixture;

//     setup((done) => {
//         let host = process.env['REDIS_SERVICE_HOST'] || 'localhost';
//         let port = process.env['REDIS_SERVICE_PORT'] || 6379;

//         _lock = new RedisLock();

//         let config = ConfigParams.fromTuples(
//             'connection.host', host,
//             'connection.port', port
//         );
//         _lock.configure(config);

//         _fixture = new LockFixture(_lock);

//         _lock.open(null, done);
//     });

//     teardown((done) => {
//         _lock.close(null, done);
//     });

//     test('Try Acquire Lock', (done) => {
//         _fixture.testTryAcquireLock(done);
//     });

//     test('Acquire Lock', (done) => {
//         _fixture.testAcquireLock(done);
//     });

//     test('Release Lock', (done) => {
//         _fixture.testReleaseLock(done);
//     });

// });

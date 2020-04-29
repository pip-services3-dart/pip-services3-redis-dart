// let process = require('process');
// let assert = require('chai').assert;
// let async = require('async');

// import { Descriptor } from 'package:pip_services3_commons-node';
// import { ConfigParams } from 'package:pip_services3_commons-node';

// import { RedisCache } from '../../src/cache/RedisCache';
// import { CacheFixture } from '../fixtures/CacheFixture';

// suite('RedisCache', ()=> {
//     let _cache: RedisCache;
//     let _fixture: CacheFixture;

//     setup((done) => {
//         let host = process.env['REDIS_SERVICE_HOST'] || 'localhost';
//         let port = process.env['REDIS_SERVICE_PORT'] || 6379;

//         _cache = new RedisCache();

//         let config = ConfigParams.fromTuples(
//             'connection.host', host,
//             'connection.port', port
//         );
//         _cache.configure(config);

//         _fixture = new CacheFixture(_cache);

//         _cache.open(null, done);
//     });

//     teardown((done) => {
//         _cache.close(null, done);
//     });

//     test('Store and Retrieve', (done) => {
//         _fixture.testStoreAndRetrieve(done);
//     });    

//     test('Retrieve Expired', (done) => {
//         _fixture.testRetrieveExpired(done);
//     });    

//     test('Remove', (done) => {
//         _fixture.testRemove(done);
//     });    
    
// });

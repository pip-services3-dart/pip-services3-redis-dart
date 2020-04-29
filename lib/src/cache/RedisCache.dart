//  @module cache 
//  @hidden 
// const _ = require('lodash');
//  @hidden 
// const async = require('async');

// import { ConfigParams } from 'pip-services3-commons-node';
// import { IConfigurable } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { IReferenceable } from 'pip-services3-commons-node';
// import { IOpenable } from 'pip-services3-commons-node';
// import { InvalidStateException } from 'pip-services3-commons-node';
// import { ConfigException } from 'pip-services3-commons-node';
// import { ConnectionParams } from 'pip-services3-components-node';
// import { ConnectionResolver } from 'pip-services3-components-node';
// import { CredentialParams } from 'pip-services3-components-node';
// import { CredentialResolver } from 'pip-services3-components-node';
// import { ICache } from 'pip-services3-components-node';

// 
// ///Distributed cache that stores values in Redis in-memory database.
// ///
// ///### Configuration parameters ###
// ///
// ///- connection(s):           
// ///  - discovery_key:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
// ///  - host:                  host name or IP address
// ///  - port:                  port number
// ///  - uri:                   resource URI or connection string with all parameters in it
// ///- credential(s):
// ///  - store_key:             key to retrieve parameters from credential store
// ///  - username:              user name (currently is not used)
// ///  - password:              user password
// ///- options:
// ///  - retries:               number of retries (default: 3)
// ///  - timeout:               default caching timeout in milliseconds (default: 1 minute)
// ///  - max_size:              maximum number of values stored in this cache (default: 1000)        
// /// 
// ///### References ###
// ///
// ///- \*:discovery:\*:\*:1.0        (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
// ///- \*:credential-store:\*:\*:1.0 (optional) Credential stores to resolve credential
//  *
// ///### Example ###
// ///
// ///    let cache = new RedisCache();
// ///    cache.configure(ConfigParams.fromTuples(
// ///      "host", "localhost",
// ///      "port", 6379
// ///    ));
// ///
// ///    cache.open("123", (err) => {
// ///      ...
// ///    });
// ///
// ///    cache.store("123", "key1", "ABC", (err) => {
// ///         cache.store("123", "key1", (err, value) => {
// ///             // Result: "ABC"
// ///         });
// ///    });
//  
// export class RedisCache implements ICache, IConfigurable, IReferenceable, IOpenable {
//     private _connectionResolver: ConnectionResolver = new ConnectionResolver();
//     private _credentialResolver: CredentialResolver = new CredentialResolver();
    
//     private _timeout: number = 30000;
//     private _retries: number = 3;

//     private _client: any = null;

//     
//     ///Creates a new instance of this cache.
//      
//     public constructor() {}

//     
//     ///Configures component by passing configuration parameters.
//     ///
//     ///- config    configuration parameters to be set.
//      
//     public configure(config: ConfigParams): void {
//         this._connectionResolver.configure(config);
//         this._credentialResolver.configure(config);

//         this._timeout = config.getAsIntegerWithDefault('options.timeout', this._timeout);
//         this._retries = config.getAsIntegerWithDefault('options.retries', this._retries);
//     }

//     
// 	///Sets references to dependent components.
// 	///
// 	///- references 	references to locate the component dependencies. 
//      
//     public setReferences(references: IReferences): void {
//         this._connectionResolver.setReferences(references);
//         this._credentialResolver.setReferences(references);
//     }

//     
// 	///Checks if the component is opened.
// 	///
// 	///Returns true if the component has been opened and false otherwise.
//      
//     public isOpen(): boolean {
//         return this._client;
//     }

//     
// 	///Opens the component.
// 	///
// 	///- correlationId 	(optional) transaction id to trace execution through call chain.
//     ///- callback 			callback function that receives error or null no errors occured.
//      
//     public open(correlationId: string, callback: (err: any) => void): void {
//         let connection: ConnectionParams;
//         let credential: CredentialParams;

//         async.series([
//             (callback) => {
//                 this._connectionResolver.resolve(correlationId, (err, result) => {
//                     connection = result;
//                     if (err == null && connection == null)
//                         err = new ConfigException(correlationId, 'NO_CONNECTION', 'Connection is not configured');
//                     callback(err);
//                 });
//             },
//             (callback) => {
//                 this._credentialResolver.lookup(correlationId, (err, result) => {
//                     credential = result;
//                     callback(err);
//                 });
//             },
//             (callback) => {
//                 let options: any = {
//                     // connect_timeout: this._timeout,
//                     // max_attempts: this._retries,
//                     retry_strategy: (options) => { return this.retryStrategy(options); }
//                 };
                
//                 if (connection.getUri() != null) {
//                     options.url = connection.getUri();
//                 } else {                    
//                     options.host = connection.getHost() || 'localhost';
//                     options.port = connection.getPort() || 6379;
//                 }

//                 if (credential != null) {
//                     options.password = credential.getPassword();
//                 }
    
//                 let redis = require('redis');
//                 this._client = redis.createClient(options);
    
//                 if (callback) callback(null);    
//             }
//         ], callback);
//     }

//     
// 	///Closes component and frees used resources.
// 	///
// 	///- correlationId 	(optional) transaction id to trace execution through call chain.
//     ///- callback 			callback function that receives error or null no errors occured.
//      
//     public close(correlationId: string, callback: (err: any) => void): void {
//         if (this._client != null) {
//             this._client.quit(((err) => {
//                 this._client = null;    
//                 if (callback) callback(err);
//             }));
//         } else {
//             if (callback) callback(null);
//         }
//     }

//     private checkOpened(correlationId: string, callback: any): boolean {
//         if (!this.isOpen()) {
//             let err = new InvalidStateException(correlationId, 'NOT_OPENED', 'Connection is not opened');
//             callback(err, null);
//             return false;
//         }
        
//         return true;
//     }
    
//     private retryStrategy(options: any): any {
//         if (options.error && options.error.code === 'ECONNREFUSED') {
//             // End reconnecting on a specific error and flush all commands with
//             // a individual error
//             return new Error('The server refused the connection');
//         }
//         if (options.total_retry_time > this._timeout) {
//             // End reconnecting after a specific timeout and flush all commands
//             // with a individual error
//             return new Error('Retry time exhausted');
//         }
//         if (options.attempt > this._retries) {
//             // End reconnecting with built in error
//             return undefined;
//         }
//         // reconnect after
//         return Math.min(options.attempt///100, 3000);
//     }

//     
//     ///Retrieves cached value from the cache using its key.
//     ///If value is missing in the cache or expired it returns null.
//     ///
//     ///- correlationId     (optional) transaction id to trace execution through call chain.
//     ///- key               a unique value key.
//     ///- callback          callback function that receives cached value or error.
//      
//     public retrieve(correlationId: string, key: string,
//         callback: (err: any, value: any) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.get(key, callback);
//     }

//     
//     ///Stores value in the cache with expiration time.
//     ///
//     ///- correlationId     (optional) transaction id to trace execution through call chain.
//     ///- key               a unique value key.
//     ///- value             a value to store.
//     ///- timeout           expiration timeout in milliseconds.
//     ///- callback          (optional) callback function that receives an error or null for success
//      
//     public store(correlationId: string, key: string, value: any, timeout: number,
//         callback: (err: any) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.set(key, value, 'PX', timeout, callback);
//     }

//     
//     ///Removes a value from the cache by its key.
//     ///
//     ///- correlationId     (optional) transaction id to trace execution through call chain.
//     ///- key               a unique value key.
//     ///- callback          (optional) callback function that receives an error or null for success
//      
//     public remove(correlationId: string, key: string,
//         callback: (err: any) => void) {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.del(key, callback);
//     }
    
// }
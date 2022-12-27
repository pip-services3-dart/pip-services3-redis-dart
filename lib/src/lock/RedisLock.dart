import 'dart:async';

import 'package:redis/redis.dart' as redis;
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

///Distributed lock that is implemented based on Redis in-memory database.
///
///### Configuration parameters ###
///
/// - [connection(s)]:
///  - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///  - [host]:                  host name or IP address
///  - [port]:                  port number
///  - [uri]:                   resource URI or connection string with all parameters in it
/// - [credential(s)]:
///  - [store_key]:             key to retrieve parameters from credential store
///  - [username]:              user name (currently is not used)
///  - [password]:              user password
/// - [options]:
///  - [retry_timeout]:         timeout in milliseconds to retry lock acquisition. (Default: 100)
///  - [retries]:               number of retries (default: 3)
///
///### References ###
///
/// - *:discovery:*:*:1.0        (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
/// - *:credential-store:*:*:1.0 (optional) Credential stores to resolve credential [ICredentialStore](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICredentialStore-class.html)
///
///### Example ###
///```dart
///    var lock = RedisLock();
///    lock.configure(ConfigParams.fromTuples([
///      'host', 'localhost',
///      'port', 6379
///    ]));
///
///    await lock.open('123');
///      ...
///
///    await lock.acquire('123', 'key1');
///
///    try {
///        // Processing...
///    } finally {
///       await lock.releaseLock('123', 'key1');
///        // Continue...
///    }
///```
class RedisLock extends Lock
    implements IConfigurable, IReferenceable, IOpenable {
  final _connectionResolver = ConnectionResolver();
  final _credentialResolver = CredentialResolver();

  final String _lock = IdGenerator.nextLong();
  int _timeout = 30000;
  int _retries = 3;

  redis.Command? _client;

  ///Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    _connectionResolver.configure(config);
    _credentialResolver.configure(config);
    _timeout = config.getAsIntegerWithDefault('options.timeout', _timeout);
    _retries = config.getAsIntegerWithDefault('options.retries', _retries);
  }

  ///Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    _connectionResolver.setReferences(references);
    _credentialResolver.setReferences(references);
  }

  ///Checks if the component is opened.
  ///
  ///Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return _client != null;
  }

  ///Opens the component.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives an null no errors occured.
  /// Throws error
  @override
  Future open(String? correlationId) async {
    var connection = await _connectionResolver.resolve(correlationId);
    if (connection == null) {
      throw ConfigException(
          correlationId, 'NO_CONNECTION', 'Connection is not configured');
    }
    //credential = await _credentialResolver.lookup(correlationId);

    var redisConn = redis.RedisConnection();

    //TODO: Fix work with uri connection string and credentials
    // if (connection.getUri() != null) {
    //   var url = connection.getUri();
    // } else {
    var host = connection.getHost() ?? 'localhost';
    var port = connection.getPort() ?? 6379;
    _client = await redisConn.connect(host, port);
    // }

    // if (credential != null) {
    //   var password = credential.getPassword();
    // }
  }

  ///Closes component and frees used resources.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives an null no errors occured.
  /// Throws error
  @override
  Future close(String? correlationId) async {
    if (_client != null) {
      await _client!.get_connection().close();
      _client = null;
    }
  }

  bool _checkOpened(String? correlationId) {
    if (!isOpen()) {
      throw InvalidStateException(
          correlationId, 'NOT_OPENED', 'Connection is not opened');
    }
    return true;
  }

  ///Makes a single attempt to acquire a lock by its key.
  ///It returns immediately a positive or negative result.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [key]               a unique lock key to acquire.
  /// - [ttl]               a lock timeout (time to live) in milliseconds.
  /// Return                Future that receives a lock result
  /// Throws error.
  @override
  Future<bool> tryAcquireLock(
      String? correlationId, String key, int ttl) async {
    if (!_checkOpened(correlationId)) return false;
    var result =
        await _client!.send_object(['SET', key, _lock, 'NX', 'PX', ttl]);
    return result == 'OK';
  }

  ///Releases prevously acquired lock by its key.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [key]               a unique lock key to release.
  /// Return          Future that receives an null for success.
  /// Throws error
  @override
  Future releaseLock(String? correlationId, String key) async {
    if (!_checkOpened(correlationId)) return;

    // Start transaction on key
    await _client!.send_object(['WATCH', key]);

    // Read and check if lock is the same
    var keyId = await _client!.send_object(['GET', key]);

    if (keyId == null) {
      await _client!.send_object(['UNWATCH']);
    }
    // Remove the lock if it matches
    if (keyId == _lock) {
      await _client!.send_object(['MULTI']);
      await _client!.send_object(['DEL', key]);
      await _client!.send_object(['EXEC']);
    } else {
      // Cancel transaction if it doesn't match
      await _client!.send_object(['UNWATCH']);
    }
  }
}

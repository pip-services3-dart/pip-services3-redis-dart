import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../cache/RedisCache.dart';
import '../lock/RedisLock.dart';

///Creates Redis components by their descriptors.
///
///See [[RedisCache]]
///See [[RedisLock]]

class DefaultRedisFactory extends Factory {
  static final descriptor =
      Descriptor('pip-services', 'factory', 'redis', 'default', '1.0');
  static final RedisCacheDescriptor =
      Descriptor('pip-services', 'cache', 'redis', '*', '1.0');
  static final RedisLockDescriptor =
      Descriptor('pip-services', 'lock', 'redis', '*', '1.0');

  ///Create a  instance of the factory.
  DefaultRedisFactory() : super() {
    registerAsType(DefaultRedisFactory.RedisCacheDescriptor, RedisCache);
    registerAsType(DefaultRedisFactory.RedisLockDescriptor, RedisLock);
  }
}

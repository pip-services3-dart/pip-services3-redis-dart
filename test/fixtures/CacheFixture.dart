import 'dart:async';
import 'package:test/test.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

final KEY1 = 'key1';
final KEY2 = 'key2';

final VALUE1 = 'value1';
final VALUE2 = 'value2';

class CacheFixture {
  final ICache _cache;

  CacheFixture(ICache cache) : _cache = cache;

  Future testStoreAndRetrieve() async {
    await _cache.store('123', KEY1, VALUE1, 5000);

    await _cache.store('123', KEY2, VALUE2, 5000);

    await Future.delayed(Duration(milliseconds: 500));

    var val = await _cache.retrieve('123', KEY1);
    expect(val, isNotNull);
    expect(VALUE1, val);

    val = await _cache.retrieve('123', KEY2);
    expect(val, isNotNull);
    expect(VALUE2, val);
  }

  Future testRetrieveExpired() async {
    await _cache.store('123', KEY1, VALUE1, 1000);

    await Future.delayed(Duration(milliseconds: 1500));

    var val = await _cache.retrieve('123', KEY1);
    expect(val, isNull);
  }

  Future testRemove() async {
    await _cache.store('123', KEY1, VALUE1, 1000);

    await _cache.remove('123', KEY1);

    var val = await _cache.retrieve('123', KEY1);
    expect(val, isNull);
  }
}

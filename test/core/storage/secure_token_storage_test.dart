import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySecureStorage backing;
  late SecureTokenStorage tokens;

  setUp(() {
    backing = InMemorySecureStorage();
    tokens = SecureTokenStorage(backing);
  });

  test('初始无 token', () async {
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });

  test('save 后 read 返回相同值', () async {
    await tokens.save(accessToken: 'a1', refreshToken: 'r1');
    expect(await tokens.readAccessToken(), 'a1');
    expect(await tokens.readRefreshToken(), 'r1');
  });

  test('再次 save 覆盖旧值', () async {
    await tokens.save(accessToken: 'a1', refreshToken: 'r1');
    await tokens.save(accessToken: 'a2', refreshToken: 'r2');
    expect(await tokens.readAccessToken(), 'a2');
    expect(await tokens.readRefreshToken(), 'r2');
  });

  test('clear 删除两个 token', () async {
    await tokens.save(accessToken: 'a', refreshToken: 'r');
    await tokens.clear();
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });

  test('token 持久化到底层 SecureStorage（key 命名稳定）', () async {
    await tokens.save(accessToken: 'a', refreshToken: 'r');
    expect(await backing.read('auth.access_token'), 'a');
    expect(await backing.read('auth.refresh_token'), 'r');
  });
}

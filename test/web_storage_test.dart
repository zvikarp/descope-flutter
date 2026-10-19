import 'package:descope/src/internal/web/web_platform.dart';
import 'package:descope/src/session/storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // SessionStorageWebStore uses the stub in-memory storage, so these
  // tests exercise the migration logic on non-web platforms without mocking.
  group('SessionStorageWebStore', () {
    late SessionStorageWebStore store;

    setUp(() {
      store = SessionStorageWebStore();
      webLocalStorage.clear();
      webSessionStorage.clear();
    });

    test('loadItem returns data from sessionStorage', () async {
      webSessionStorage.setItem('key', 'value');
      expect(await store.loadItem('key'), 'value');
      expect(webLocalStorage, isEmpty);
    });

    test('loadItem falls back to localStorage and copies to sessionStorage', () async {
      webLocalStorage.setItem('key', 'legacy');
      final result = await store.loadItem('key');
      expect(result, 'legacy');
      expect(webSessionStorage.getItem('key'), 'legacy'); // copied to sessionStorage on load
      expect(webLocalStorage.containsKey('key'), isTrue); // not cleared until next save
    });

    test('loadItem returns null when nothing is stored', () async {
      expect(await store.loadItem('key'), isNull);
    });

    test('saveItem writes to sessionStorage and clears localStorage', () async {
      webLocalStorage.setItem('key', 'legacy');
      await store.saveItem(key: 'key', data: 'value');
      expect(webSessionStorage.getItem('key'), 'value');
      expect(webLocalStorage.containsKey('key'), isFalse); // cleared on save
    });

    test('removeItem clears both sessionStorage and localStorage', () async {
      webSessionStorage.setItem('key', 'new');
      webLocalStorage.setItem('key', 'old');
      await store.removeItem('key');
      expect(webSessionStorage.containsKey('key'), isFalse);
      expect(webLocalStorage.containsKey('key'), isFalse);
    });
  });
}

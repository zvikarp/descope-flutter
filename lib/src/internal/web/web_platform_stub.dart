import 'dart:async';

/// In-memory stand-in for `window.sessionStorage` / `window.localStorage`.
class WebStorage {
  final _data = <String, String>{};

  String? getItem(String key) => _data[key];

  void setItem(String key, String value) => _data[key] = value;

  void removeItem(String key) => _data.remove(key);

  bool containsKey(String key) => _data.containsKey(key);

  bool get isEmpty => _data.isEmpty;

  void clear() => _data.clear();
}

final webSessionStorage = WebStorage();
final webLocalStorage = WebStorage();

String webUserAgent() => '';

String webVendor() => '';

String? webOrigin() => null;

bool webIsWebAuthnSupported() => false;

Future<String> webAuthnCreate(String options) =>
    Future.error(UnsupportedError('WebAuthn is only available on web'));

Future<String> webAuthnGet(String options) =>
    Future.error(UnsupportedError('WebAuthn is only available on web'));

/// A flow web component mounted in the page.
abstract class WebFlowComponent {
  void dispose();
}

WebFlowComponent webMountFlow({
  required String projectId,
  required String flowId,
  required String baseUrl,
  required String componentVersion,
  required Map<String, String> containerCss,
  required void Function() onReady,
  required void Function(Map<String, dynamic> detail) onSuccess,
  required void Function(String? message) onError,
}) {
  throw UnsupportedError('Web flows are only available on web');
}

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'webauthn_script.dart';

// Storage

class WebStorage {
  final web.Storage _storage;

  WebStorage(this._storage);

  String? getItem(String key) => _storage.getItem(key);

  void setItem(String key, String value) => _storage.setItem(key, value);

  void removeItem(String key) => _storage.removeItem(key);

  bool containsKey(String key) => _storage.getItem(key) != null;

  bool get isEmpty => _storage.length == 0;

  void clear() => _storage.clear();
}

final webSessionStorage = WebStorage(web.window.sessionStorage);
final webLocalStorage = WebStorage(web.window.localStorage);

// Browser info

String webUserAgent() => web.window.navigator.userAgent;

String webVendor() => web.window.navigator.vendor;

String? webOrigin() => web.window.location.origin;

// WebAuthn

const _webAuthnScriptId = 'descope-webauthn-script';

@JS('descopeIsWebAuthnSupported')
external JSBoolean _isWebAuthnSupported();

@JS('descopeWebAuthnCreate')
external JSPromise<JSString> _webAuthnCreate(JSString options);

@JS('descopeWebAuthnGet')
external JSPromise<JSString> _webAuthnGet(JSString options);

void _setupWebAuthnScript() {
  if (web.document.getElementById(_webAuthnScriptId) != null) return;
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.id = _webAuthnScriptId;
  script.text = webAuthnScript;
  web.document.head?.appendChild(script);
}

bool webIsWebAuthnSupported() {
  _setupWebAuthnScript();
  return _isWebAuthnSupported().toDart;
}

Future<String> webAuthnCreate(String options) async {
  _setupWebAuthnScript();
  return (await _webAuthnCreate(options.toJS).toDart).toDart;
}

Future<String> webAuthnGet(String options) async {
  _setupWebAuthnScript();
  return (await _webAuthnGet(options.toJS).toDart).toDart;
}

// Flows

const _webComponentTag = 'descope-wc';
const _flowContainerClass = 'login-container';
const _hiddenContainerClass = 'hidden-container';
const _styleClass = 'web-component-style';
const _eventReady = 'ready';
const _eventSuccess = 'success';
const _eventError = 'error';

/// A flow web component mounted in the page.
class WebFlowComponent {
  final web.HTMLElement _container;
  final web.Element _component;
  final web.EventListener _readyListener;
  final web.EventListener _successListener;
  final web.EventListener _errorListener;

  WebFlowComponent._(this._container, this._component, this._readyListener,
      this._successListener, this._errorListener);

  void dispose() {
    try {
      _component.removeEventListener(_eventReady, _readyListener);
      _component.removeEventListener(_eventSuccess, _successListener);
      _component.removeEventListener(_eventError, _errorListener);
      _container.remove();
    } catch (_) {
      // any cleanup failures are silent
    }
  }
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
  _setFlowStyle(containerCss);
  _ensureFlowScript(componentVersion);

  final component = web.document.createElement(_webComponentTag);
  component.setAttribute('project-id', projectId);
  component.setAttribute('flow-id', flowId);
  component.setAttribute('base-url', baseUrl);

  final container = web.document.createElement('div') as web.HTMLElement;
  container.className = _hiddenContainerClass;
  container.appendChild(component);

  final readyListener = ((web.Event event) {
    container.className = _flowContainerClass;
    onReady();
  }).toJS;

  final successListener = ((web.Event event) {
    onSuccess(_eventDetail(event));
  }).toJS;

  final errorListener = ((web.Event event) {
    onError(_eventDetail(event)['errorMessage'] as String?);
  }).toJS;

  component.addEventListener(_eventReady, readyListener);
  component.addEventListener(_eventSuccess, successListener);
  component.addEventListener(_eventError, errorListener);

  web.document.body?.appendChild(container);
  return WebFlowComponent._(
      container, component, readyListener, successListener, errorListener);
}

Map<String, dynamic> _eventDetail(web.Event event) {
  final detail = (event as web.CustomEvent).detail.dartify();
  return detail is Map ? _stringifyKeys(detail) : <String, dynamic>{};
}

Map<String, dynamic> _stringifyKeys(Map<dynamic, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    if (value == null) return;
    result[key.toString()] = value is Map ? _stringifyKeys(value) : value;
  });
  return result;
}

void _setFlowStyle(Map<String, String> css) {
  final rules = css.entries.map((e) => '${e.key}: ${e.value};').join();
  final style = web.document.createElement('style');
  style.className = _styleClass;
  style.textContent =
      '.$_flowContainerClass {$rules}.$_hiddenContainerClass{display: none;}';

  web.document.querySelector('.$_styleClass')?.remove();
  web.document.head?.appendChild(style);
}

void _ensureFlowScript(String version) {
  // added only once per component version
  final scriptClass = 'web-component-script-${version.replaceAll('.', '-')}';
  if (web.document.querySelector('.$scriptClass') != null) return;
  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.className = scriptClass;
  script.src =
      'https://cdn.jsdelivr.net/npm/@descope/web-component@$version/dist/index.js';
  web.document.body?.appendChild(script);
}

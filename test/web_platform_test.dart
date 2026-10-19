@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:descope/src/internal/web/web_platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('webMountFlow', () {
    test('mounts the web component hidden and removes it on dispose', () {
      final component = webMountFlow(
        projectId: 'project',
        flowId: 'flow',
        baseUrl: 'https://api.descope.com',
        componentVersion: '1.2.3',
        containerCss: {'width': '100px'},
        onReady: () {},
        onSuccess: (_) {},
        onError: (_) {},
      );

      final wc = web.document.querySelector('descope-wc');
      expect(wc, isNotNull);
      expect(wc!.getAttribute('project-id'), 'project');
      expect(wc.getAttribute('flow-id'), 'flow');
      expect(wc.getAttribute('base-url'), 'https://api.descope.com');
      expect(web.document.querySelector('.hidden-container'), isNotNull);
      expect(web.document.querySelector('.web-component-script-1-2-3'), isNotNull);

      component.dispose();
      expect(web.document.querySelector('descope-wc'), isNull);
    });

    test('forwards success and error events', () {
      Map<String, dynamic>? success;
      String? error;
      final component = webMountFlow(
        projectId: 'project',
        flowId: 'flow',
        baseUrl: 'https://api.descope.com',
        componentVersion: '1.2.3',
        containerCss: {},
        onReady: () {},
        onSuccess: (detail) => success = detail,
        onError: (message) => error = message,
      );

      final wc = web.document.querySelector('descope-wc')!;
      wc.dispatchEvent(web.CustomEvent('success', web.CustomEventInit(detail: <String, Object?>{'a': <String, Object?>{'b': 1}}.jsify())));
      wc.dispatchEvent(web.CustomEvent('error', web.CustomEventInit(detail: <String, Object?>{'errorMessage': 'oops'}.jsify())));
      component.dispose();

      expect(success, {'a': {'b': 1}});
      expect(error, 'oops');
    });
  });

  test('passkey support can be queried', () {
    expect(() => webIsWebAuthnSupported(), returnsNormally);
    expect(web.document.getElementById('descope-webauthn-script'), isNotNull);
  });
}

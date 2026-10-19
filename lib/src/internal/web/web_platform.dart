// Browser facilities used by the SDK when running on Flutter web.
//
// The web implementation relies on `package:web` and `dart:js_interop`, so it works
// with both the JS and the WebAssembly compilers. On every other platform a stub
// is used, and the SDK never calls into it outside of tests.
export 'web_platform_stub.dart'
    if (dart.library.js_interop) 'web_platform_web.dart';

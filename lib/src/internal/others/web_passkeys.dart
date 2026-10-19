import '/src/internal/others/error.dart';
import '/src/internal/web/web_platform.dart';
import '/src/types/error.dart';

class WebPasskeys {
  bool isSupported() {
    try {
      return webIsWebAuthnSupported();
    } catch (e) {
      throw DescopeException.passkeyFailed.add(message: e.toString());
    }
  }

  String getOrigin() {
    final origin = webOrigin();
    if (origin != null) {
      return origin;
    }
    throw DescopeException.passkeyFailed.add(message: "Unable to get window origin");
  }

  Future<String> passkey(String options, bool create) async {
    try {
      return create ? await webAuthnCreate(options) : await webAuthnGet(options);
    } catch (e) {
      throw DescopeException.passkeyFailed.add(message: e.toString());
    }
  }
}

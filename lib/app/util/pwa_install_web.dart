import 'dart:js' as js;

bool get isPwaWeb => true;

Future<bool> promptPwaInstall() async {
  try {
    final result = js.context.callMethod('papaBearPwaInstall');
    return result == true;
  } catch (_) {
    return false;
  }
}

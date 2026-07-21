import 'package:flutter/services.dart';

class ExternalAppService {
  static const MethodChannel _channel =
      MethodChannel('app_casal_flutter/external_apps');

  static Future<void> openUrl(String url) async {
    await _channel.invokeMethod(
      'openUrl',
      {
        'url': url,
      },
    );
  }
}

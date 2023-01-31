import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'flutter_screenshot_view.dart';

class FlutterScreenshotPlugin {
  static const MethodChannel _channel =
      MethodChannel('flutter_screenshot_plugin');

  static Size _clientSize = const Size(0, 0);

  static Future<Uint8List?> takescreenshot(
      {ScreenshotPosition? position}) async {
    final Uint8List? result;
    if (position != null) {
      result = await _channel.invokeMethod('takescreenshot', {
        "x": position.left?.toInt(),
        "y": position.top?.toInt(),
        "width": position.width?.toInt(),
        "height": position.height?.toInt(),
      });
    } else {
      result = await _channel.invokeMethod('takescreenshot');
    }
    return result;
  }

  static Future<Size> getViewSize() async {
    if (_clientSize.width > 0 && _clientSize.height > 0) {
      return _clientSize;
    }
    final result = await _channel.invokeMethod('getViewSize');
    _clientSize = Size(result['width'] + 0.0, result['height'] + 0.0);
    return _clientSize;
  }
}



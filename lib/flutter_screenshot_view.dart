import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'flutter_screenshot_plugin.dart';

/// 用法：
/// ```
///  ScreenshotController controller = ScreenshotController();
///  ScreenshotView(
///    controller: controller,
///    child: child
/// )
/// ```
///  Uint8List a = await controller.takeScreenshot();
class ScreenshotView extends StatefulWidget {
  const ScreenshotView(
      {Key? key, required this.child, required this.controller})
      : super(key: key);

  final Widget child;
  final ScreenshotController controller;

  @override
  _ScreenshotViewState createState() => _ScreenshotViewState();
}

class _ScreenshotViewState extends State<ScreenshotView>
    with WidgetsBindingObserver {
  final GlobalKey _localKey = GlobalKey();
  late ScreenshotPosition _screenshotPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      RenderBox? renderObject =
          _localKey.currentContext!.findRenderObject() as RenderBox;
      Offset offset = renderObject.localToGlobal(Offset.zero);
      Size? _size = _localKey.currentContext?.size;
      Size viewsize = await FlutterScreenshotPlugin.getViewSize();
      Size screenSize = MediaQuery.of(context).size;
      EdgeInsets padding = MediaQuery.of(context).padding;
      // 兼容有刘海屏/底部导航栏
      // 但是还是存在高度稍微偏大的问题
      // 若需要则强制SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      double vwScale = viewsize.width / (screenSize.width + padding.left + padding.right);
      double vhScale = viewsize.height / (screenSize.height + padding.top + padding.bottom);

      _screenshotPosition = ScreenshotPosition(
          width: _size!.width * vwScale,
          height: _size.height * vhScale,
          top: offset.dy * vhScale,
          left: offset.dx * vwScale);
    });

    widget.controller.addListener(() async {
      print(_screenshotPosition.toJson());
      Uint8List? data = await FlutterScreenshotPlugin.takescreenshot(position: _screenshotPosition);
      widget.controller.$emit(data!);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _localKey,
      child: widget.child,
    );
  }
}

class ScreenshotPosition {
  double? width;
  double? height;
  double? top;
  double? left;
  ScreenshotPosition({this.width, this.height, this.top, this.left});

  toJson() {
    Map<String, String> _json = {};
    _json['width'] = width.toString();
    _json['height'] = height.toString();
    _json['top'] = top.toString();
    _json['left'] = left.toString();
    return _json.toString();
  }
}

class ScreenshotController extends ChangeNotifier {
  Function(Uint8List) _cache = (Uint8List) {};

  $on(Function(Uint8List) cb) {
    _cache = cb;
  }

  $emit(Uint8List data) {
    _cache(data);
  }

  Future<Uint8List> takeScreenshot() {
    notifyListeners();
    Completer<Uint8List> completer = Completer<Uint8List>();
    $on((Uint8List data) {
      completer.complete(data);
    });
    return completer.future;
  }
}
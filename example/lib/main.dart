import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_screenshot_plugin/flutter_screenshot_plugin.dart';
import 'package:flutter_screenshot_plugin/flutter_screenshot_view.dart';
import 'package:fijkplayer/fijkplayer.dart';

void main() {
  runApp(const MyApp());
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isCapture = false;
  Uint8List _uint8list = Uint8List(0);
  FijkPlayer fijkPlayer = FijkPlayer();

  @override
  void initState() {
    super.initState();
    fijkPlayer.setDataSource(
        "https://sf1-hscdn-tos.pstatp.com/obj/media-fe/xgplayer_doc_video/flv/xgplayer-demo-360p.flv",
        autoPlay: true);
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  ScreenshotController controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
          ),
          ScreenshotView(
              controller: controller,
              child: Container(
                width: 400,
                height: 300,
                child: FijkView(
                  player: fijkPlayer,
                  color: Colors.white,
                  fsFit: FijkFit.cover,
                  fit: FijkFit.cover,
                ),
              )),
          GestureDetector(
              onTap: () async {
                Uint8List a = await controller.takeScreenshot();
                _uint8list = a;
                isCapture = true;
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: Colors.blue,
                child: Text('截屏'),
              )),
          Container(
            height: 20,
          ),
          GestureDetector(
              onTap: () async {
                var a = await FlutterScreenshotPlugin.getViewSize();
                print(a);
                print(MediaQuery.of(context).size);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: Colors.blue,
                child: Text('获取窗口大小'),
              )),
          Container(
            height: 20,
          ),
          isCapture
              ? Container(
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3)
                ),
                child: Image.memory(
                  _uint8list,
                  scale: 0.5,
                ),
              )
              : Container()
        ],
      ),
    );
  }
}

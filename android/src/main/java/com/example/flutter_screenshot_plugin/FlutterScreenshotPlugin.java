package com.example.flutter_screenshot_plugin;

import static io.flutter.util.ViewUtils.getActivity;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Picture;
import android.view.View;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.FlutterView;

/** FlutterScreenshotPlugin */
public class FlutterScreenshotPlugin implements FlutterPlugin, MethodCallHandler , ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  Activity activity;
  private Object renderer;

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    //在这里就获取到了activity了
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }
  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_screenshot_plugin");
    channel.setMethodCallHandler(this);
    renderer = flutterPluginBinding.getFlutterEngine().getRenderer();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if (call.method.equals("takescreenshot")) {
      Integer x = call.argument("x");
      Integer y = call.argument("y");
      Integer w = call.argument("width");
      Integer h = call.argument("height");
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      if (w == null) {
        w = 0;
      }
      if (h == null) {
        h = 0;
      }
      byte[] drawByte = handleTakeScreenshot(x,y,w,h);
      result.success(drawByte);
    } else if (call.method.equals("getViewSize")) {
      Map<String, Integer> _map = handleGetViewSize();
      result.success(_map);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
  private Map<String, Integer> handleGetViewSize() {
    Map<String, Integer> _map = new HashMap<String, Integer>();
    View view = this.activity.getWindow().getDecorView();
    Integer width = view.getWidth();
    Integer height = view.getHeight();
    _map.put("width", width);
    _map.put("height", height);
    return _map;
  }
  private byte[] handleTakeScreenshot(Integer x, Integer y, Integer w, Integer h) {
    View view = this.activity.getWindow().getDecorView();
    view.setDrawingCacheEnabled(true); // 设置缓存，可用于实时截图
    Bitmap bitmap = null;
    if (this.renderer.getClass() == FlutterView.class) {
      bitmap = ((FlutterView) this.renderer).getBitmap();
    } else if(this.renderer.getClass() == FlutterRenderer.class ) {
      bitmap = ( (FlutterRenderer) this.renderer ).getBitmap();
    }

    if (w == 0) {
      w = bitmap.getWidth() - x;
    }
    if (h == 0) {
      h = bitmap.getHeight() - y;
    }
//    renderer = new FlutterEngine(activity).getRenderer();
//    bitmap = ((FlutterRenderer) renderer).getBitmap();
    view.setDrawingCacheEnabled(false); // 清空缓存，可用于实时截图
    Bitmap _bitmap = Bitmap.createBitmap(bitmap, x, y, w, h);
    byte[] drawByte = getBitmapByte(_bitmap); // 位图转为 Byte

    return drawByte;
  }
  // 位图转 Byte
  private static byte[] getBitmapByte(Bitmap bitmap){
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    // 参数1转换类型，参数2压缩质量，参数3字节流资源
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
    try {
      out.flush();
      out.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
    return out.toByteArray();
  }

}

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
class ALStringPosition {

  ALStringPosition(Element element, BuildContext parentContext) {
    Text t = element.widget as Text;

    if(t.key is ValueKey<String>) {
      ValueKey<String> vk = t.key as ValueKey<String>;
      this._key = vk.value;
    }

    this._value = t.data;

    Rect bounds = element.globalPaintBoundsTo(parentContext);

    this._x = bounds.left;
    this._y = bounds.top;
    this._width = bounds.width;
    this._height = bounds.height;

  }
  String separator = "";
  String _key;
  String _value;
  double _x = -1;
  double _y = -1;
  double _width = -1;
  double _height = -1;

  String toJson() {

    return "{" + separator +
        (_key != null ? '"key": "' + _key + '",' + separator  : "")+
        (_value != null ? '"value": "' + _value + '",' + separator : "")+
        '"x": ' + _x.toStringAsFixed(0) + "," + separator +
        '"y": ' + _y.toStringAsFixed(0) + "," + separator +
        '"width": ' + _width.toStringAsFixed(0) + "," + separator +
        '"height": ' + _height.toStringAsFixed(0)+ "" + separator +
        "}";

  }
}

extension ApplangaElementEx on Element {
  Rect get globalPaintBounds {
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }

  Rect globalPaintBoundsTo(BuildContext context) {
    var translation = renderObject?.getTransformTo(context.findRenderObject())?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;

      Rect r = renderObject.paintBounds;
      r = r.translate(translation.x, translation.y);
      double scaleX = window.physicalSize.width / width;
      double scaleY = window.physicalSize.height / height;

      double left = r.left * scaleX;
      double right = r.right * scaleX;
      double top = r.top * scaleY;
      double bottom = r.bottom * scaleY;
      Rect r2 = new Rect.fromLTRB(left, top, right, bottom);
      return r2;
    } else {
      return null;
    }
  }
}

extension ApplangaWidgetEx on Widget {
  void setScreenTag(BuildContext context, String tag) {
    ApplangaFlutter.setScreenTag(context, tag);
  }
}

extension ApplangaStateWidgetEx<Widget> on State<StatefulWidget> {
  void setScreenTag(BuildContext context, String tag) {
    ApplangaFlutter.setScreenTag(context, tag);
  }
}

class ApplangaMethodHandler {
  ApplangaMethodHandler(MethodChannel _channel) {
    _channel.setMethodCallHandler(this._callHandler);

  }

  Future<String> _callHandler(MethodCall call) async {
    switch(call.method) {
      case "getStringPositions":
        return ApplangaFlutter.stringPositions;
    }
  }
}
class ApplangaFlutter {


  static bool isSupported = (Platform.isAndroid || Platform.isIOS) && !kIsWeb;

  static const MethodChannel _channel =
  const MethodChannel('applanga_flutter');

  static BuildContext _currentScreenContext = null;
  static String  _currentScreenTag = null;
  static ApplangaMethodHandler _callHandler = null;
  static void setScreenTag(BuildContext context, String tag) {
    _currentScreenContext = context;
    _currentScreenTag = tag;
  }

  static Future<String> getString(String key, String defaultValue) async {

    if(!isSupported)
    {
        return defaultValue;
    }

    final String version = await _channel.invokeMethod('getString', <String, dynamic>{
      'key': key,
      'defaultValue': defaultValue
    });
    return version;
  }

  static Future<bool> isDebuggerConnected() async {
    final bool b = await _channel.invokeMethod('isDebuggerConnected');
    return b;
  }

  static Future<void> showDraftModeDialog() async {
    if(!isSupported)
    {
      return;
    }
    await _channel.invokeMethod('showDraftModeDialog');
  }

  static Future<void> screenshot() async{
    if(!isSupported)
    {
      return;
    }
    return screenshotOf(_currentScreenContext, _currentScreenTag);
  }

  static String getStringPositionsOf(BuildContext context) {
    String stringPositions = '{"ALStringPositions":[';
    void visitor(Element element) {
      if (element.widget is Text) {
        ALStringPosition spos = new ALStringPosition(element, context);
        if (stringPositions != '{"ALStringPositions":[') {
          stringPositions = stringPositions + "," + spos.separator;
        }
        stringPositions = stringPositions + spos.toJson();
      }
      element.visitChildren(visitor);
    }
    context.visitChildElements(visitor);
    stringPositions = stringPositions + "]}\n";
    return stringPositions;
  }

  static String get stringPositions {
    return getStringPositionsOf(_currentScreenContext);
  }

  static void screenshotOf(BuildContext context, String tag) async {
    if(!isSupported)
    {
      return;
    }
    //stringIds.add(stringPositions);
    await captureScreenshotWithTag(tag, false, null);
    //context.visitChildElements(visitor);
  }

  static Future<void> captureScreenshotWithTag(String tag, bool useOcr, List<String> stringIds) async {
    if(!isSupported)
    {
      return;
    }
    return await _channel.invokeMethod('takeScreenshotWithTag',<String, dynamic>{
      'tag': tag,
      'useOcr': useOcr,
      'stringIds': stringIds
    });
  }

  static void setLanguage(String lang){
    if(!isSupported)
    {
      return;
    }
    _channel.invokeMethod('setlanguage',<String, dynamic>{
      'lang': lang
    });
  }

  static Future<Map<String,String>> localizedStringsForCurrentLanguage() async {
    if(!isSupported)
    {
      return null;
    }
    Map<dynamic,dynamic> applangaMap = await _channel.invokeMethod("localizedStringsForCurrentLanguage");

    Map<String,String> result =  Map<String,String>();

    applangaMap.forEach((key,value){
      assert(key.runtimeType == String);
      assert(value.runtimeType == String);
      result.putIfAbsent(key, ()=>value);
    });

    return result;

  }
  static Future<Map<String, Map<String,String>>> localizeMap(Map<String, Map<String, String>> map) async {
    if(!isSupported)
    {
      return map;
    }
    Map<dynamic,dynamic> applangaMap = await _channel.invokeMethod("localizeMap", map);

    //we will return this
    Map<String, Map<String,String>> result =  Map<String, Map<String,String>>();

    applangaMap.forEach((locale,valueMap) {
      assert(locale.runtimeType == String);
      Map<String,String> entriesForLocaleMap = Map<String,String>();
      applangaMap[locale].forEach((key,value){
        assert(key.runtimeType == String);
        assert(value.runtimeType == String);

        entriesForLocaleMap.putIfAbsent(key, ()=>value);
      });
      result.putIfAbsent(locale, ()=>entriesForLocaleMap);
    });

    return result;
  }

  static Future<bool> update() async {
    if(!isSupported)
    {
      return false;
    }
    if(_callHandler == null) {
      _callHandler = new ApplangaMethodHandler(_channel);
    }
    return await _channel.invokeMethod('update');
  }

  static Future<void> setScreenShotMenuVisible(bool visable) async {
    if(!isSupported)
    {
      return;
    }
    if(visable)
    {
      return await _channel.invokeMethod('showScreenShotMenu');
    }
    else
    {
      return await _channel.invokeMethod('hideScreenShotMenu');

    }
  }
}

import 'dart:ui';

import 'package:flutter/widgets.dart';

class ALStringPosition {
  final String separator = "";
  String? _key;
  String? _value;
  double _x = -1;
  double _y = -1;
  double _width = -1;
  double _height = -1;
  final int elementHash;

  String? get key => _key;
  String? get value => _value;

  ALStringPosition(this._key, this._value, this._x, this._y, this._width,
      this._height, this.elementHash);

  ALStringPosition copyWith(
      {String? key,
      String? value,
      double? x,
      double? y,
      double? width,
      double? height}) {
    return ALStringPosition(key ?? _key, value ?? _value, x ?? _x, y ?? _y,
        width ?? _width, height ?? _height, elementHash);
  }

  ALStringPosition.byElementContext(
      Element element, BuildContext parentContext, bool showIdMode)
      : elementHash = element.hashCode {
    Text textElement = element.widget as Text;
    _value = textElement.data;

    if (showIdMode) {
      _key = _value;
    } else if (textElement.key is ValueKey<String>) {
      ValueKey<String> vk = textElement.key as ValueKey<String>;
      _key = vk.value;
    }

    Rect? bounds = globalPaintBoundsTo(parentContext, element);

    if (bounds != null) {
      _x = bounds.left;
      _y = bounds.top;
      _width = bounds.width;
      _height = bounds.height;
    }
  }

  Rect? globalPaintBoundsTo(BuildContext context, Element element) {
    var translation = element.renderObject
        ?.getTransformTo(context.findRenderObject())
        .getTranslation();
    if (translation != null) {
      try {
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;

        Rect r = element.renderObject!.paintBounds;
        r = r.translate(translation.x, translation.y);
        double scaleX = window.physicalSize.width / width;
        double scaleY = window.physicalSize.height / height;

        double left = r.left * scaleX;
        double right = r.right * scaleX;
        double top = r.top * scaleY;
        double bottom = r.bottom * scaleY;
        Rect r2 = Rect.fromLTRB(left, top, right, bottom);
        return r2;
      } catch (e) {
        debugPrint("globalPaintBoundsTo() error");
        debugPrint(e.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  static String listToJsonString(List<ALStringPosition> positions) {
    String stringPositions = '';
    for (final position in positions) {
      stringPositions += ',${position.separator}${position.toJson()}';
    }
    if (stringPositions.isNotEmpty) {
      stringPositions = stringPositions.substring(1);
    }
    return '{"ALStringPositions":[$stringPositions]}\n';
  }

  static List<String> listToStringIdList(List<ALStringPosition> positions) {
    return positions
        .where((element) => element.key != null)
        .map((e) => e.key!)
        .toList();
  }

  String toJson() {
    return "{" +
        separator +
        (_key != null ? '"key": "' + _key! + '",' + separator : "") +
        (_value != null ? '"value": "' + _value! + '",' + separator : "") +
        '"x": ' +
        _x.toStringAsFixed(0) +
        "," +
        separator +
        '"y": ' +
        _y.toStringAsFixed(0) +
        "," +
        separator +
        '"width": ' +
        _width.toStringAsFixed(0) +
        "," +
        separator +
        '"height": ' +
        _height.toStringAsFixed(0) +
        "" +
        separator +
        "}";
  }
}

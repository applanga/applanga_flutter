import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/material.dart';

mixin ApplangaScreenshotScopeMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ApplangaFlutter.I.registerState(this);
  }

  @override
  void dispose() {
    super.dispose();
    ApplangaFlutter.I.disposeState(this);
  }
}

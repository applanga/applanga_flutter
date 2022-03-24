import 'package:applanga_flutter/src/applanga_screenshot_scope_mixin.dart';
import 'package:flutter/material.dart';

class ApplangaScreenshotScope extends StatefulWidget {
  final Widget child;

  const ApplangaScreenshotScope({Key? key, required this.child})
      : super(key: key);

  String childToStringShort() => child.toStringShort();

  @override
  State<ApplangaScreenshotScope> createState() =>
      _ApplangaScreenshotScopeState();
}

class _ApplangaScreenshotScopeState extends State<ApplangaScreenshotScope>
    with ApplangaScreenshotScopeMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

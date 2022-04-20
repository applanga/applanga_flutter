import 'dart:async';

import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/widgets.dart';

final repaintBoundryKey = GlobalKey<_ApplangaWidgetState>();

class ApplangaWidget extends StatefulWidget {
  final Widget child;

  const ApplangaWidget({Key? key, required this.child}) : super(key: key);

  @override
  _ApplangaWidgetState createState() => _ApplangaWidgetState();
}

class _ApplangaWidgetState extends State<ApplangaWidget>
    with ApplangaScreenshotScopeMixin {
  Future<void> rebuild() {
    Completer completer = Completer();
    _rebuildAll(context);
    setState(() {});
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      completer.complete();
    });
    return completer.future;
  }

  void _rebuildAll(BuildContext context) {
    void rebuildElement(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuildElement);
    }

    (context as Element).visitChildren(rebuildElement);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundryKey,
      child: ApplangaInherited(state: this, child: widget.child),
    );
  }
}

class ApplangaInherited extends InheritedWidget {
  const ApplangaInherited({
    Key? key,
    required this.state,
    required Widget child,
  }) : super(key: key, child: child);

  final _ApplangaWidgetState state;

  Future<void> rebuild() => state.rebuild();

  static ApplangaInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApplangaInherited>();
  }

  @override
  bool updateShouldNotify(ApplangaInherited oldWidget) {
    return true;
  }
}

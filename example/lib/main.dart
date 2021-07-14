import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localisations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        const ApplangaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en'), const Locale('de')],
      home: new App(),
    );
  }
}

class App extends StatefulWidget {
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<App> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initApplanga();
  }

  Future<void> initApplanga() async {
    await ApplangaFlutter.update();
    await ApplangaLocalizations.of(context).localizeMap();
    setState(() {
      //do nothing just rebuild widget tree
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    setScreenTag(context, "test");
    return MaterialApp(
      home: Scaffold(
        appBar: new AppBar(
          //title: new Text(DemoLocalizations.of(context).title),
          title: new Text(ApplangaLocalizations.of(context).get("title"),
              key: Key("title")),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  ApplangaFlutter.showDraftModeDialog();
                },
                child: FutureBuilder<String>(
                    future: ApplangaFlutter.getString("show_draft_mode_dialog", "nothing"),
                    builder: (context, data) {
                      return Text(data.hasData
                          ? data.data.replaceAll("%arg", "draft")
                          : "");
                    }),
              ),
              TextButton(
                onPressed: () {
                  ApplangaFlutter.setScreenShotMenuVisible(true);
                },
                child: Text(
                    ApplangaLocalizations.of(context).get("showScreenShotMenu"),key: Key("showScreenShotMenu"),
                ),
              ),
              TextButton(
                onPressed: () {
                  ApplangaFlutter.setScreenShotMenuVisible(false);
                },
                child: Text(
                    ApplangaLocalizations.of(context).get("hideScreenShotMenu"),key: Key("hideScreenShotMenu"),
                ),
              ),
              TextButton(
                onPressed: () {
                  ApplangaFlutter.captureScreenshotWithTag("test");
                },
                child: Text(
                  ApplangaLocalizations.of(context)
                      .get("takeProgramaticScreenshot"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondRoute()),
                  );
                },
                key: Key("OpenSecondPage"),
                child: Text("Open Second View"),
              ),
              TextButton(
                onPressed: () async {
                  await ApplangaLocalizations.of(context).enableShowIdMode();
                  setState(() {});
                },
                child: Text("enable show id mode"),
              ),
              TextButton(
                onPressed: () async {
                  await ApplangaLocalizations.of(context).disableShowIdMode();
                  setState(() {});
                },
                child: Text("disable show id mode"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setScreenTag(context, "test2");
    return Scaffold(
      appBar: AppBar(
        title: Text(ApplangaLocalizations.of(context).get("secondPageTitle"),
            key: Key("secondPageTitle")),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: Text(
            ApplangaLocalizations.of(context).get("hello_world"),
            key: Key("hello_world"),
          ),
        ),
      ),
    );
  }
}

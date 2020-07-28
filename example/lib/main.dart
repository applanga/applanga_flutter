import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:applanga_flutter/applanga_flutter.dart';
import 'localisations.dart';

void main() {
  runApp(new Demo());
}

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        const ApplangaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('de')
      ],
      // Watch out: MaterialApp creates a Localizations widget
      // with the specified delegates. DemoLocalizations.of()
      // will only find the app's Localizations widget if its
      // context is a child of the app.
      home: new DemoApp(),
    );
  }
}

class DemoApp extends StatefulWidget {
  DemoAppState createState() => new DemoAppState();
}
class DemoAppState extends State<DemoApp>{

  void _applangaUpdate() async{
    await ApplangaFlutter.update();
    await ApplangaLocalizations.of(context).localizeMap();
    setState(() {
      //do nothing just rebuild widget tree -> important
    });
  }

  void initState() {
    super.initState();
    _applangaUpdate();
  }

  @override
  Widget build(BuildContext context) {
    setScreenTag(context,"test");
    return new Scaffold(
      appBar: new AppBar(
        //title: new Text(DemoLocalizations.of(context).title),
        title: new Text(ApplangaLocalizations.of(context).get("hello_world")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                    ApplangaFlutter.showDraftModeDialog();
              },
              child: Text(
                ApplangaLocalizations.of(context).get("draftModeLabel"),
              ),

            ),
            FlatButton(
              onPressed: () {
                ApplangaFlutter.setScreenShotMenuVisible(true);
              },
              child: Text(
                  ApplangaLocalizations.of(context).get("showScreenShotMenu")
              ),

            ),
            FlatButton(
              onPressed: () {
                ApplangaFlutter.setScreenShotMenuVisible(false);
              },
              child: Text(
                  ApplangaLocalizations.of(context).get("hideScreenShotMenu")
              ),
            ),
            FlatButton(
              onPressed: () {
                ApplangaFlutter.captureScreenshotWithTag("test",true,null);
              },
              child: Text(
                  ApplangaLocalizations.of(context).get("takeProgramaticScreenshot")
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondRoute()),
                );
              },
              key: Key("OpenSecondPage"),
              child: Text(
                  "Open Second View"
              ),
            )
          ],
        ),
      ),
    );
  }

}
class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setScreenTag(context,"test2");
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Route"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: Text(ApplangaLocalizations.of(context).get("secondPageTitle")),
        ),
      ),
    );
  }
}
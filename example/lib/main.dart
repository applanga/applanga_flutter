import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:example/generated/applanga_localizations.dart';
import 'package:example/second_page.dart';
import 'package:flutter/material.dart';
import 'package:example/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  final Locale? startupLocale;

  const MyApp({Key? key, this.startupLocale}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.startupLocale;
  }

  @override
  Widget build(BuildContext context) {
    return ApplangaWidget(
      child: Column(
        children: [
          Expanded(
            child: MaterialApp(
              title: 'Flutter Demo',
              locale: _currentLocale,
              localizationsDelegates:
                  ApplangaLocalizations.localizationsDelegates,
              supportedLocales: ApplangaLocalizations.supportedLocales,
              localeListResolutionCallback:
                  ApplangaLocalizations.localeListResolutionCallback,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const MyHomePage(),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 8,
              children: ApplangaLocalizations.supportedLocales
                  .map(
                    (locale) => ElevatedButton(
                      child: Text(locale.toString(),
                          style: TextStyle(
                              fontWeight: (_currentLocale == locale)
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                          textScaler: TextScaler.linear(
                              (_currentLocale == locale) ? 1.3 : 1)),
                      onPressed: () {
                        setState(() {
                          _currentLocale = locale;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with ApplangaScreenshotScopeMixin {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // pass the context to the Applanga instance on every screen/page
    // it's used for screenshot string position detection
    //
    // ApplangaFlutter.I.setContext(context);
    //                or
    // ApplangaFlutter.instance.setContext(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).homePageTitle(DateTime.now()),
          key: const ValueKey('homePageTitle'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)
                  .youHavePushedTheButtonXTimes(_counter, 'thumb'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SecondPage(),
                ));
              },
              label: Text(AppLocalizations.of(context).goToSecondPage),
              icon: const Icon(Icons.arrow_forward),
            ),
            Text(ApplangaFlutter.I.getTranslation("dynamic_string_test") ??
                "dynamic string not loaded.")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: AppLocalizations.of(context).increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}

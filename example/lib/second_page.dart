import 'package:applanga_flutter/applanga_flutter.dart';
import 'package:flutter/material.dart';
import 'package:example/l10n/app_localizations.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApplangaScreenshotScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).secondPageTitle),
        ),
        body: Center(
          child: Text(
            AppLocalizations.of(context).helloFromSecondPage,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

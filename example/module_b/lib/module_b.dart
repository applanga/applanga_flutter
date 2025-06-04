import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:module_b/l10n/gen/module_b_localizations.dart';

class ModuleB extends StatefulWidget {
  const ModuleB({super.key});

  @override
  State<ModuleB> createState() => _ModuleBState();
}

class _ModuleBState extends State<ModuleB> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: ModuleBLocalizations.localizationsDelegates,
      supportedLocales: ModuleBLocalizations.supportedLocales,
      title: 'Module B',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}


class ModuleBHomePage extends StatefulWidget {
  const ModuleBHomePage({super.key});

  @override
  State<ModuleBHomePage> createState() => _ModuleBHomePageState();
}

class _ModuleBHomePageState extends State<ModuleBHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module A Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(ModuleBLocalizations.of(context).welcome),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}

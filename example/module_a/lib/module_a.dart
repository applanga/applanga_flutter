import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:module_a/l10n/gen/module_a_localizations.dart';

class ModuleA extends StatefulWidget {
  const ModuleA({super.key});

  @override
  State<ModuleA> createState() => _ModuleAState();
}

class _ModuleAState extends State<ModuleA> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: ModuleALocalizations.localizationsDelegates,
      supportedLocales: ModuleALocalizations.supportedLocales,
      title: 'Module A',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ModuleAHomePage(),
    );
  }
}

class ModuleAHomePage extends StatefulWidget {
  const ModuleAHomePage({super.key});

  @override
  State<ModuleAHomePage> createState() => _ModuleAHomePageState();
}

class _ModuleAHomePageState extends State<ModuleAHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module A Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(ModuleALocalizations.of(context).welcome),
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

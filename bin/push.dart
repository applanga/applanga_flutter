library applanga_flutter;

import 'package:applanga_flutter/src/applanga_exception.dart';
import 'package:applanga_flutter/src/cli/applanga_cli.dart';

Future<void> main(List<String> args) async {
  try {
    var cli = await ApplangaCli.createAsync();
    cli.push(args);
  } on ApplangaCliNotFoundException {
    /* ignore */
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

class Utils {
  static final _bluePen = AnsiPen()..blue(bold: true);
  static final _greenPen = AnsiPen()..green(bold: true);
  static final _redPen = AnsiPen()..red(bold: true);
  static final _whitePen = AnsiPen()..white(bold: false);

  static void writeLn(String msg) {
    stdout.writeln(_whitePen(msg));
  }

  static void actionWriteLn(String msg) {
    stdout.writeln(_bluePen("\n-> $msg"));
  }

  static void errorWriteLn(String msg) {
    stderr.writeln(_redPen("\n-> $msg"));
  }

  static void successWriteLn(String msg){
    stdout.writeln(_greenPen("\n-> $msg"));
  }

  static void forwardProcessOutput(Process process) {
    process.stdout.transform(utf8.decoder).forEach((line) {
      writeLn(line);
    });
    process.stderr.transform(utf8.decoder).forEach((line) {
      errorWriteLn(line);
    });
  }
}

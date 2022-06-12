import 'dart:io';

import 'package:process_run/process_run.dart';

bool _isWindows = Platform.isWindows;

bool _trim(String line) {
  return line.trim() != '';
}

Task _mapLine(String line) {
  return Task(line.trim().split(RegExp(r"\s+")), line);
}

class SystemTasks {
  static Future<bool> isProgramRunning(String name) async {
    List<Task> tasks = await SystemTasks.tasks();
    return tasks.where((element) => element.pname.toLowerCase().endsWith(name.toLowerCase())).isNotEmpty;
  }

  static Future<bool> isKyberRunning() async {
    List<Task> tasks = await SystemTasks.tasks();
    bool kyber = tasks.where((element) => element.pname.toLowerCase().contains("kyber")).isNotEmpty;
    bool bf2 = tasks.where((element) => element.pname.toLowerCase().endsWith("starwarsbattlefrontii.exe")).isNotEmpty;
    return kyber && bf2;
  }

  static Future<List<Task>> tasks() async {
    try {
      var r = await Process.run(_isWindows ? "tasklist" : "ps aux", [], runInShell: false);
      if (r.stdout != null) {
        String stdout = r.stdout.toString();
        List tasks = stdout.split("\n").where(_trim).map(_mapLine).toList();
        tasks = tasks.where((e) => (_isWindows ? tasks.indexOf(e) > 1 : tasks.indexOf(e) > 0)).toList();
        return List<Task>.from(tasks);
      } else {
        return List<Task>.generate(0, (i) => const Task([""], ""));
      }
    } catch (e) {
      rethrow;
    }
  }
}

class Task {
  final List<String> p;
  final String line;

  String get pname => _isWindows ? p[0] : p[10];

  String get pid => p[1];

  const Task(this.p, this.line);

  Future<ProcessResult> kill() {
    String command = _isWindows ? "taskkill /PID $pid /TF" : "kill -s 9 $pid";
    return runExecutableArguments(command, []);
  }

  Future<ProcessResult> killLikes() {
    String command = _isWindows ? "TASKKILL /F /IM $pname /T" : "pkill -9 $pname";
    return runExecutableArguments(command, []);
  }

  Future<ProcessResult> start() {
    return runExecutableArguments(pname.replaceAll(RegExp(r"\.exe$"), ""), []);
  }

  Future<void> reStart() async {
    try {
      await kill();
      await start();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> reStartLikes() async {
    try {
      await killLikes();
      await start();
    } catch (error) {
      rethrow;
    }
  }

  @override
  String toString() {
    return line;
  }
}

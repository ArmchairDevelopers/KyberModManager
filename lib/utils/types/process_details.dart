class ProcessDetails {
  ProcessDetails(this.pid, this.name, String memory) {
    _memory = int.tryParse(memory) ?? 0;
  }

  final int pid;

  final String name;

  late final int _memory;

  late final String? memoryUnits;

  int get memory => _memory;
}

class ProcessModules {
  ProcessModules({required this.modulesLength, required this.modules});

  final int modulesLength;
  final List<String> modules;
}

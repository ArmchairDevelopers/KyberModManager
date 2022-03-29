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

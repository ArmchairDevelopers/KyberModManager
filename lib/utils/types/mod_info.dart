class ModInfo {
  String name;
  String version;

  @override
  toString() => '$name ($version)';

  ModInfo({required this.name, required this.version});
}

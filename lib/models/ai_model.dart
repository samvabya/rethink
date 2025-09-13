class AIModel {
  final String id;
  final String name;
  final String provider;
  final bool isPlus;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    this.isPlus = false,
  });

  @override
  String toString() => name;
}

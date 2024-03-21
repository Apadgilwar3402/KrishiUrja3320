
extension Utils on String {
  bool get isNotEmpty => this.isNotEmpty;

  bool get isEmpty => this.isEmpty;

  bool get isNotNull => this != null;

  bool get isNull => this == null;

  bool get isNullOrEmpty => isNull || isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String orDefault(String defaultValue) =>
      isNullOrEmpty ? defaultValue : this;

  List<String> splitLines() =>
      this.split('\n').where((line) =>line.isNotEmpty).toList();
}
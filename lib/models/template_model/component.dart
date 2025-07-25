class Component {
  Component();

  factory Component.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Component.fromJson($json) is not implemented');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

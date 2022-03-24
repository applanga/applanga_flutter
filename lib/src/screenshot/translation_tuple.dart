class TranslationTuple {
  final String key;
  final String? value;

  TranslationTuple(this.key, this.value);

  @override
  String toString() {
    return "TranslationTuple: { key: $key, value: $value }";
  }
}

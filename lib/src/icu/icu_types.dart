enum IcuElementType { literal, argument, plural, gender, select }

class IcuArgument {
  String name;

  IcuArgument(this.name);

  @override
  bool operator ==(Object other) {
    return other is IcuArgument && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

class IcuOption {
  String name;
  List<IcuBaseElement> value;

  IcuOption(this.name, this.value);
}

abstract class IcuBaseElement {
  IcuElementType type;
  String value;

  IcuBaseElement(this.type, this.value);
}

class IcuLiteralElement extends IcuBaseElement {
  IcuLiteralElement(String value) : super(IcuElementType.literal, value);
}

class IcuArgumentElement extends IcuBaseElement {
  IcuArgumentElement(String value) : super(IcuElementType.argument, value);
}

class IcuSelectElement extends IcuBaseElement {
  List<IcuOption> options;

  IcuSelectElement(String value, this.options)
      : super(IcuElementType.select, value);
}

class IcuPluralElement extends IcuBaseElement {
  List<IcuOption> options;

  IcuPluralElement(String value, this.options)
      : super(IcuElementType.plural, value);
}

class IcuGenderElement extends IcuBaseElement {
  List<IcuOption> options;

  IcuGenderElement(String value, this.options)
      : super(IcuElementType.gender, value);
}

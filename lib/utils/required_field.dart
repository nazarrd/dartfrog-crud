class RequiredModel {
  RequiredModel({
    required this.key,
    required this.value,
    required this.type,
    this.length,
  });

  String key;
  dynamic value;
  Type type;
  int? length;
}

String requiredField(List<RequiredModel> fields) {
  final nullFields = <String>[];
  final invalidFields = <String>[];
  final lengthFields = <String>[];

  for (final field in fields) {
    if (field.value == null) {
      nullFields.add('${field.key}(${field.type})');
    } else {
      if (field.length != null && '${field.value}'.length < field.length!) {
        lengthFields.add('${field.key}(${field.type}-${field.length})');
      }
      if (field.value.runtimeType != field.type) {
        invalidFields.add('${field.key}(${field.type})');
      }
    }
  }

  final nullText =
      nullFields.isNotEmpty ? '${nullFields.join(', ')} field is required' : '';
  final invalidText = invalidFields.isNotEmpty
      ? '${invalidFields.join(', ')} type is invalid'
      : '';
  final lengthText = lengthFields.isNotEmpty
      ? '${lengthFields.join(', ')} insufficient number of characters'
      : '';
  final segments = <String>[
    if (nullText.isNotEmpty) nullText,
    if (invalidText.isNotEmpty) invalidText,
    if (lengthText.isNotEmpty) lengthText,
  ];
  final errorMessage = segments.join(' & ').trim().replaceAll('  ', ' ');
  return errorMessage.isNotEmpty ? '$errorMessage.' : '';
}

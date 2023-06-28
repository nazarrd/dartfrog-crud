class GeneralModel {
  GeneralModel({this.code, this.message, this.data});

  GeneralModel.fromJson(Map<String, dynamic> json) {
    code = json['code'] as int?;
    message = json['message'] as String?;
    if (json['data'] != null) data = json['data'] as Map<String, dynamic>?;
  }
  int? code;
  String? message;
  Map<String, dynamic>? data;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code ?? 200;
    data['message'] = message;
    if (data['data'] != null) data['data'] = data;
    return data;
  }
}

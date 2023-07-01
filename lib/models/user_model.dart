import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  UserModel({
    this.id,
    this.name,
    this.username,
    this.password,
    this.photo,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as ObjectId?;
    name = json['name'] as String?;
    username = json['username'] as String?;
    password = json['password'] as String?;
    photo = json['photo'] as String?;
  }
  ObjectId? id;
  String? name;
  String? username;
  String? password;
  String? photo;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['password'] = password;
    data['photo'] = photo;
    return data;
  }
}

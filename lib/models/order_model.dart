import 'package:mongo_dart/mongo_dart.dart';

class OrderModel {
  OrderModel({
    this.id,
    this.userId,
    this.pizzaId,
    this.address,
    this.phoneNumber,
    this.status,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as ObjectId?;
    userId = json['user_id'] as String?;
    pizzaId = json['pizza_id'] as String?;
    address = json['address'] as String?;
    phoneNumber = json['phone_number'] as String?;
    status = json['status'] as String?;
  }
  ObjectId? id;
  String? userId;
  String? pizzaId;
  String? address;
  String? phoneNumber;
  String? status;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['pizza_id'] = pizzaId;
    data['address'] = address;
    data['phone_number'] = phoneNumber;
    data['status'] = status;
    return data;
  }
}

import 'package:mongo_dart/mongo_dart.dart';

class ProductData {
  ProductData({
    this.id,
    this.name,
    this.description,
    this.image,
    this.price,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as ObjectId?;
    name = json['name'] as String?;
    description = json['description'] as String?;
    image = json['image'] as String?;
    price = json['price'] as int?;
  }
  ObjectId? id;
  String? name;
  String? description;
  String? image;
  int? price;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['image'] = image;
    data['price'] = price;
    return data;
  }
}

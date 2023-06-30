import 'dart:convert';

import 'package:crud/models/product_model.dart';
import 'package:crud/services/database.dart';
import 'package:crud/utils/dlog.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method == HttpMethod.post) {
    return Database.connectDb(createProduct(context));
  } else if (method == HttpMethod.get) {
    return Database.connectDb(readProduct(context));
  } else if (method == HttpMethod.patch) {
    return Database.connectDb(updateProduct(context));
  } else if (method == HttpMethod.delete) {
    return Database.connectDb(deleteProduct(context));
  }
  return Response.json(statusCode: 405);
}

Future<Response> createProduct(RequestContext context) async {
  try {
    // Set the connection
    final collection = await Database.getCollection('products');

    // Parse the request body to retrieve the product data
    final requestBody =
        jsonDecode(await context.request.body()) as Map<String, dynamic>?;

    // Create a new document with the product data
    final product = ProductModel(
      name: requestBody?['name'] as String?,
      description: requestBody?['description'] as String?,
      image: requestBody?['image'] as String?,
      price: requestBody?['price'] as int?,
    );

    // Insert the new document into the collection
    final result = await collection.insertOne(product.toJson()..remove('id'));
    if (result.isSuccess) {
      // Product added successfully
      return Response.json(
        body: {
          'code': 200,
          'message': 'create product successfully',
          'data': product.toJson()..['id'] = result.id as ObjectId?
        },
      );
    }

    return Response.json(
      body: {'code': 500, 'message': 'failed to create product'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> readProduct(RequestContext context) async {
  try {
    // set the connection
    final collection = await Database.getCollection('products');

    // check if query parameter is present
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final doc = await collection
          .findOne(where.eq('_id', ObjectId.parse(params['id']!)));
      if (doc != null && doc.isNotEmpty) {
        return Response.json(
          body: {
            'code': 200,
            'message': 'get product by id successfully',
            'data': ProductModel.fromJson(doc).toJson(),
          },
        );
      } else {
        return Response.json(
          body: {'code': 404, 'message': 'product not found'},
        );
      }
    } else {
      final doc = await collection.find().toList();
      return Response.json(
        body: {
          'code': 200,
          'message': 'get all product successfully',
          'data': doc.map(ProductModel.fromJson).toList(),
        },
      );
    }
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> updateProduct(RequestContext context) async {
  try {
    // Get the product ID from the request parameters
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final productId = ObjectId.parse(params['id']!);

      // Get the updated fields from the request body
      final updatedFields =
          jsonDecode(await context.request.body()) as Map<String, dynamic>?;

      // Fetch the product from the database
      final collection = await Database.getCollection('products');
      final product = await collection.findOne(where.eq('_id', productId));

      if (product != null) {
        // Update the price field if it exists in the updated fields
        final newProduct = ProductModel(
          name: (updatedFields?['name'] ?? product['price']) as String?,
          description: (updatedFields?['description'] ?? product['description'])
              as String?,
          image: (updatedFields?['image'] ?? product['image']) as String?,
          price: (updatedFields?['price'] ?? product['price']) as int?,
        );

        // Update the product in the database
        await collection.updateOne(
          where.eq('_id', productId),
          modify
              .set('name', newProduct.name)
              .set('description', newProduct.description)
              .set('image', newProduct.image)
              .set('price', newProduct.price),
        );

        return Response.json(
          body: {
            'code': 200,
            'message': 'product updated successfully',
            'data': newProduct.toJson()..['id'] = product['_id'] as ObjectId?
          },
        );
      }

      return Response.json(body: {'code': 404, 'message': 'product not found'});
    }
    return Response.json(body: {'code': 404, 'message': 'product not found'});
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> deleteProduct(RequestContext context) async {
  try {
    // set the connection
    final collection = await Database.getCollection('products');

    // check if query parameter is present
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final doc = await collection
          .remove(where.eq('_id', ObjectId.parse(params['id']!)));
      if (doc['n'] != 0) {
        return Response.json(
          body: {'code': 200, 'message': 'product delete successfully'},
        );
      }
    }
    return Response.json(body: {'code': 404, 'message': 'product not found'});
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

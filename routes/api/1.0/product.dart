import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../models/product_model.dart';
import '../../../services/db_services.dart';
import '../../../utils/dlog.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method == HttpMethod.post) {
    return DbService.startConnection(context, createProduct(context));
  } else if (method == HttpMethod.get) {
    return DbService.startConnection(context, readProduct(context));
  } else if (method == HttpMethod.patch) {
    return DbService.startConnection(context, updateProduct(context));
  } else if (method == HttpMethod.delete) {
    return DbService.startConnection(context, deleteProduct(context));
  }
  return Response.json(statusCode: 405);
}

Future<Response> readProduct(RequestContext context) async {
  try {
    // set the connection
    final collection = await DbService.getCollection('products');

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
            'data': ProductData.fromJson(doc).toJson(),
          },
        );
      } else {
        return Response.json(
          statusCode: 404,
          body: {'code': 404, 'message': 'product not found'},
        );
      }
    } else {
      final doc = await collection.find().toList();
      return Response.json(
        body: {
          'code': 200,
          'message': 'get all product successfully',
          'data': doc.map(ProductData.fromJson).toList(),
        },
      );
    }
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> createProduct(RequestContext context) async {
  try {
    // Set the connection
    final collection = await DbService.getCollection('products');

    // Parse the request body to retrieve the product data
    final requestBody =
        jsonDecode(await context.request.body()) as Map<String, dynamic>?;

    // Create a new document with the product data
    final product = ProductData(
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
      statusCode: 500,
      body: {'code': 500, 'message': 'failed to create product'},
    );
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
      final collection = await DbService.getCollection('products');
      final product = await collection.findOne(where.eq('_id', productId));

      if (product != null) {
        // Update the price field if it exists in the updated fields
        final newProduct = ProductData(
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

      return Response.json(
        statusCode: 404,
        body: {'code': 404, 'message': 'product not found'},
      );
    }
    return Response.json(
      statusCode: 404,
      body: {'code': 404, 'message': 'product not found'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> deleteProduct(RequestContext context) async {
  try {
    // set the connection
    final collection = await DbService.getCollection('products');

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
    return Response.json(
      statusCode: 404,
      body: {'code': 404, 'message': 'product not found'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

import 'dart:convert';

import 'package:crud/models/user_model.dart';
import 'package:crud/services/database.dart';
import 'package:crud/services/secure.dart';
import 'package:crud/utils/dlog.dart';
import 'package:crud/utils/required_field.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  if (method == HttpMethod.post) {
    return Database.connectDb(createUser(context));
  } else if (method == HttpMethod.get) {
    return Database.connectDb(readUser(context));
  } else if (method == HttpMethod.patch) {
    return Database.connectDb(updateUser(context));
  } else if (method == HttpMethod.delete) {
    return Database.connectDb(deleteUser(context));
  }
  return Response.json(statusCode: 405);
}

Future<Response> createUser(RequestContext context) async {
  try {
    // Set the connection
    final collection = await Database.getCollection('users');

    // Parse the request body to retrieve the user data
    final requestBody =
        jsonDecode(await context.request.body()) as Map<String, dynamic>?;

    // Create a new document with the user data
    late UserModel user;
    final name = requestBody?['name'];
    final username = requestBody?['username'];
    final password = requestBody?['password'];

    // check required input
    final validator = requiredField([
      RequiredModel(key: 'name', value: name, type: String),
      RequiredModel(key: 'username', value: username, type: String, length: 3),
      RequiredModel(key: 'password', value: password, type: String, length: 8),
    ]);
    if (validator.isEmpty) {
      if (password.toString().length < 8) {
        return Response.json(
          body: {
            'code': 411,
            'message': 'password(String) must be at least 8 character'
          },
        );
      }
      user = UserModel(
        name: name as String?,
        username: username as String?,
        password: Secure().encyptPassword('$password'),
        photo: requestBody?['photo'] as String?,
      );
      final doc = await collection.findOne(where.eq('username', username));
      if (doc != null && doc.isNotEmpty) {
        return Response.json(
          body: {'code': 409, 'message': 'username has been taken'},
        );
      }
    } else {
      return Response.json(body: {'code': 411, 'message': validator});
    }

    // Insert the new document into the collection
    final result = await collection.insertOne(user.toJson()..remove('id'));
    if (result.isSuccess) {
      // User added successfully
      return Response.json(
        body: {
          'code': 200,
          'message': 'create user successfully',
          'data': user.toJson()..['id'] = result.id as ObjectId?
        },
      );
    }

    return Response.json(
      body: {'code': 500, 'message': 'failed to create user'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> readUser(RequestContext context) async {
  try {
    // set the connection
    final collection = await Database.getCollection('users');

    // check if query parameter is present
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final doc = await collection
          .findOne(where.eq('_id', ObjectId.parse(params['id']!)));
      if (doc != null && doc.isNotEmpty) {
        return Response.json(
          body: {
            'code': 200,
            'message': 'get user by id successfully',
            'data': UserModel.fromJson(doc).toJson(),
          },
        );
      } else {
        return Response.json(
          statusCode: 404,
          body: {'code': 404, 'message': 'user not found'},
        );
      }
    } else {
      final doc = await collection.find().toList();
      return Response.json(
        body: {
          'code': 200,
          'message': 'get all user successfully',
          'data': doc.map(UserModel.fromJson).toList(),
        },
      );
    }
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> updateUser(RequestContext context) async {
  try {
    // Get the user ID from the request parameters
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final userId = ObjectId.parse(params['id']!);

      // Get the updated fields from the request body
      final updatedFields =
          jsonDecode(await context.request.body()) as Map<String, dynamic>?;

      // Fetch the user from the database
      final collection = await Database.getCollection('users');
      final user = await collection.findOne(where.eq('_id', userId));

      if (user != null) {
        // check required input
        final newPassword = updatedFields?['password'];
        if (newPassword != null) {
          final validator = requiredField([
            RequiredModel(
              key: 'password',
              value: updatedFields?['password'],
              type: String,
              length: 8,
            ),
          ]);
          if (validator.isNotEmpty) {
            return Response.json(body: {'code': 411, 'message': validator});
          }
        }

        // Update the price field if it exists in the updated fields
        final newUser = UserModel(
          name: (updatedFields?['name'] ?? user['price']) as String?,
          username: (updatedFields?['username'] ?? user['username']) as String?,
          password: newPassword == null
              ? user['password'] as String?
              : Secure().encyptPassword('${updatedFields?['password']}'),
          photo: (updatedFields?['photo'] ?? user['photo']) as String?,
        );

        // Update the user in the database
        await collection.updateOne(
          where.eq('_id', userId),
          modify
              .set('name', newUser.name)
              .set('username', newUser.username)
              .set('password', newUser.password)
              .set('photo', newUser.photo),
        );

        return Response.json(
          body: {
            'code': 200,
            'message': 'user updated successfully',
            'data': newUser.toJson()..['id'] = user['_id'] as ObjectId?
          },
        );
      }

      return Response.json(
        statusCode: 404,
        body: {'code': 404, 'message': 'user not found'},
      );
    }
    return Response.json(
      statusCode: 404,
      body: {'code': 404, 'message': 'user not found'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

Future<Response> deleteUser(RequestContext context) async {
  try {
    // set the connection
    final collection = await Database.getCollection('users');

    // check if query parameter is present
    final params = context.request.uri.queryParameters;
    if (params.containsKey('id')) {
      final doc = await collection
          .remove(where.eq('_id', ObjectId.parse(params['id']!)));
      if (doc['n'] != 0) {
        return Response.json(
          body: {'code': 200, 'message': 'user delete successfully'},
        );
      }
    }
    return Response.json(
      statusCode: 404,
      body: {'code': 404, 'message': 'user not found'},
    );
  } catch (error, stacktrace) {
    dlog('$error, $stacktrace');
    return Response.json(statusCode: 500);
  }
}

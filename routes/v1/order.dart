import 'package:crud/models/order_model.dart';
import 'package:crud/services/database.dart';
import 'package:crud/utils/dlog.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return Database.connectDb(readOrder(context));
  }
  return Response.json(statusCode: 405);
}

Future<Response> readOrder(RequestContext context) async {
  try {
    // set the connection
    final collection = await Database.getCollection('orders');

    // check if user_id is present
    final params = context.request.uri.queryParameters;
    if (params.containsKey('user_id')) {
      final userId = params['user_id'];
      final doc = await collection.find(where.eq('user_id', userId)).toList();
      final userOrders = doc.map(OrderModel.fromJson).toList();
      if (userOrders.isNotEmpty) {
        return Response.json(
          body: {'code': 200, 'message': 'success', 'data': userOrders},
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

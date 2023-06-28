import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import '../config/app_config.dart';
import '../models/general_model.dart';

List<({int code, String status})> handledCode = [
  (code: 400, status: 'bad request'),
  (code: 404, status: 'route not found'),
  (code: 405, status: 'method not allowed'),
  (code: 500, status: 'internal server error'),
];

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(mainHandler());
}

Middleware mainHandler() {
  return (Handler handler) {
    return (RequestContext context) async {
      if (environment == Environment.prod) {
        final contentType = context.request.headers['user-agent'];
        if (contentType?.toLowerCase().contains('postman') ?? false) {
          return Response.json(
            statusCode: 400,
            body: handledCode.firstWhere((e) => e.code == 400).status,
          );
        }
      }

      final response = await handler(context);
      if (handledCode.any((e) => e.code == response.statusCode)) {
        final bodyBase = await response.body();

        GeneralModel body;
        try {
          body = GeneralModel.fromJson(
            jsonDecode(bodyBase) as Map<String, dynamic>,
          );
        } catch (_) {
          body = GeneralModel(message: bodyBase);
        }

        return Response.json(
          statusCode: response.statusCode,
          body: GeneralModel(
            code: body.code ?? response.statusCode,
            message: body.message ??
                handledCode
                    .firstWhere((e) => e.code == response.statusCode)
                    .status,
          ),
        );
      }
      return response;
    };
  };
}

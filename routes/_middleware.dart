import 'dart:convert';

import 'package:crud/config/app_config.dart';
import 'package:crud/models/general_model.dart';
import 'package:crud/services/secure.dart';
import 'package:crud/utils/dlog.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(mainHandler());
}

Middleware mainHandler() {
  return (Handler handler) {
    return (RequestContext context) async {
      // list reponse code handled
      final handledCode = <({int code, String status})>[
        (code: 400, status: 'bad request'),
        (code: 404, status: 'route not found'),
        (code: 405, status: 'method not allowed'),
        (code: 500, status: 'internal server error'),
      ];

      // block postman request in production
      if (AppConfig.env == 'PROD') {
        final contentType = context.request.headers['user-agent'];
        if (contentType?.toLowerCase().contains('postman') ?? false) {
          return Response.json(
            statusCode: 400,
            body: GeneralModel(
              code: 400,
              message: handledCode.firstWhere((e) => e.code == 400).status,
            ),
          );
        }
      }

      // verify a token
      final tokenValid = _checkToken(context.request);
      if (!tokenValid) {
        final jwt =
            Secure().jwtSign(JWT(Secure().aesEncrypt(jsonEncode({'id': 123}))));
        dlog(jwt);
        return Response.json(
          statusCode: 401,
          body: GeneralModel(code: 401, message: 'invalid token'),
        );
      }

      final response = await handler(context);
      final body = await _decodeBody(response);
      final code = body.code ?? response.statusCode;
      if (handledCode.any((e) => e.code == response.statusCode)) {
        return Response.json(
          statusCode: response.statusCode,
          body: GeneralModel(
            code: code,
            message: body.message ??
                handledCode
                    .firstWhere((e) => e.code == response.statusCode)
                    .status,
          ),
        );
      }
      return Response.json(
        statusCode: code,
        headers: response.headers,
        body: jsonDecode(await response.body()),
      );
    };
  };
}

bool _checkToken(Request request) {
  final nonTokenUrl = <String>['auth'];
  try {
    if (!nonTokenUrl.contains(request.url.pathSegments[1])) {
      if (AppConfig.secretKey == null) throw Exception();
      final token = request.headers['Authorization'];
      Secure().jtwVerify(token);
    }
    return true;
  } catch (error) {
    return false;
  }
}

Future<GeneralModel> _decodeBody(Response response) async {
  final bodyBase = await response.body();
  GeneralModel body;
  try {
    body = GeneralModel.fromJson(
      jsonDecode(bodyBase) as Map<String, dynamic>,
    );
  } catch (_) {
    body = GeneralModel(message: bodyBase);
  }
  return body;
}

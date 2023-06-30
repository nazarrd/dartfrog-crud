import 'dart:convert';

import 'package:crud/config/app_config.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:encrypt/encrypt.dart';

class Secure {
  // aes encrypt
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(Key.fromUtf8(AppConfig.cryptoKey)));
  String aesEncrypt(String input) => encrypter.encrypt(input, iv: iv).base64;
  String aesDecrypt(String input) =>
      utf8.decode(encrypter.decryptBytes(Encrypted.fromBase64(input), iv: iv));

  // jwt sign-verify
  String jwtSign(JWT jwt) => jwt.sign(AppConfig.secretKey!);
  JWT jtwVerify(String? token) => JWT.verify('$token', AppConfig.secretKey!);
}

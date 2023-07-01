import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:crud/config/app_config.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:encrypt/encrypt.dart';

class Secure {
  // aes encrypt-decrypt input
  final _iv = IV.fromLength(16);
  final _encrypter = Encrypter(AES(Key.fromUtf8(AppConfig.cryptoKey)));
  String aesEncrypt(String i) => _encrypter.encrypt(i, iv: _iv).base64;
  String aesDecrypt(String i) =>
      utf8.decode(_encrypter.decryptBytes(Encrypted.fromBase64(i), iv: _iv));

  // jwt sign-verify token
  String jwtSign(JWT jwt) =>
      jwt.sign(AppConfig.secretKey!, expiresIn: const Duration(hours: 1));
  JWT jtwVerify(String? token) => JWT.verify('$token', AppConfig.secretKey!);

  // bcrypt ecnvrypt-check password
  String encyptPassword(String i) => BCrypt.hashpw(i, BCrypt.gensalt());
  bool checkPassword(String i, String e) => BCrypt.checkpw(i, e);
}

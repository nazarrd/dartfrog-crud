import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

abstract class AppConfig {
  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  // load env
  static String? get env => _env['SERVER_ENV'];
  static String get cryptoKey =>
      _env[env == 'DEV' ? 'CRYPTO_DEV_KEY' : 'CRYPTO_PROD_KEY'] ?? '';
  static SecretKey? get secretKey {
    final key = _env[env == 'DEV' ? 'JWT_DEV_KEY' : 'JWT_PROD_KEY'];
    if (key != null) return SecretKey(key);
    return null;
  }

  // set database url
  static String? get _mongoUser => _env['MONGODB_USER'];
  static String? get _mongoPass => _env['MONGODB_PASS'];
  static String? get _mongoServer => _env['MONGODB_SERVER'];
  static int? get _mongoPort => int.tryParse(_env['MONGODB_PORT'] ?? '27017');
  static String? get _mongoDatabase => _env['MONGODB_DATABASE'];
  static String mongoUrl =
      'mongodb+srv://$_mongoUser:$_mongoPass@$_mongoServer:$_mongoPort/$_mongoDatabase';
}

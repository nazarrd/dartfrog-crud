import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../utils/dlog.dart';

class DbService {
  static Db? _db;

  static Future<Db> get db async {
    if (_db != null && _db!.state == State.open) {
      return _db!;
    } else {
      dlog('create connection to MongoDB');
      _db = await _openDb();
      return _db!;
    }
  }

  static Future<Response> startConnection(
    RequestContext context,
    Future<Response> callBack,
  ) async {
    try {
      await db;
      return await callBack;
    } catch (e) {
      dlog(e);
      return Response.json(statusCode: 500);
    }
  }

  static Future<Db> _openDb() async {
    // Load the environment variables from .env file
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final mongoUrl =
        'mongodb+srv://${env['MONGODB_USER']}:${env['MONGODB_PASS']}@${env['MONGODB_SERVER']}:${env['MONGODB_PORT']}/${env['MONGODB_DATABASE']}';
    try {
      final db = await Db.create(mongoUrl);
      await db.open();
      dlog('connected to MongoDB');
      return db;
    } catch (error, stacktrace) {
      dlog('$error, $stacktrace');
      throw ConnectionException('unable to connect to $mongoUrl');
    }
  }

  static Future<void> closeDb() async {
    if (_db != null && _db!.state != State.closed) {
      await _db!.close();
      dlog('disconnected from MongoDB');
    }
  }

  static Future<DbCollection> getCollection(String name) async =>
      db.then((value) => value.collection(name));
}

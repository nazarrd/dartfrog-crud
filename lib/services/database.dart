import 'package:crud/config/app_config.dart';
import 'package:crud/utils/dlog.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Database {
  static Db? _db;

  static Future<Db> get db async {
    if (_db?.state == State.open && (_db?.isConnected ?? false)) {
      return _db!;
    } else {
      dlog('create new connection to MongoDB');
      _db = await _openDb();
      return _db!;
    }
  }

  static Future<Response> connectDb(Future<Response> callback) async {
    try {
      await db;
      return await callback;
    } catch (e) {
      dlog(e);
      return Response.json(statusCode: 500);
    }
  }

  static Future<Db> _openDb() async {
    final mongoUrl = AppConfig.mongoUrl;
    try {
      final db = await Db.create(mongoUrl);
      await db.open();
      return db;
    } catch (error, stacktrace) {
      dlog('$error, $stacktrace');
      throw const ConnectionException('unable to connect to MongoDB');
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

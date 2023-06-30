// ignore_for_file: avoid_print
import 'package:crud/config/app_config.dart';

void dlog(dynamic log) {
  if (AppConfig.env == 'DEV') {
    if (log is String) {
      const maxLogSize = 1000;
      for (var i = 0; i <= log.length / maxLogSize; i++) {
        final start = i * maxLogSize;
        var end = (i + 1) * maxLogSize;
        end = end > log.length ? log.length : end;
        print(log.substring(start, end));
      }
    } else {
      print(log);
    }
  }
}

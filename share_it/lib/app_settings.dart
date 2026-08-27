import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSettings {
  static final ValueNotifier<bool> isEncripted = ValueNotifier<bool>(false);

  static final ValueNotifier<int> port = ValueNotifier<int>(53398);

  static final ValueNotifier<String> theme = ValueNotifier<String>(
    dotenv.env['THEME'] ?? 'System',
  );

  static final ValueNotifier<String> deviceName = ValueNotifier(
    dotenv.env['USER_ID'] ?? 'unregistred device',
  );

  static final ValueNotifier<String> deviceIP = ValueNotifier(
    dotenv.env['USER_IP'] ?? '0.0.0.0',
  );
}

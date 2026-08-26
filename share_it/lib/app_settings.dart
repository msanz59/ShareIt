import 'package:flutter/foundation.dart';

class AppSettings {
  static final ValueNotifier<bool> isEncripted = ValueNotifier<bool>(false);

  static final ValueNotifier<int> port = ValueNotifier<int>(53398);
}

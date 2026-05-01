import 'dart:math';

import 'package:daily_record/core/utils/token_storage.dart';

class DeviceService {
  static const int _deviceIdLength = 32;

  static Future<String> getDeviceId() async {
    final existingId = await TokenStorage.getDeviceId();
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newDeviceId = _generateDeviceId();
    await TokenStorage.saveDeviceId(newDeviceId);
    return newDeviceId;
  }

  static Future<void> init() async {
    await getDeviceId();
  }

  static String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();

    for (var i = 0; i < _deviceIdLength; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }
}

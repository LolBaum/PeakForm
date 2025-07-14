import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class LoggingService {
  LoggingService._privateConstructor();
  static final LoggingService instance = LoggingService._privateConstructor();

  late final Logger _logger;
  final Map<String, dynamic> _globalContext = {};

  Future<void> init(Logger logger) async {
    _logger = logger;

    // static context
    final packageInfo = await PackageInfo.fromPlatform();
    _globalContext['app_version'] = packageInfo.version;
    _globalContext['build_number'] = packageInfo.buildNumber;
    _globalContext['package_name'] = packageInfo.packageName;

    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      _globalContext['os'] = 'web';
      _globalContext['device_model'] = webInfo.browserName.name;
      _globalContext['os_version'] = webInfo.appVersion;
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _globalContext['os'] = 'android';
      _globalContext['brand'] = androidInfo.brand;
      _globalContext['device_model'] = androidInfo.model;
      _globalContext['hardware'] = androidInfo.hardware;
      _globalContext['manufacturer'] = androidInfo.manufacturer;
      _globalContext['product'] = androidInfo.product;
      _globalContext['android_id'] = androidInfo.id;
      _globalContext['sdk_int'] = androidInfo.version.sdkInt;
      _globalContext['fingerprint'] = androidInfo.fingerprint;
      _globalContext['bootloader'] = androidInfo.bootloader;
      _globalContext['board'] = androidInfo.board;
      _globalContext['display'] = androidInfo.display;
      _globalContext['fingerprint'] = androidInfo.fingerprint;
      _globalContext['bootloader'] = androidInfo.bootloader;
      _globalContext['os_version'] = androidInfo.version.release;
      _globalContext['is_physical_device'] = androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _globalContext['os'] = 'ios';
      _globalContext['device_model'] = iosInfo.model;
      _globalContext['system_name'] = iosInfo.systemName;
      _globalContext['localized_model'] = iosInfo.localizedModel;
      _globalContext['identifier_for_vendor'] = iosInfo.identifierForVendor;
      _globalContext['os_version'] = iosInfo.systemVersion;
      _globalContext['utsname_machine'] = iosInfo.utsname.machine;
      _globalContext['utsname_version'] = iosInfo.utsname.version;
      _globalContext['utsname_release'] = iosInfo.utsname.release;
      _globalContext['utsname_machine'] = iosInfo.utsname.machine;
      _globalContext['utsname_version'] = iosInfo.utsname.version;
      _globalContext['utsname_release'] = iosInfo.utsname.release;
      _globalContext['is_physical_device'] = iosInfo.isPhysicalDevice;
    }

    // Generate a unique ID for this app session
    _globalContext['session_id'] = const Uuid().v4();
  }

  // dynamic context
  void setUserContext({String? id, String? email, String? username}) {
    if (id != null) _globalContext['user_id'] = id;
    if (email != null) _globalContext['user_email'] = email;
    if (username != null) _globalContext['user_username'] = username;
  }

  void clearUserContext() {
    _globalContext.remove('user_id');
    _globalContext.remove('user_email');
    _globalContext.remove('user_username');
  }

  void setScreenContext(String screenName) {
    _globalContext['screen'] = screenName;
  }

  void i(String message, {Map<String, dynamic>? context}) {
    _log(Level.info, message, context: context);
  }

  void w(String message, {Map<String, dynamic>? context}) {
    _log(Level.warning, message, context: context);
  }

  void e(String message,
      {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    _log(Level.error, message,
        error: error, stackTrace: stackTrace, context: context);
  }

  void _log(Level level, String message,
      {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    final fullContext = {..._globalContext};
    if (context != null) {
      fullContext.addAll(context);
    }

    fullContext['message'] = message;

    _logger.log(level, fullContext, error: error, stackTrace: stackTrace);
  }
}

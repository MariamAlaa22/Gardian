import 'package:flutter/services.dart';

class GuardianNativeBridge {
  static const MethodChannel _callSmsChannel = MethodChannel('guardian/calls_sms');
  static const MethodChannel _geoChannel = MethodChannel('guardian/geofence');

  static Future<void> startMonitoring() async {
    await _callSmsChannel.invokeMethod('startMonitoring');
  }

  static Future<void> stopMonitoring() async {
    await _callSmsChannel.invokeMethod('stopMonitoring');
  }

  static Future<List<Map<String, dynamic>>> getCallLogs() async {
    final dynamic result = await _callSmsChannel.invokeMethod('getCallLogs');
    return _normalizeList(result);
  }

  static Future<List<Map<String, dynamic>>> getSmsLogs() async {
    final dynamic result = await _callSmsChannel.invokeMethod('getSmsLogs');
    return _normalizeList(result);
  }

  static Future<void> uploadContacts() async {
    await _callSmsChannel.invokeMethod('uploadContacts');
  }

  static Future<List<Map<String, dynamic>>> getContacts() async {
    final dynamic result = await _callSmsChannel.invokeMethod('getContacts');
    return _normalizeList(result);
  }

  static Future<void> startGeofence({
    required String childEmail,
    required String childName,
  }) async {
    await _geoChannel.invokeMethod('startGeofence', <String, dynamic>{
      'childEmail': childEmail,
      'childName': childName,
    });
  }

  static Future<void> stopGeofence() async {
    await _geoChannel.invokeMethod('stopGeofence');
  }

  static Future<Map<String, dynamic>> getLastLocation() async {
    final dynamic result = await _geoChannel.invokeMethod('getLastLocation');
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _normalizeList(dynamic result) {
    if (result is! List) return <Map<String, dynamic>>[];
    return result
        .whereType<Map>()
        .map((Map item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

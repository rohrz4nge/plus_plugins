import 'dart:developer' as developer;
import 'dart:html' as html;
import 'dart:js_util' as js_util;

enum MotionApis { deviceMotion, sensorApi }

/// Receive permission status of the API.
Future<MotionApis?> checkPermission({String? permissionName}) async {
  final permission = html.window.navigator.permissions;

  // Check if browser supports this API or supports permission manager
  if (permission != null) {
    try {
      // Request for permission or check permission status
      final permissionStatus = await permission.query(
        {
          'name': permissionName,
        },
      );
      switch (permissionStatus.state) {
        case 'granted':
          return MotionApis.sensorApi;
        case 'prompt':
          // user needs to interact with this
          developer.log(
              'Permission [$permissionName] still has not been granted or denied.');
          break;
        default:
          // If permission is denied, do nothing
          developer
              .log('Permission [$permissionName] to use sensor is denied.');
      }
    } catch (e) {
      developer.log(
          'Integration with Permissions API is not enabled, still trying to start app.',
          error: e);
    }
  } else {
    const deviceMotionEvent = html.DeviceMotionEvent;
    if (js_util.hasProperty(deviceMotionEvent, 'requestPermission')) {
      final promise =
          js_util.callMethod(deviceMotionEvent, 'requestPermission', []);
      final result = await js_util.promiseToFuture(promise);
      if (result == "granted") {
        return MotionApis.deviceMotion;
      } else {
        return null;
      }
    }
    developer.log('No Permissions API, still try to start app.');
    return MotionApis.sensorApi;
  }
  return null;
}

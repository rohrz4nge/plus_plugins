import 'dart:async';
import 'dart:developer' as developer;
import 'dart:html' as html
    show
        LinearAccelerationSensor,
        Accelerometer,
        Gyroscope,
        Magnetometer,
        DeviceMotionEvent,
        DeviceRotationRate,
        window;
import 'dart:js';
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';
import 'package:sensors_plus_web/src/utils.dart';

/// The sensors plugin.
class SensorsPlugin extends SensorsPlatform {
  /// Factory method that initializes the Sensors plugin platform with an instance
  /// of the plugin for the web.
  static void registerWith(Registrar registrar) {
    SensorsPlatform.instance = SensorsPlugin();
  }

  void _featureDetected(
    Function initSensor, {
    String? apiName,
    String? permissionName,
    Function? onError,
    Function? initDeviceMotion,
  }) async {
    try {
      if (initDeviceMotion != null) {
        final motionApi = await checkPermission(permissionName: permissionName);
        if (motionApi == MotionApis.deviceMotion) {
          initDeviceMotionSensor();
        } else {
          initSensor();
        }
      } else {
        initSensor();
      }
    } catch (error) {
      if (onError != null) {
        onError();
      }

      /// Handle construction errors.
      ///
      /// If a feature policy blocks use of a feature it is because your code
      /// is inconsistent with the policies set on your server.
      /// This is not something that would ever be shown to a user.
      /// See Feature-Policy for implementation instructions in the browsers.
      if (error.toString().contains('SecurityError')) {
        /// See the note above about feature policy.
        developer.log('$apiName construction was blocked by a feature policy.',
            error: error);

        /// if this feature is not supported or Flag is not enabled yet!
      } else if (error.toString().contains('ReferenceError')) {
        developer.log('$apiName is not supported by the User Agent.',
            error: error);

        /// if this is unknown error, rethrow it
      } else {
        developer.log('Unknown error happened, rethrowing.');
        rethrow;
      }
    }
  }

  StreamController<AccelerometerEvent>? _accelerometerStreamController;
  late Stream<AccelerometerEvent> _accelerometerResultStream;

  @override
  Stream<AccelerometerEvent> get accelerometerEvents {
    if (_accelerometerStreamController == null) {
      _accelerometerStreamController = StreamController<AccelerometerEvent>();
      _featureDetected(
        () {
          final accelerometer = html.Accelerometer();

          setProperty(
            accelerometer,
            'onreading',
            allowInterop((_) => addAccelerometerEvent(accelerometer)),
          );

          accelerometer.start();

          accelerometer.onError.forEach(
            (e) => developer.log(
                'The accelerometer API is supported but something is wrong!',
                error: e),
          );
        },
        apiName: 'Accelerometer()',
        permissionName: 'accelerometer',
        onError: () {
          _accelerometerStreamController!.add(AccelerometerEvent(0, 0, 0));
        },
        initDeviceMotion: initDeviceMotionSensor,
      );
      _accelerometerResultStream =
          _accelerometerStreamController!.stream.asBroadcastStream();
    }

    return _accelerometerResultStream;
  }

  StreamController<GyroscopeEvent>? _gyroscopeEventStreamController;
  late Stream<GyroscopeEvent> _gyroscopeEventResultStream;

  @override
  Stream<GyroscopeEvent> get gyroscopeEvents {
    if (_gyroscopeEventStreamController == null) {
      _gyroscopeEventStreamController = StreamController<GyroscopeEvent>();
      _featureDetected(
        () {
          final gyroscope = html.Gyroscope();

          setProperty(gyroscope, 'onreading',
              allowInterop((_) => addGyroscopeEvent(gyroscope)));

          gyroscope.start();

          gyroscope.onError.forEach(
            (e) => developer.log(
                'The gyroscope API is supported but something is wrong!',
                error: e),
          );
        },
        apiName: 'Gyroscope()',
        permissionName: 'gyroscope',
        onError: () {
          _gyroscopeEventStreamController!.add(GyroscopeEvent(0, 0, 0));
        },
        initDeviceMotion: initDeviceMotionSensor,
      );
      _gyroscopeEventResultStream =
          _gyroscopeEventStreamController!.stream.asBroadcastStream();
    }

    return _gyroscopeEventResultStream;
  }

  StreamController<UserAccelerometerEvent>? _userAccelerometerStreamController;
  late Stream<UserAccelerometerEvent> _userAccelerometerResultStream;

  @override
  Stream<UserAccelerometerEvent> get userAccelerometerEvents {
    if (_userAccelerometerStreamController == null) {
      _userAccelerometerStreamController =
          StreamController<UserAccelerometerEvent>();
      _featureDetected(
        () {
          final linearAccelerationSensor = html.LinearAccelerationSensor();

          setProperty(
            linearAccelerationSensor,
            'onreading',
            allowInterop(
                (_) => addUserAccelerometerEvent(linearAccelerationSensor)),
          );

          linearAccelerationSensor.start();

          linearAccelerationSensor.onError.forEach(
            (e) => developer.log(
                'The linear acceleration API is supported but something is wrong!',
                error: e),
          );
        },
        apiName: 'LinearAccelerationSensor()',
        permissionName: 'accelerometer',
        onError: () {
          _userAccelerometerStreamController!
              .add(UserAccelerometerEvent(0, 0, 0));
        },
        initDeviceMotion: initDeviceMotionSensor,
      );
      _userAccelerometerResultStream =
          _userAccelerometerStreamController!.stream.asBroadcastStream();
    }

    return _userAccelerometerResultStream;
  }

  StreamController<MagnetometerEvent>? _magnetometerStreamController;
  late Stream<MagnetometerEvent> _magnetometerResultStream;

  @override
  Stream<MagnetometerEvent> get magnetometerEvents {
    if (_magnetometerStreamController == null) {
      _magnetometerStreamController = StreamController<MagnetometerEvent>();
      _featureDetected(
        () {
          final magnetometerSensor = html.Magnetometer();

          setProperty(
            magnetometerSensor,
            'onreading',
            allowInterop((_) => addMagnetometerEvent(magnetometerSensor)),
          );

          magnetometerSensor.start();

          magnetometerSensor.onError.forEach(
            (e) => developer.log(
                'The magnetometer API is supported but something is wrong!',
                error: e),
          );
        },
        apiName: 'Magnetometer()',
        permissionName: 'magnetometer',
        onError: () {
          _magnetometerStreamController!.add(MagnetometerEvent(0, 0, 0));
        },
      );
      _magnetometerResultStream =
          _magnetometerStreamController!.stream.asBroadcastStream();
    }

    return _magnetometerResultStream;
  }

  void initDeviceMotionSensor() {
    _accelerometerStreamController ??= StreamController<AccelerometerEvent>();
    _userAccelerometerStreamController ??=
        StreamController<UserAccelerometerEvent>();
    _gyroscopeEventStreamController ??= StreamController<GyroscopeEvent>();
    callMethod(html.window, 'addEventListener', [
      'devicemotion',
      allowInterop(
        (html.DeviceMotionEvent event) {
          addAccelerometerEvent(event.accelerationIncludingGravity);
          addUserAccelerometerEvent(event.acceleration);
          addGyroscopeEvent(event.rotationRate);
        },
      ),
    ]);
  }

  void addAccelerometerEvent(rawEvent) {
    final createdEvent = AccelerometerEvent(rawEvent?.x ?? 0 as double,
        rawEvent?.y ?? 0 as double, rawEvent?.z ?? 0 as double);
    _accelerometerStreamController!.add(createdEvent);
  }

  void addGyroscopeDeviceMotionEvent(html.DeviceRotationRate rawEvent) {
    final createdEvent = GyroscopeEvent(rawEvent.alpha as double,
        rawEvent.beta as double, rawEvent.gamma as double);
    _gyroscopeEventStreamController!.add(createdEvent);
  }

  void addGyroscopeEvent(rawEvent) {
    final createdEvent = GyroscopeEvent(rawEvent?.x ?? 0 as double,
        rawEvent?.y ?? 0 as double, rawEvent?.z ?? 0 as double);
    _gyroscopeEventStreamController!.add(createdEvent);
  }

  void addUserAccelerometerEvent(rawEvent) {
    final createdEvent = UserAccelerometerEvent(rawEvent?.x ?? 0 as double,
        rawEvent?.y ?? 0 as double, rawEvent?.z ?? 0 as double);
    _userAccelerometerStreamController!.add(createdEvent);
  }

  void addMagnetometerEvent(rawEvent) {
    final createdEvent = MagnetometerEvent(rawEvent?.x ?? 0 as double,
        rawEvent?.y ?? 0 as double, rawEvent?.z ?? 0 as double);
    _magnetometerStreamController!.add(createdEvent);
  }
}

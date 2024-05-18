part of flutter_blue_plus;

class PrinterController {
  StreamSubscription<BluetoothAdapterState>? _subscription;

  Future<void> initBluetoothPrinter({
    Function(BluetoothDevice)? onSuccess,
    Function(String)? onFailure,
  }) async {
    FlutterBluePlus.setLogLevel(LogLevel.info, color: true);

    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print('--> Bluetooth not supported by this device');

      if (onFailure != null) {
        onFailure('Bluetooth not supported by this device');
      }

      return;
    }

    // turn on bluetooth ourself if we can
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // handle bluetooth on & off
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    _subscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      print('--> bluetooth adapter state = $state');
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc

        final List<BluetoothDevice> devs = await FlutterBluePlus.bondedDevices;

        print('--> devs size = ${devs.length}');

        for (var d in devs) {
          print('--> name: ${d.advName}');
          print('--> id: ${d.remoteId.str}');
          print('--> platformName: ${d.platformName}');

          if (d.remoteId.str.isNotEmpty) {
            await d.connect();

            if (onSuccess != null) {
              onSuccess(d);
            }
            return;
          }

          // device.sendData(ESCUtil.nextLine(1));
        }
      } else {
        // show an error to the user, etc
        if (onFailure != null) {
          onFailure('Something went wrong');
        }
      }
    });
  }

  void cancelBluetoothPrinter() {
    _subscription?.cancel();
    _subscription = null;
  }
}

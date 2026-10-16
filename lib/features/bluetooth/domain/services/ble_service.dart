import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/ble_device.dart';

/// Service untuk menangani komunikasi Bluetooth Low Energy (BLE) langsung dengan Smartwatch
class BleService {
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? _hrSubscription;
  final _liveHeartRateController = StreamController<BleLiveHeartRate>.broadcast();

  // Standard Bluetooth SIG UUIDs
  static final Guid heartRateServiceUuid = Guid('180D');
  static final Guid heartRateMeasurementCharUuid = Guid('2A37');
  static final Guid batteryServiceUuid = Guid('180F');
  static final Guid batteryLevelCharUuid = Guid('2A19');

  Stream<BleLiveHeartRate> get liveHeartRateStream => _liveHeartRateController.stream;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Memeriksa apakah hardware Bluetooth didukung pada perangkat
  Future<bool> isSupported() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Memeriksa apakah Bluetooth aktif
  Future<bool> isAdapterOn() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  /// Memulai pemindaian perangkat BLE terdekat
  Stream<List<BleDeviceInfo>> scanForDevices({
    Duration timeout = const Duration(seconds: 12),
  }) async* {
    final discoveredMap = <String, BleDeviceInfo>{};

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: false,
      );
    } catch (e) {
      // Jika terjadi kesalahan izin atau hardware
    }

    yield* FlutterBluePlus.scanResults.map((results) {
      for (final r in results) {
        final name = r.device.platformName.isNotEmpty
            ? r.device.platformName
            : (r.advertisementData.advName.isNotEmpty
                ? r.advertisementData.advName
                : '');

        if (name.isNotEmpty) {
          final isSupercalla = BleDeviceInfo.checkIsSupercalla(name);
          discoveredMap[r.device.remoteId.str] = BleDeviceInfo(
            id: r.device.remoteId.str,
            name: name,
            rssi: r.rssi,
            isSupercalla: isSupercalla,
          );
        }
      }

      // Urutkan perangkat: Supercalla MG5 di urutan teratas, lalu berdasarkan kekuatan sinyal (RSSI)
      final sortedList = discoveredMap.values.toList()
        ..sort((a, b) {
          if (a.isSupercalla && !b.isSupercalla) return -1;
          if (!a.isSupercalla && b.isSupercalla) return 1;
          return b.rssi.compareTo(a.rssi);
        });

      return sortedList;
    });
  }

  /// Menghentikan pemindaian BLE
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  /// Menghubungkan ke smartwatch via deviceId (MAC address / Remote ID)
  Future<bool> connect(String deviceId) async {
    try {
      await stopScan();

      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevice = device;

      // Temukan service dan mulai subscribe Heart Rate jika didukung
      await discoverAndSubscribe();
      return true;
    } catch (e) {
      _connectedDevice = null;
      return false;
    }
  }

  /// Menemukan GATT Services pada jam dan subscribe ke Heart Rate 0x2A37
  Future<List<String>> discoverAndSubscribe() async {
    final discoveredNames = <String>[];
    if (_connectedDevice == null) return discoveredNames;

    try {
      final services = await _connectedDevice!.discoverServices();

      for (final s in services) {
        discoveredNames.add(s.uuid.str.toUpperCase());

        // Cari Standard Heart Rate Service (0x180D)
        if (s.uuid == heartRateServiceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == heartRateMeasurementCharUuid) {
              await c.setNotifyValue(true);
              await _hrSubscription?.cancel();
              _hrSubscription = c.lastValueStream.listen((data) {
                final hr = BleLiveHeartRate.parse(data);
                if (hr != null) {
                  _liveHeartRateController.add(hr);
                }
              });
            }
          }
        }
      }
    } catch (_) {}

    return discoveredNames;
  }

  /// Membaca level baterai (0x180F -> 0x2A19) jika disediakan oleh perangkat
  Future<int?> readBatteryLevel() async {
    if (_connectedDevice == null) return null;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final s in services) {
        if (s.uuid == batteryServiceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == batteryLevelCharUuid) {
              final val = await c.read();
              if (val.isNotEmpty) {
                return val[0];
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Memutuskan koneksi BLE dengan jam
  Future<void> disconnect() async {
    try {
      await _hrSubscription?.cancel();
      _hrSubscription = null;
      await _connectedDevice?.disconnect();
    } catch (_) {} finally {
      _connectedDevice = null;
    }
  }

  void dispose() {
    _hrSubscription?.cancel();
    _liveHeartRateController.close();
  }
}

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ble_device.dart';
import '../../domain/services/ble_service.dart';

class BleState {
  final BleConnectionStatus status;
  final bool isBluetoothOn;
  final List<BleDeviceInfo> scanResults;
  final BleDeviceInfo? connectedDevice;
  final int? liveHeartRateBpm;
  final DateTime? lastHeartRateTime;
  final int? batteryLevel;
  final List<String> discoveredServices;
  final String? errorMessage;

  const BleState({
    this.status = BleConnectionStatus.disconnected,
    this.isBluetoothOn = true,
    this.scanResults = const [],
    this.connectedDevice,
    this.liveHeartRateBpm,
    this.lastHeartRateTime,
    this.batteryLevel,
    this.discoveredServices = const [],
    this.errorMessage,
  });

  bool get isConnected => status == BleConnectionStatus.connected;
  bool get isScanning => status == BleConnectionStatus.scanning;
  bool get isConnecting => status == BleConnectionStatus.connecting;

  BleState copyWith({
    BleConnectionStatus? status,
    bool? isBluetoothOn,
    List<BleDeviceInfo>? scanResults,
    BleDeviceInfo? connectedDevice,
    int? liveHeartRateBpm,
    DateTime? lastHeartRateTime,
    int? batteryLevel,
    List<String>? discoveredServices,
    String? errorMessage,
    bool clearConnectedDevice = false,
    bool clearError = false,
  }) {
    return BleState(
      status: status ?? this.status,
      isBluetoothOn: isBluetoothOn ?? this.isBluetoothOn,
      scanResults: scanResults ?? this.scanResults,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      liveHeartRateBpm: liveHeartRateBpm ?? this.liveHeartRateBpm,
      lastHeartRateTime: lastHeartRateTime ?? this.lastHeartRateTime,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      discoveredServices: discoveredServices ?? this.discoveredServices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(() => service.dispose());
  return service;
});

class BleController extends StateNotifier<BleState> {
  final BleService _bleService;
  StreamSubscription<List<BleDeviceInfo>>? _scanSub;
  StreamSubscription<BleLiveHeartRate>? _hrSub;

  BleController(this._bleService) : super(const BleState()) {
    _initHeartRateListener();
    checkAdapter();
  }

  void _initHeartRateListener() {
    _hrSub = _bleService.liveHeartRateStream.listen((hr) {
      state = state.copyWith(
        liveHeartRateBpm: hr.bpm,
        lastHeartRateTime: hr.timestamp,
      );
    });
  }

  Future<void> checkAdapter() async {
    final isOn = await _bleService.isAdapterOn();
    state = state.copyWith(isBluetoothOn: isOn);
  }

  /// Memulai pemindaian perangkat Bluetooth terdekat (khususnya Supercalla MG5)
  Future<void> startScan() async {
    await stopScan();

    final isOn = await _bleService.isAdapterOn();
    if (!isOn) {
      state = state.copyWith(
        isBluetoothOn: false,
        status: BleConnectionStatus.error,
        errorMessage: 'Bluetooth ponsel belum aktif. Silakan aktifkan Bluetooth.',
      );
      return;
    }

    state = state.copyWith(
      status: BleConnectionStatus.scanning,
      scanResults: const [],
      clearError: true,
    );

    _scanSub = _bleService.scanForDevices().listen(
      (devices) {
        state = state.copyWith(scanResults: devices);
      },
      onError: (err) {
        state = state.copyWith(
          status: BleConnectionStatus.error,
          errorMessage: 'Gagal memindai: $err',
        );
      },
      onDone: () {
        if (state.status == BleConnectionStatus.scanning) {
          state = state.copyWith(status: BleConnectionStatus.disconnected);
        }
      },
    );
  }

  /// Menghentikan pemindaian
  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    await _bleService.stopScan();
    if (state.status == BleConnectionStatus.scanning) {
      state = state.copyWith(status: BleConnectionStatus.disconnected);
    }
  }

  /// Menghubungkan ke jam tangan Supercalla MG5
  Future<void> connectToDevice(BleDeviceInfo device) async {
    await stopScan();

    state = state.copyWith(
      status: BleConnectionStatus.connecting,
      connectedDevice: device,
      clearError: true,
    );

    final success = await _bleService.connect(device.id);

    if (success) {
      final services = await _bleService.discoverAndSubscribe();
      final battery = await _bleService.readBatteryLevel();

      state = state.copyWith(
        status: BleConnectionStatus.connected,
        connectedDevice: device,
        discoveredServices: services,
        batteryLevel: battery,
      );
    } else {
      state = state.copyWith(
        status: BleConnectionStatus.error,
        clearConnectedDevice: true,
        errorMessage: 'Gagal terhubung ke ${device.name}. Pastikan jam dalam jangkauan dan Bluetooth aktif.',
      );
    }
  }

  /// Memutuskan koneksi
  Future<void> disconnect() async {
    await _bleService.disconnect();
    state = state.copyWith(
      status: BleConnectionStatus.disconnected,
      clearConnectedDevice: true,
      liveHeartRateBpm: null,
      lastHeartRateTime: null,
      discoveredServices: const [],
      batteryLevel: null,
    );
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _hrSub?.cancel();
    super.dispose();
  }
}

final bleControllerProvider =
    StateNotifierProvider<BleController, BleState>((ref) {
  final service = ref.watch(bleServiceProvider);
  return BleController(service);
});

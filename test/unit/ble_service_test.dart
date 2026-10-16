import 'package:flutter_test/flutter_test.dart';
import 'package:suhat/features/bluetooth/domain/models/ble_device.dart';
import 'package:suhat/features/bluetooth/presentation/controllers/ble_controller.dart';

void main() {
  group('BLE Models & Parser Tests', () {
    test('BleDeviceInfo.checkIsSupercalla identifies Supercalla MG5 variants', () {
      expect(BleDeviceInfo.checkIsSupercalla('Supercalla MG5'), isTrue);
      expect(BleDeviceInfo.checkIsSupercalla('MG5'), isTrue);
      expect(BleDeviceInfo.checkIsSupercalla('MG Five'), isTrue);
      expect(BleDeviceInfo.checkIsSupercalla('Supercalla MG-5 Smartwatch'), isTrue);
      expect(BleDeviceInfo.checkIsSupercalla('Creek_MG5'), isTrue);
      expect(BleDeviceInfo.checkIsSupercalla('Smart Band Creek'), isTrue);

      expect(BleDeviceInfo.checkIsSupercalla('Apple Watch'), isFalse);
      expect(BleDeviceInfo.checkIsSupercalla('Galaxy Watch 6'), isFalse);
      expect(BleDeviceInfo.checkIsSupercalla('Mi Band 7'), isFalse);
      expect(BleDeviceInfo.checkIsSupercalla(null), isFalse);
      expect(BleDeviceInfo.checkIsSupercalla(''), isFalse);
    });

    test('BleLiveHeartRate.parse decodes standard 8-bit Bluetooth SIG HR packet', () {
      // Byte 0: 0x00 (Format: UINT8, Contact: not supported, Energy: false)
      // Byte 1: 72 BPM
      final raw = [0x00, 72];
      final parsed = BleLiveHeartRate.parse(raw);

      expect(parsed, isNotNull);
      expect(parsed!.bpm, 72);
      expect(parsed.sensorContact, isNull);
    });

    test('BleLiveHeartRate.parse decodes 8-bit packet with sensor contact detected', () {
      // Byte 0: 0x06 (Format: UINT8, Contact Supported & Detected: 0x06)
      // Byte 1: 85 BPM
      final raw = [0x06, 85];
      final parsed = BleLiveHeartRate.parse(raw);

      expect(parsed, isNotNull);
      expect(parsed!.bpm, 85);
      expect(parsed.sensorContact, isTrue);
    });

    test('BleLiveHeartRate.parse decodes standard 16-bit HR packet', () {
      // Byte 0: 0x01 (Format: UINT16)
      // Byte 1: 0x96 (150 low byte), Byte 2: 0x00 (high byte) -> 150 BPM
      final raw = [0x01, 0x96, 0x00];
      final parsed = BleLiveHeartRate.parse(raw);

      expect(parsed, isNotNull);
      expect(parsed!.bpm, 150);
    });

    test('BleLiveHeartRate.parse decodes packet with Energy Expended (Joules)', () {
      // Byte 0: 0x08 (Energy Expended present: bit 3 = 1)
      // Byte 1: 78 BPM
      // Byte 2 & 3: 250 Joules (0xFA, 0x00)
      final raw = [0x08, 78, 0xFA, 0x00];
      final parsed = BleLiveHeartRate.parse(raw);

      expect(parsed, isNotNull);
      expect(parsed!.bpm, 78);
      expect(parsed.energyExpendedJoules, 250);
    });

    test('BleLiveHeartRate.parse rejects corrupted or unrealistic physiological HR', () {
      // Empty byte
      expect(BleLiveHeartRate.parse([]), isNull);

      // Truncated packet
      expect(BleLiveHeartRate.parse([0x01]), isNull);

      // Unrealistic human heart rate (< 30 or > 240)
      expect(BleLiveHeartRate.parse([0x00, 15]), isNull); // 15 BPM
      expect(BleLiveHeartRate.parse([0x00, 255]), isNull); // 255 BPM
    });

    test('BleState manages connection states cleanly', () {
      const state = BleState();
      expect(state.status, BleConnectionStatus.disconnected);
      expect(state.isConnected, isFalse);
      expect(state.isScanning, isFalse);

      final scanning = state.copyWith(status: BleConnectionStatus.scanning);
      expect(scanning.isScanning, isTrue);

      const device = BleDeviceInfo(
        id: 'AA:BB:CC:DD:EE:FF',
        name: 'Supercalla MG5',
        rssi: -58,
        isSupercalla: true,
      );

      final connected = scanning.copyWith(
        status: BleConnectionStatus.connected,
        connectedDevice: device,
        liveHeartRateBpm: 76,
      );

      expect(connected.isConnected, isTrue);
      expect(connected.connectedDevice?.name, 'Supercalla MG5');
      expect(connected.connectedDevice?.isSupercalla, isTrue);
      expect(connected.liveHeartRateBpm, 76);
    });
  });
}

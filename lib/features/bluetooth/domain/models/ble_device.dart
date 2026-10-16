enum BleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

/// Model data perangkat Bluetooth LE (Smartwatch Supercalla MG5 / perangkat BLE lainnya)
class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final bool isSupercalla;

  const BleDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    this.isSupercalla = false,
  });

  /// Deteksi apakah perangkat adalah seri Supercalla / MG5
  static bool checkIsSupercalla(String? deviceName) {
    if (deviceName == null || deviceName.trim().isEmpty) return false;
    final lower = deviceName.toLowerCase();
    return lower.contains('mg5') ||
        lower.contains('supercalla') ||
        lower.contains('mg five') ||
        lower.contains('creek') ||
        lower.contains('mg-5');
  }

  BleDeviceInfo copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? isSupercalla,
  }) {
    return BleDeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isSupercalla: isSupercalla ?? this.isSupercalla,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDeviceInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Data pengukuran detak jantung langsung (Real-Time) via Bluetooth SIG GATT Characteristic 0x2A37
class BleLiveHeartRate {
  final int bpm;
  final DateTime timestamp;
  final bool? sensorContact;
  final int? energyExpendedJoules;

  const BleLiveHeartRate({
    required this.bpm,
    required this.timestamp,
    this.sensorContact,
    this.energyExpendedJoules,
  });

  /// Mengurai format byte standar Bluetooth SIG Heart Rate Measurement (0x2A37)
  /// Flags byte (byte 0):
  /// - Bit 0: 0 = Heart Rate Value UINT8, 1 = UINT16
  /// - Bit 1 & 2: Sensor contact detected
  /// - Bit 3: Energy Expended field present
  /// - Bit 4: RR-Interval field present
  static BleLiveHeartRate? parse(List<int> rawBytes) {
    if (rawBytes.isEmpty) return null;

    final flags = rawBytes[0];
    final is16Bit = (flags & 0x01) != 0;
    final contactSupported = (flags & 0x04) != 0;
    final contactDetected = contactSupported ? ((flags & 0x02) != 0) : null;
    final hasEnergy = (flags & 0x08) != 0;

    int offset = 1;
    int bpm = 0;

    if (is16Bit) {
      if (rawBytes.length < 3) return null;
      bpm = rawBytes[1] | (rawBytes[2] << 8);
      offset += 2;
    } else {
      if (rawBytes.length < 2) return null;
      bpm = rawBytes[1];
      offset += 1;
    }

    int? energyExpended;
    if (hasEnergy && rawBytes.length >= offset + 2) {
      energyExpended = rawBytes[offset] | (rawBytes[offset + 1] << 8);
    }

    // Filter denyut manusia fisiologis realistis (30 - 240 BPM)
    if (bpm < 30 || bpm > 240) return null;

    return BleLiveHeartRate(
      bpm: bpm,
      timestamp: DateTime.now(),
      sensorContact: contactDetected,
      energyExpendedJoules: energyExpended,
    );
  }
}

/// Informasi Layanan GATT Bluetooth yang ditemukan pada jam tangan
class BleGattServiceInfo {
  final String uuid;
  final String name;
  final List<String> characteristicUuids;

  const BleGattServiceInfo({
    required this.uuid,
    required this.name,
    required this.characteristicUuids,
  });

  /// Dapatkan nama layanan standar Bluetooth SIG atau vendor yang dikenal
  static String resolveServiceName(String uuidString) {
    final lower = uuidString.toLowerCase();
    if (lower.contains('180d')) return 'Heart Rate Service (Detak Jantung Standar)';
    if (lower.contains('180f')) return 'Battery Service (Baterai)';
    if (lower.contains('180a')) return 'Device Information (Manufaktur & Model)';
    if (lower.contains('1800')) return 'Generic Access';
    if (lower.contains('1801')) return 'Generic Attribute';
    if (lower.contains('1814')) return 'Running Speed and Cadence';
    if (lower.contains('fee7')) return 'Tencent Sports Health Service';
    if (lower.contains('fea0') || lower.contains('fea1') || lower.contains('fea2')) {
      return 'FitBeing / Creek Sensor Data Service';
    }
    if (lower.contains('6e400001')) return 'Nordic UART Data Stream';
    return 'Layanan Vendor Khusus (Proprietary)';
  }
}


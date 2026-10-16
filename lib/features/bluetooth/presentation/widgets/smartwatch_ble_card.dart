import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/ble_device.dart';
import '../controllers/ble_controller.dart';

class SmartwatchBleCard extends ConsumerWidget {
  const SmartwatchBleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bleControllerProvider);
    final controller = ref.read(bleControllerProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bleState.isConnected
              ? AppTheme.accentGreen.withOpacity(0.5)
              : AppTheme.borderSubtle,
          width: bleState.isConnected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bleState.isConnected
                      ? AppTheme.accentGreen.withOpacity(0.12)
                      : AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  bleState.isConnected
                      ? Icons.bluetooth_connected
                      : (bleState.isScanning
                          ? Icons.bluetooth_searching
                          : Icons.bluetooth),
                  color: bleState.isConnected
                      ? AppTheme.accentGreen
                      : AppTheme.primaryTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koneksi Bluetooth (BLE) Langsung',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      bleState.isConnected
                          ? 'Terhubung ke ${bleState.connectedDevice?.name ?? "Supercalla MG5"}'
                          : (bleState.isScanning
                              ? 'Sedang mencari Supercalla MG5...'
                              : 'Khusus Smartwatch Supercalla MG5'),
                      style: TextStyle(
                        fontSize: 11,
                        color: bleState.isConnected
                            ? AppTheme.accentGreen
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              _buildStatusBadge(bleState),
            ],
          ),

          const SizedBox(height: 14),

          // Error Message jika ada
          if (bleState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.accentRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bleState.errorMessage!,
                      style: const TextStyle(fontSize: 11, color: AppTheme.accentRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tampilan Ketika Terhubung
          if (bleState.isConnected && bleState.connectedDevice != null) ...[
            _buildConnectedSection(context, bleState, controller),
          ] else ...[
            // Tampilan Belum Terhubung: Tombol Scan & List Hasil
            _buildDisconnectedSection(bleState, controller),
          ],

          const SizedBox(height: 12),

          // Catatan Transparansi Fisiologis
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Catatan: Jalur BLE membaca sensor detak jantung & GATT langsung dari Supercalla MG5 secara real-time. '
              'Untuk riwayat tidur dan rekap olahraga kumulatif, data dikonsolidasikan melalui Health Connect / Strava.',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BleState state) {
    Color color;
    String label;

    switch (state.status) {
      case BleConnectionStatus.connected:
        color = AppTheme.accentGreen;
        label = 'Terhubung';
        break;
      case BleConnectionStatus.connecting:
        color = AppTheme.accentAmber;
        label = 'Menghubungkan';
        break;
      case BleConnectionStatus.scanning:
        color = AppTheme.primaryTeal;
        label = 'Memindai';
        break;
      case BleConnectionStatus.error:
        color = AppTheme.accentRed;
        label = 'Gagal';
        break;
      case BleConnectionStatus.disconnected:
        color = AppTheme.textMuted;
        label = 'Terputus';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildConnectedSection(
    BuildContext context,
    BleState state,
    BleController controller,
  ) {
    final dev = state.connectedDevice!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.accentGreen.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.watch, color: AppTheme.accentGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dev.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'ID: ${dev.id}  •  Kekuatan Sinyal: ${dev.rssi} dBm',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (state.batteryLevel != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.battery_std, size: 16, color: AppTheme.accentGreen),
                        Text(
                          '${state.batteryLevel}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const Divider(height: 18),
              // Live Heart Rate Stream
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite, color: AppTheme.accentRed, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Live Heart Rate Sensor:',
                        style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                  if (state.liveHeartRateBpm != null) ...[
                    Row(
                      children: [
                        Text(
                          '${state.liveHeartRateBpm}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentRed,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      'Menunggu sensor...',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.disconnect(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.accentRed,
              side: BorderSide(color: AppTheme.accentRed.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.bluetooth_disabled, size: 16),
            label: const Text('Putuskan Koneksi Jam', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectedSection(
    BleState state,
    BleController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tombol Pindai
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isConnecting
                ? null
                : (state.isScanning ? () => controller.stopScan() : () => controller.startScan()),
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isScanning ? AppTheme.accentAmber : AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: state.isScanning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.radar, size: 18),
            label: Text(
              state.isScanning ? 'Hentikan Pemindaian' : 'Cari Supercalla MG5 (BLE)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // List Hasil Pemindaian
        if (state.scanResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Perangkat Ditemukan:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          ...state.scanResults.take(5).map((device) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: device.isSupercalla
                    ? AppTheme.primaryTeal.withOpacity(0.08)
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: device.isSupercalla
                      ? AppTheme.primaryTeal.withOpacity(0.4)
                      : AppTheme.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    device.isSupercalla ? Icons.watch : Icons.bluetooth,
                    size: 18,
                    color: device.isSupercalla ? AppTheme.primaryTeal : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                device.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: device.isSupercalla ? FontWeight.bold : FontWeight.w500,
                                  color: AppTheme.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (device.isSupercalla) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'MG5',
                                  style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'RSSI: ${device.rssi} dBm',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: state.isConnecting ? null : () => controller.connectToDevice(device),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppTheme.primaryTeal,
                    ),
                    child: const Text('Hubungkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

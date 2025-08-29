import 'package:flutter/material.dart';
import 'package:carefreepass/domain/entities/ble_device.dart';

class BleDeviceTile extends StatelessWidget {
  final BleDevice device;

  const BleDeviceTile({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSignalColor(device.rssi),
          child: Text(
            '${device.rssi}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${device.id}'),
            Text('신호 강도: ${_getSignalStrength(device.rssi)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              device.isConnectable ? Icons.link : Icons.link_off,
              color: device.isConnectable ? Colors.green : Colors.grey,
            ),
            Text(
              device.isConnectable ? '연결 가능' : '연결 불가',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${device.name} 감지됨! RSSI: ${device.rssi}dBm'),
              backgroundColor: _getSignalColor(device.rssi),
            ),
          );
        },
      ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  String _getSignalStrength(int rssi) {
    if (rssi >= -50) return '매우 강함';
    if (rssi >= -70) return '강함';
    if (rssi >= -90) return '보통';
    return '약함';
  }
}
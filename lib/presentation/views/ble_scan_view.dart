import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/gradient_background.dart';
import '../bloc/ble/ble_bloc.dart';
import '../bloc/ble/ble_event.dart';
import '../bloc/ble/ble_state.dart';
import '../widgets/ble_device_tile.dart';

class BleScanView extends StatefulWidget {
  const BleScanView({super.key});

  @override
  State<BleScanView> createState() => _BleScanViewState();
}

class _BleScanViewState extends State<BleScanView> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 페이지 진입 시 자동으로 권한 확인 및 스캔 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BleBloc>().add(CheckPermissions());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<BleBloc>().add(StopBleScan());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<BleBloc>();
    final currentState = bloc.state;
    
    if (state == AppLifecycleState.resumed) {
      // 이전에 스캔 중이었으면 다시 시작
      if (currentState is! BleInitial && 
          currentState is! BleError &&
          currentState is! BlePermissionDenied &&
          currentState is! BleBluetoothOff) {
        bloc.add(StartBleScan());
      }
    } else if (state == AppLifecycleState.paused) {
      // 백그라운드로 갈 때만 중지
      if (currentState is BleScanning) {
        bloc.add(StopBleScan());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('BLE 스캔'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<BleBloc, BleState>(
        builder: (context, state) {
          if (state is BleInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BleBluetoothOff) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 64),
                  SizedBox(height: 16),
                  Text('블루투스가 꺼져 있습니다'),
                  Text('설정에서 블루투스를 켜주세요'),
                ],
              ),
            );
          }

          if (state is BlePermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64),
                  const SizedBox(height: 16),
                  const Text('블루투스 및 위치 권한이 필요합니다'),
                  const SizedBox(height: 8),
                  const Text('BLE 기기 스캔을 위해 권한을 허용해주세요',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 권한 다시 요청
                      context.read<BleBloc>().add(CheckPermissions());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('권한 다시 요청'),
                  ),
                ],
              ),
            );
          }

          if (state is BleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('오류: ${state.message}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BleBloc>().add(StartBleScan());
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (state is BleScanning) {
            if (state.devices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('병원 비콘 검색 중...'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text('조건:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('✓ SHA-256 상위 6바이트 검증'),
                          Text('✓ RSSI -100 이상 (10m 이내)'),
                          SizedBox(height: 8),
                          Text('nRF Connect에서 5ED4A4459CA1 입력',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                            textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade100,
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text('${state.devices.length}개 디바이스 발견'),
                      const Spacer(),
                      Text(
                        '업데이트: ${_formatTime(state.lastUpdate)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.devices.length,
                    itemBuilder: (context, index) {
                      return BleDeviceTile(device: state.devices[index]);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('대기 중'),
          );
        },
      ),
      floatingActionButton: BlocBuilder<BleBloc, BleState>(
        builder: (context, state) {
          if (state is BleScanning) {
            return FloatingActionButton(
              onPressed: () {
                context.read<BleBloc>().add(StopBleScan());
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          }
          return FloatingActionButton(
            onPressed: () {
              context.read<BleBloc>().add(StartBleScan());
            },
            child: const Icon(Icons.bluetooth_searching),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }
}
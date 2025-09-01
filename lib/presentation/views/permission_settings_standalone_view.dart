import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../widgets/custom_back_button.dart';

class PermissionSettingsStandaloneView extends StatefulWidget {
  const PermissionSettingsStandaloneView({super.key});

  @override
  State<PermissionSettingsStandaloneView> createState() => _PermissionSettingsStandaloneViewState();
}

class _PermissionSettingsStandaloneViewState extends State<PermissionSettingsStandaloneView> 
    with WidgetsBindingObserver {
  bool _bluetoothPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  bool _locationPermissionGranted = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCurrentPermissions();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCurrentPermissions();
    }
  }
  
  Future<void> _checkCurrentPermissions() async {
    final bluetoothStatus = Platform.isIOS 
        ? await Permission.bluetooth.status
        : await Permission.bluetoothScan.status;
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.locationWhenInUse.status;
    
    setState(() {
      _bluetoothPermissionGranted = bluetoothStatus.isGranted;
      _notificationPermissionGranted = notificationStatus.isGranted;
      _locationPermissionGranted = locationStatus.isGranted;
    });
  }
  
  Future<void> _requestBluetoothPermission() async {
    if (Platform.isIOS) {
      final currentStatus = await Permission.bluetooth.status;
      
      if (currentStatus.isPermanentlyDenied) {
        await _showSettingsDialog('블루투스');
        return;
      }
      
      if (currentStatus.isGranted) {
        setState(() {
          _bluetoothPermissionGranted = true;
        });
        return;
      }
      
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(milliseconds: 500));
        await FlutterBluePlus.stopScan();
        
        await Future.delayed(const Duration(milliseconds: 500));
        final newStatus = await Permission.bluetooth.status;
        
        if (newStatus.isGranted) {
          setState(() {
            _bluetoothPermissionGranted = true;
          });
        } else if (!newStatus.isPermanentlyDenied) {
          await _showRetryDialog('블루투스');
        }
      } catch (e) {
        final status = await Permission.bluetooth.status;
        setState(() {
          _bluetoothPermissionGranted = status.isGranted;
        });
        
        if (!status.isGranted && !status.isPermanentlyDenied) {
          await _showRetryDialog('블루투스');
        }
      }
    } else {
      final status = await Permission.bluetoothScan.request();
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog('블루투스');
      } else if (status.isDenied) {
        await _showRetryDialog('블루투스');
      } else {
        setState(() {
          _bluetoothPermissionGranted = status.isGranted;
        });
      }
    }
  }
  
  Future<void> _showRetryDialog(String permissionName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('권한 필요'),
          content: Text(
            '$permissionName 권한이 필요합니다.\n'
            '원활한 서비스 이용을 위해 권한을 허용해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('나중에'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('다시 요청'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      if (permissionName == '블루투스') {
        await _requestBluetoothPermission();
      } else if (permissionName == '위치') {
        await _requestLocationPermission();
      } else if (permissionName == '알림') {
        await _requestNotificationPermission();
      }
    }
  }
  
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    
    if (status.isPermanentlyDenied) {
      await _showSettingsDialog('알림');
    } else if (status.isDenied) {
      await _showRetryDialog('알림');
    } else {
      setState(() {
        _notificationPermissionGranted = status.isGranted;
      });
    }
  }
  
  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    
    if (status.isPermanentlyDenied) {
      await _showSettingsDialog('위치');
    } else if (status.isDenied) {
      await _showRetryDialog('위치');
    } else {
      setState(() {
        _locationPermissionGranted = status.isGranted;
      });
    }
  }
  
  Future<void> _showSettingsDialog(String permissionName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('권한 설정 필요'),
          content: Text(
            '$permissionName 권한이 거부되었습니다.\n'
            '설정에서 권한을 허용해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      await openAppSettings();
      await _checkCurrentPermissions();
    }
  }
  
  void _handleComplete() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: Row(
                children: [
                  const CustomBackButton(),
                  Expanded(
                    child: Center(
                      child: Text(
                        '권한 설정',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
                child: Column(
                  children: [
                    // 블루투스 권한
                    _buildPermissionItem(
                      context,
                      title: '블루투스 권한',
                      subtitle: '이동하는 중에도 원활하게 위치를\n공유할 수 있도록 도와줘요.',
                      icon: Icons.bluetooth,
                      iconColor: AppColors.primaryGreen,
                      isGranted: _bluetoothPermissionGranted,
                      onTap: _bluetoothPermissionGranted ? null : _requestBluetoothPermission,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                    
                    // 푸시 알림 권한
                    _buildPermissionItem(
                      context,
                      title: '푸시 알림 권한',
                      subtitle: '도착 알림 및 메시지 등을 전달해요.\n나중에 설정에서 변경할 수 있어요.',
                      icon: Icons.notifications,
                      iconColor: const Color(0xFFFFD54F),
                      isGranted: _notificationPermissionGranted,
                      onTap: _notificationPermissionGranted ? null : _requestNotificationPermission,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                    
                    // 위치 권한
                    _buildPermissionItem(
                      context,
                      title: '위치 권한',
                      subtitle: '본인의 위치를 주변인 공유해요.\n거부 시 앱 이용이 제한될 수 있어요.',
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      isGranted: _locationPermissionGranted,
                      onTap: _locationPermissionGranted ? null : _requestLocationPermission,
                    ),
                  ],
                ),
              ),
            ),
            
            // 완료 버튼
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '완료',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isGranted,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.lg)),
        decoration: BoxDecoration(
          color: isGranted 
              ? iconColor.withValues(alpha: 0.1)
              : AppColors.backgroundGray,
          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isGranted ? iconColor : AppColors.grayMedium,
            ),
            SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.md)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isGranted ? Icons.check_circle : Icons.arrow_forward_ios,
              size: 24,
              color: isGranted ? iconColor : AppColors.grayMedium,
            ),
          ],
        ),
      ),
    );
  }
}
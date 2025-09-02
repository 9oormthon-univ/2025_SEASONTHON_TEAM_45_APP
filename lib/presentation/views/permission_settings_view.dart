import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../widgets/custom_back_button.dart';

class PermissionSettingsView extends StatefulWidget {
  final bool isFromSettings;
  
  const PermissionSettingsView({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<PermissionSettingsView> createState() => _PermissionSettingsViewState();
}

class _PermissionSettingsViewState extends State<PermissionSettingsView> 
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
    // 앱이 다시 포그라운드로 돌아올 때 권한 상태 재확인
    if (state == AppLifecycleState.resumed) {
      _checkCurrentPermissions();
    }
  }
  
  Future<void> _checkCurrentPermissions() async {
    // iOS와 Android에서 다른 블루투스 권한 사용
    // iOS는 Permission.bluetooth만 지원함 (bluetoothScan 없음!)
    final bluetoothStatus = Platform.isIOS 
        ? await Permission.bluetooth.status  // iOS는 bluetooth만!
        : await Permission.bluetoothScan.status;  // Android는 bluetoothScan
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
      // iOS: Permission.bluetooth 사용
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
      
      // 실제 BLE 스캔으로 권한 팝업 트리거 (iOS 특성)
      try {
        await FlutterBluePlus.startScan(timeout: const Duration(milliseconds: 500));
        await FlutterBluePlus.stopScan();
        
        // 권한 상태 재확인
        await Future.delayed(const Duration(milliseconds: 500));
        final newStatus = await Permission.bluetooth.status;
        
        if (newStatus.isGranted) {
          setState(() {
            _bluetoothPermissionGranted = true;
          });
        } else if (!newStatus.isPermanentlyDenied) {
          // 거부했지만 영구 거부가 아니면 다시 요청 가능함을 알림
          await _showRetryDialog('블루투스');
        }
      } catch (e) {
        // 스캔 실패 = 권한 거부
        final status = await Permission.bluetooth.status;
        setState(() {
          _bluetoothPermissionGranted = status.isGranted;
        });
        
        if (!status.isGranted && !status.isPermanentlyDenied) {
          await _showRetryDialog('블루투스');
        }
      }
    } else {
      // Android: bluetoothScan 사용
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
      // 다시 권한 요청
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
      // 설정에서 돌아왔을 때 권한 상태 재확인
      await _checkCurrentPermissions();
    }
  }
  
  void _handleNext() {
    if (_bluetoothPermissionGranted && _notificationPermissionGranted && _locationPermissionGranted) {
      if (widget.isFromSettings) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPermissionsGranted = _bluetoothPermissionGranted && 
        _notificationPermissionGranted && 
        _locationPermissionGranted;
    
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 설정에서 왔을 때만 헤더 표시
            if (widget.isFromSettings)
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
                padding: ResponsiveUtils.defaultPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!widget.isFromSettings) const Spacer(flex: 1),
                    
                    // Title (로그인 후에만 표시)
                    if (!widget.isFromSettings) ...[
                      Text(
                        '원활한 앱 이용을 위해',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
                      Text(
                        '아래 권한을 확인해 주세요.',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xxl)),
              
              // Bluetooth Permission
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
                decoration: BoxDecoration(
                  color: _bluetoothPermissionGranted 
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : AppColors.backgroundGray,
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                ),
                child: InkWell(
                  onTap: _bluetoothPermissionGranted ? null : _requestBluetoothPermission,
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveUtils.widthPercent(context, 12),
                        height: ResponsiveUtils.widthPercent(context, 12),
                        decoration: BoxDecoration(
                          color: _bluetoothPermissionGranted 
                              ? AppColors.primaryGreen
                              : AppColors.primaryGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bluetooth,
                          color: Colors.white,
                          size: ResponsiveUtils.iconSize(context, IconSizeType.medium),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.widthPercent(context, 4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '블루투스 권한',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                            Text(
                              '근처 기기를 찾고 연결하기 위해\n필요한 권한입니다.',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                        color: _bluetoothPermissionGranted 
                            ? AppColors.primaryGreen
                            : AppColors.grayMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
              
              // Location Permission
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
                decoration: BoxDecoration(
                  color: _locationPermissionGranted 
                      ? const Color(0xFF2196F3).withOpacity(0.1)
                      : AppColors.backgroundGray,
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                ),
                child: InkWell(
                  onTap: _locationPermissionGranted ? null : _requestLocationPermission,
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveUtils.widthPercent(context, 12),
                        height: ResponsiveUtils.widthPercent(context, 12),
                        decoration: BoxDecoration(
                          color: _locationPermissionGranted 
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF2196F3).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: ResponsiveUtils.iconSize(context, IconSizeType.medium),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.widthPercent(context, 4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '위치 권한',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                            Text(
                              'BLE 기기 스캔과 더 정확한\n위치 공유를 위해 필요합니다.',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                        color: _locationPermissionGranted 
                            ? const Color(0xFF2196F3)
                            : AppColors.grayMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
              
              // Notification Permission
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.widthPercent(context, 4)),
                decoration: BoxDecoration(
                  color: _notificationPermissionGranted 
                      ? const Color(0xFFFFD54F).withOpacity(0.1)
                      : AppColors.backgroundGray,
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                ),
                child: InkWell(
                  onTap: _notificationPermissionGranted ? null : _requestNotificationPermission,
                  child: Row(
                    children: [
                      Container(
                        width: ResponsiveUtils.widthPercent(context, 12),
                        height: ResponsiveUtils.widthPercent(context, 12),
                        decoration: BoxDecoration(
                          color: _notificationPermissionGranted 
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFFFFD54F).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: ResponsiveUtils.iconSize(context, IconSizeType.medium),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.widthPercent(context, 4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '푸시 알림 권한',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
                            Text(
                              '중요한 알림과 상태 변경을\n실시간으로 받아보실 수 있습니다.',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: ResponsiveUtils.iconSize(context, IconSizeType.small),
                        color: _notificationPermissionGranted 
                            ? const Color(0xFFFFD54F)
                            : AppColors.grayMedium,
                      ),
                    ],
                  ),
                ),
              ),
                    
                    if (!widget.isFromSettings) const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
            
            // Bottom button
            Padding(
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
              child: SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: widget.isFromSettings 
                      ? () => Navigator.pop(context)  // 설정에서 왔을 때는 항상 활성화
                      : (allPermissionsGranted ? _handleNext : null),  // 로그인 후에는 권한 모두 허용시 활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (widget.isFromSettings || allPermissionsGranted)
                        ? AppColors.primaryGreen 
                        : AppColors.grayLight,
                    foregroundColor: (widget.isFromSettings || allPermissionsGranted)
                        ? Colors.white 
                        : AppColors.grayMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isFromSettings ? '완료' : '다음으로',
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
}
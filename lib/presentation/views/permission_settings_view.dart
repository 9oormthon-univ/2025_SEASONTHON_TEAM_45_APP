import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';

class PermissionSettingsView extends StatefulWidget {
  const PermissionSettingsView({super.key});

  @override
  State<PermissionSettingsView> createState() => _PermissionSettingsViewState();
}

class _PermissionSettingsViewState extends State<PermissionSettingsView> {
  bool _bluetoothPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  
  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }
  
  Future<void> _checkCurrentPermissions() async {
    final bluetoothStatus = await Permission.bluetooth.status;
    final notificationStatus = await Permission.notification.status;
    
    setState(() {
      _bluetoothPermissionGranted = bluetoothStatus.isGranted;
      _notificationPermissionGranted = notificationStatus.isGranted;
    });
  }
  
  Future<void> _requestBluetoothPermission() async {
    final status = await Permission.bluetooth.request();
    setState(() {
      _bluetoothPermissionGranted = status.isGranted;
    });
  }
  
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _notificationPermissionGranted = status.isGranted;
    });
  }
  
  void _handleNext() {
    if (_bluetoothPermissionGranted && _notificationPermissionGranted) {
      Navigator.pushReplacementNamed(context, '/ble_scan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPermissionsGranted = _bluetoothPermissionGranted && _notificationPermissionGranted;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.defaultPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              // Title
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
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              
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
                              '이동하는 중에도 원활하게 위치를\n공유할 수 있도록 도와줘요.',
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
                              '도착 알림 및 예시지 등을 전달해요.\n나중에 설정에서 변경할 수 있어요.',
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
              
              const Spacer(flex: 2),
              
              // Next button
              SizedBox(
                width: double.infinity,
                height: ResponsiveUtils.buttonHeight(context),
                child: ElevatedButton(
                  onPressed: allPermissionsGranted ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allPermissionsGranted 
                        ? AppColors.primaryGreen 
                        : AppColors.grayLight,
                    foregroundColor: allPermissionsGranted 
                        ? Colors.white 
                        : AppColors.grayMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '다음으로',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../data/auth_storage.dart';
import '../bloc/reservation/reservation_bloc.dart';
import '../bloc/reservation/reservation_state.dart';
import '../bloc/reservation/reservation_event.dart';
import '../bloc/ble/ble_bloc.dart';
import '../bloc/ble/ble_event.dart';
import '../bloc/ble/ble_state.dart';
import '../../injection_container.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 테스트 모드 설정
  static const bool DEBUG_MODE = true; // 테스트 시 true, 배포 시 false
  
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _userName;
  late BleBloc _bleBloc;
  Timer? _statusCheckTimer;
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _bleBloc = sl<BleBloc>();
    context.read<ReservationBloc>().add(LoadReservations());
    
    // 주기적으로 예약 상태 확인 (30초마다)
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      context.read<ReservationBloc>().add(LoadReservations());
    });
  }

  void _loadUserInfo() {
    final authStorage = AuthStorage();
    final userInfo = authStorage.getCurrentUser();
    setState(() {
      _userName = userInfo?['name'] ?? '사용자';
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _statusCheckTimer?.cancel();
    _bleBloc.close();
    super.dispose();
  }

  // BLE 스캔 시작 (오늘 예약이 SCHEDULED 상태일 때만)
  void _startBleScanning(String appointmentId) {
    if (DEBUG_MODE) {
      print('[BLE] 스캔 시작: 예약 ID $appointmentId');
    }
    _bleBloc.add(StartScanning());
  }

  // BLE 스캔 중지
  void _stopBleScanning() {
    if (DEBUG_MODE) {
      print('[BLE] 스캔 중지');
    }
    _bleBloc.add(StopScanning());
  }

  // 체크인 처리
  void _handleCheckIn(String appointmentId, String memberId) async {
    if (DEBUG_MODE) {
      print('[API] 체크인 요청: appointmentId=$appointmentId, memberId=$memberId');
    }
    
    // 체크인 API 호출
    context.read<ReservationBloc>().add(CheckInAppointment(
      appointmentId: appointmentId,
      memberId: memberId,
    ));
    
    // BLE 스캔 중지
    _stopBleScanning();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 홈화면에서는 뒤로가기 방지
        return false;
      },
      child: BlocProvider(
        create: (_) => _bleBloc,
        child: BlocListener<BleBloc, BleState>(
          listener: (context, bleState) {
            if (bleState is HospitalBeaconDetected) {
              // BLE 비콘 감지 시 체크인
              final reservation = (context.read<ReservationBloc>().state as ReservationLoaded)
                  .reservations
                  .firstWhere((r) => r.status == 'SCHEDULED' && _isToday(r.appointmentDate));
              
              _handleCheckIn(
                reservation.appointmentId.toString(),
                reservation.memberId.toString(),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundWhite,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: BlocBuilder<ReservationBloc, ReservationState>(
                      builder: (context, state) {
                        if (state is ReservationLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is ReservationLoaded) {
                          // 예약 정렬: 오늘 예약 우선, 그 다음 날짜순
                          final sortedReservations = _sortReservations(state.reservations);
                          
                          if (sortedReservations.isEmpty) {
                            return _buildEmptyState(context);
                          } else {
                            // 오늘 예약이 SCHEDULED 상태면 BLE 스캔 시작
                            final todayReservation = sortedReservations.first;
                            if (_isToday(todayReservation.appointmentDate) && 
                                todayReservation.status == 'SCHEDULED') {
                              _startBleScanning(todayReservation.appointmentId.toString());
                            }
                            
                            return _buildReservationPages(context, sortedReservations);
                          }
                        } else if (state is ReservationError) {
                          return Center(child: Text(state.message));
                        }
                        return _buildEmptyState(context);
                      },
                    ),
                  ),
                  _buildBottomButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 예약 정렬: 오늘 예약 우선, 그 다음 날짜순
  List<dynamic> _sortReservations(List<dynamic> reservations) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    final todayReservations = reservations.where((r) => r.appointmentDate == todayStr).toList();
    final futureReservations = reservations.where((r) => r.appointmentDate != todayStr).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    
    return [...todayReservations, ...futureReservations];
  }

  bool _isToday(String date) {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return date == todayStr;
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '구름병원',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(
              Icons.settings,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.defaultPadding(context),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '$_userName님,',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '환영합니다',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.xl)),
            decoration: BoxDecoration(
              color: AppColors.grayLight.withOpacity(0.3),
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.large),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.cloud_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                Text(
                  '아직 확인된 예약이 없어요.',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '예약하기를 눌러 진행해 주세요.',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 테스트 버튼들
          if (DEBUG_MODE) ...[
            _buildTestButtons(context),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildReservationPages(BuildContext context, List<dynamic> reservations) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: reservations.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildReservationCard(context, reservations[index]);
            },
          ),
        ),
        if (reservations.length > 1)
          _buildPageIndicator(reservations.length),
      ],
    );
  }

  Widget _buildReservationCard(BuildContext context, dynamic reservation) {
    return Padding(
      padding: ResponsiveUtils.defaultPadding(context),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '$_userName님,',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '환영합니다',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.xl)),
            decoration: BoxDecoration(
              color: _getStatusColor(reservation.status).withOpacity(0.1),
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.large),
            ),
            child: Column(
              children: [
                _buildStatusIndicator(context, reservation),
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
                Text(
                  _getStatusMessage(reservation.status),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                    color: AppColors.textSecondary,
                  ),
                ),
                if (reservation.status == 'CALLED' && reservation.roomName != null) ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                  Text(
                    '${reservation.roomName}진료실로',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '입장해주세요',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                  _buildReservationInfo(context, reservation),
                ],
              ],
            ),
          ),
          const Spacer(),
          // 테스트 버튼들
          if (DEBUG_MODE) ...[
            _buildTestButtons(context),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, dynamic reservation) {
    switch (reservation.status) {
      case 'SCHEDULED':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
            vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFFB800), size: 20),
              const SizedBox(width: 8),
              Text(
                '예약 완료',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      case 'ARRIVED':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
            vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.more_horiz, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                '대기 중',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      case 'CALLED':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
            vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                '호출됨',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReservationInfo(BuildContext context, dynamic reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('예약 날짜', _formatDate(reservation.appointmentDate)),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        _buildInfoRow('예약 시간', _formatTime(reservation.appointmentTime)),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
        _buildInfoRow('진료과', reservation.department ?? '내과'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    // 2024-12-31 -> 2024년 12월 31일
    final parts = date.split('-');
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }

  String _formatTime(String time) {
    // 14:30 -> 오후 2:30
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour < 12) {
      return '오전 ${hour == 0 ? 12 : hour}:$minute';
    } else {
      return '오후 ${hour == 12 ? 12 : hour - 12}:$minute';
    }
  }

  Widget _buildPageIndicator(int pageCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pageCount,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentPage
                  ? AppColors.primaryGreen
                  : AppColors.grayLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveUtils.buttonHeight(context),
        child: ElevatedButton(
          onPressed: () {
            // TODO: 예약하기 화면으로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('예약하기 화면은 추후 구현 예정입니다')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
            ),
            elevation: 0,
          ),
          child: Text(
            '예약하기',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 테스트용 버튼들
  Widget _buildTestButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // 테스트: 체크인 상태로 변경
                context.read<ReservationBloc>().add(UpdateAppointmentStatus(
                  appointmentId: '1',
                  status: 'ARRIVED',
                ));
              },
              child: const Text('체크인'),
            ),
            ElevatedButton(
              onPressed: () {
                // 테스트: 호출 알림 시뮬레이션
                _handleCallNotification({
                  'type': 'CALL',
                  'appointmentId': '1',
                  'roomName': '내과',
                  'status': 'CALLED',
                });
              },
              child: const Text('호출 알림'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () async {
            // 테스트 데이터 초기화
            context.read<ReservationBloc>().add(LoadReservations());
          },
          child: const Text('새로고침'),
        ),
      ],
    );
  }

  // FCM 호출 알림 처리
  void _handleCallNotification(Map<String, dynamic> data) {
    if (data['type'] == 'CALL') {
      context.read<ReservationBloc>().add(UpdateAppointmentStatus(
        appointmentId: data['appointmentId'],
        status: 'CALLED',
        roomName: data['roomName'],
      ));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return const Color(0xFFFFB800);
      case 'ARRIVED':
        return Colors.blue;
      case 'CALLED':
        return Colors.red;
      default:
        return AppColors.grayLight;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'SCHEDULED':
        return '예약시간에 맞게 도착해 주세요';
      case 'ARRIVED':
        return '병원에서 내원여부를 확인했어요';
      case 'CALLED':
        return '호출된 진료실로 와주세요!';
      default:
        return '';
    }
  }
}
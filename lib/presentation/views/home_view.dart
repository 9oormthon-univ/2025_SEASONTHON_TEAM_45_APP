import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../bloc/reservation/reservation_bloc.dart';
import '../bloc/reservation/reservation_state.dart';
import '../bloc/reservation/reservation_event.dart';
import '../bloc/ble/ble_bloc.dart';
import '../bloc/ble/ble_event.dart';
import '../bloc/ble/ble_state.dart';
import '../../injection_container.dart';
import 'appointment_initial_view.dart';

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
    // TODO: 실제 로그인한 사용자 정보를 가져와야 함
    setState(() {
      _userName = '사용자';  // 임시로 기본값 사용
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
    // if (DEBUG_MODE) {
    //   print('[BLE] 스캔 시작: 예약 ID $appointmentId');
    // }
    _bleBloc.add(StartScanning());
  }

  // BLE 스캔 중지
  void _stopBleScanning() {
    // if (DEBUG_MODE) {
    //   print('[BLE] 스캔 중지');
    // }
    _bleBloc.add(StopScanning());
  }

  // 체크인 처리
  void _handleCheckIn(String appointmentId, String memberId) async {
    // if (DEBUG_MODE) {
    //   print('[API] 체크인 요청: appointmentId=$appointmentId, memberId=$memberId');
    // }
    
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
          child: GradientScaffold(
            body: Column(
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
      padding: EdgeInsets.only(
        left: ResponsiveUtils.horizontalPadding(context),
        right: ResponsiveUtils.horizontalPadding(context),
        top: ResponsiveUtils.heightPercent(context, 1), // 상단 안전영역
        bottom: ResponsiveUtils.heightPercent(context, 1), // 헤더 하단 최소 여백
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/Cloud.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Text(
                '구름대병원',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.xxl),
                  fontWeight: FontWeight.w700,
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
      padding: ResponsiveUtils.horizontalPaddingOnly(context),
      child: Column(
        children: [
          _buildCard(context, _buildEmptyContent(context)),
          const Spacer(),
          // 테스트 버튼들
          if (DEBUG_MODE) ...[
            _buildTestButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Cloud (2).svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryGreen,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '아직 확인된 예약이 없어요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '예약하기를 눌러 진행해 주세요.',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
      padding: ResponsiveUtils.horizontalPaddingOnly(context),
      child: Column(
        children: [
          _buildCard(context, _buildReservationContent(context, reservation)),
          const Spacer(),
          // 테스트 버튼들
          if (DEBUG_MODE) ...[
            _buildTestButtons(context),
          ],
        ],
      ),
    );
  }

  // 통합된 카드 위젯
  Widget _buildCard(BuildContext context, Widget content) {
    return SizedBox(
      height: ResponsiveUtils.heightPercent(context, 55), // 카드 고정 높이 55%
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 카드 배경 SVG
          SvgPicture.asset(
            'assets/images/Card.svg',
            width: MediaQuery.of(context).size.width - ResponsiveUtils.widthPercent(context, 10), // 좌우 여백 4%씩
            height: ResponsiveUtils.heightPercent(context, 55),
            fit: BoxFit.fill,
          ),
          // 카드 내용
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.widthPercent(context, 10), // 카드 내부 좌우 여백 8%
                vertical: ResponsiveUtils.heightPercent(context, 6), // 카드 내부 상하 여백 6%
              ),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화 (오버플로우만 방지)
              child: content,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildReservationContent(BuildContext context, dynamic reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상태 인디케이터와 구분선
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: ResponsiveUtils.spacing(context, SpacingSize.lg),
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: const Color(0xFFC9CCCB),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusIndicator(context, reservation),
              SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
              Text(
                _getStatusMessage(reservation.status),
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF858585),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
        // 호출됨 상태
        if (reservation.status == 'CALLED' && reservation.roomName != null) ...[
          Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/Cloud (1).svg',
                  width: 60,
                  height: 60,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primaryGreen,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${reservation.roomName}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '진료실로 입장해주세요',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoColumn('예약 시간', _formatTime(reservation.time)),
                    _buildInfoColumn('진료과', reservation.department ?? '내과'),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // 예약 완료/대기 중 상태
          _buildReservationInfo(context, reservation),
        ],
      ],
    );
  }
  
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildStatusIndicator(BuildContext context, dynamic reservation) {
    String svgPath;
    String text;
    
    switch (reservation.status) {
      case 'SCHEDULED':
        svgPath = 'assets/images/상태 아이콘/Vector.svg';
        text = '예약 완료';
        break;
      case 'ARRIVED':
        svgPath = 'assets/images/상태 아이콘/DotsThree.svg';
        text = '대기 중';
        break;
      case 'CALLED':
        svgPath = 'assets/images/상태 아이콘/Frame 2612779.svg';
        text = '호출됨';
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, FontSize.xl), // 24px 상당
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationInfo(BuildContext context, dynamic reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 방문 예정 날짜
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '방문 예정 날짜',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md), // 16px 상당
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)), // 12px 상당
            Row(
              children: [
                Text(
                  _formatDate(reservation.appointmentDate),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.xl), // 24px 상당
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.md)), // 16px 상당
                if (_getDaysDifference(reservation.appointmentDate) >= 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.widthPercent(context, 3), // 12px 상당
                      vertical: ResponsiveUtils.heightPercent(context, 0.5), // 4px 상당
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13D094),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _getDaysDifference(reservation.appointmentDate) == 0 
                        ? 'D-Day' 
                        : 'D-${_getDaysDifference(reservation.appointmentDate)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, FontSize.sm), // 14px 상당
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFCFFFE),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)), // 24px 상당
        // 방문 예정 시간
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '방문 예정 시간',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md), // 16px 상당
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)), // 12px 상당
            Text(
              _formatTime(reservation.appointmentTime),
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xl), // 24px 상당
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)), // 24px 상당
        // 진료과
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '진료과',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md), // 16px 상당
                fontWeight: FontWeight.w500,
                color: const Color(0xFF858585),
              ),
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)), // 12px 상당
            Text(
              reservation.department ?? '내과',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xl), // 24px 상당
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
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

  int _getDaysDifference(String date) {
    // 예약 날짜까지 남은 일수 계산
    try {
      final parts = date.split('-');
      final appointmentDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      final difference = appointmentDate.difference(todayMidnight).inDays;
      return difference;
    } catch (e) {
      return -1; // 에러 시 -1 반환 (D-day 표시 안 함)
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppointmentInitialView(),
              ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text(
                '예약하기',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
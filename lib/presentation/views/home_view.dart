import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/widgets/gradient_background.dart';
import '../bloc/reservation/reservation_bloc.dart';
import '../bloc/reservation/reservation_state.dart';
import '../bloc/reservation/reservation_event.dart';
import '../bloc/ble/ble_bloc.dart';
import '../bloc/ble/ble_event.dart';
import '../bloc/ble/ble_state.dart';
import 'appointment_initial_view.dart';
import '../../injection_container.dart' as di;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? _memberId;
  late BleBloc _bleBloc;
  bool _isScanning = false;
  dynamic _todayAppointment;
  
  @override
  void initState() {
    super.initState();
    _bleBloc = di.sl<BleBloc>();
    _loadUserInfo();
    _listenToBleState();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final memberId = prefs.getInt('member_id');
    
    if (mounted) {
      setState(() {
        _memberId = memberId;
      });
      
      // memberId가 있으면 예약 목록 조회
      if (memberId != null) {
        context.read<ReservationBloc>().add(LoadReservations(memberId: memberId));
      }
    }
  }

  @override
  void dispose() {
    _stopBleScanning();
    _pageController.dispose();
    _bleBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 홈화면에서는 뒤로가기 방지
      child: GradientScaffold(
            body: Column(
              children: [
                // 상단 헤더 (병원 로고 + 설정 버튼)
                _buildHeader(context),
                
                // 예약 카드 영역
                Expanded(
                  child: BlocBuilder<ReservationBloc, ReservationState>(
                        builder: (context, state) {
                          // print('[HomeView] ReservationState: $state');
                          if (state is ReservationLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is ReservationLoaded) {
                            // print('[HomeView] 예약 목록 조회 완료: ${state.reservations.length}개');
                            // 예약 정렬: 오늘 예약 우선, 그 다음 날짜순
                            final sortedReservations = _sortReservations(state.reservations);
                            
                            // 오늘 예약 확인 및 BLE 스캔 처리
                            _checkTodayAppointmentAndStartBLE(sortedReservations);
                            
                            if (sortedReservations.isEmpty) {
                              return _buildEmptyState(context);
                            } else {
                              return _buildReservationPages(context, sortedReservations);
                            }
                          } else if (state is ReservationError) {
                            // print('[HomeView] 예약 조회 에러: ${state.message}');
                            return Center(child: Text(state.message));
                          }
                          return _buildEmptyState(context);
                        },
                  ),
                ),
                
                // 하단 예약하기 버튼
                _buildBottomButton(context),
              ],
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

  // 헤더 위젯: 병원 로고와 설정 버튼
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
              SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
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

  // 예약이 없을 때 표시되는 화면
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.horizontalPaddingOnly(context),
      child: Column(
        children: [
          _buildCard(context, _buildEmptyContent(context)),
          SizedBox(height: ResponsiveUtils.heightPercent(context, 3)), // 화면 높이의 3%
        ],
      ),
    );
  }

  // 예약 없음 이미지 표시
  Widget _buildEmptyContent(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/No reservation.svg',
        width: MediaQuery.of(context).size.width - ResponsiveUtils.widthPercent(context, 20), // 좌우 여백 10%씩
        height: ResponsiveUtils.heightPercent(context, 40), // 카드 내부 높이의 약 80%
        fit: BoxFit.contain,
      ),
    );
  }

  // 여러 예약 카드를 스와이프 가능한 페이지로 표시
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

  // 개별 예약 카드 빌드
  Widget _buildReservationCard(BuildContext context, dynamic reservation) {
    return Padding(
      padding: ResponsiveUtils.horizontalPaddingOnly(context),
      child: Column(
        children: [
          _buildCard(context, _buildReservationContent(context, reservation)),
          SizedBox(height: ResponsiveUtils.heightPercent(context, 3)), // 화면 높이의 3%
        ],
      ),
    );
  }

  // 통합된 카드 위젯
  // 카드 배경 SVG와 내용을 담는 컨테이너
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
              physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화 (오버플로우만 방지)
              child: content,
            ),
          ),
        ),
      ],
      ),
    );
  }

  // 예약 상세 정보 표시
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
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Color(0xFFC9CCCB),
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
        // 호출됨 상태일 때 진료실 정보 표시
        if (reservation.status == 'CALLED') ...[
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
                SizedBox(height: ResponsiveUtils.heightPercent(context, 3)),
                Text(
                  '${reservation.roomName ?? "진료실"}',
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
                SizedBox(height: ResponsiveUtils.heightPercent(context, 6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoColumn('예약 시간', _formatTime(reservation.appointmentTime)),
                    _buildInfoColumn('진료과', reservation.department ?? '내과'),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // 일반 예약 상태 (예약 완료/대기 중)
          _buildReservationInfo(context, reservation),
        ],
      ],
    );
  }
  
  // 라벨과 값을 세로로 표시하는 컴포넌트 (호출됨 상태에서 사용)
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
        SizedBox(height: ResponsiveUtils.heightPercent(context, 0.5)),
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

  // 예약 상태 아이콘과 텍스트 표시
  Widget _buildStatusIndicator(BuildContext context, dynamic reservation) {
    String svgPath;
    String text;
    
    switch (reservation.status) {
      case 'SCHEDULED':
        svgPath = 'assets/images/상태 아이콘/Vector.svg';
        text = '예약 완료';
        break;
      case 'CHECKED_IN':
      case 'ARRIVED':
        svgPath = 'assets/images/상태 아이콘/DotsThree.svg';
        text = '대기 중';
        break;
      case 'CALLED':
        svgPath = 'assets/images/상태 아이콘/Frame 2612779.svg';
        text = '호출됨';
        break;
      default:
        // 기본값으로 예약 완료 표시
        svgPath = 'assets/images/상태 아이콘/Vector.svg';
        text = '예약 완료';
        break;
    }
    
    return Row(
      children: [
        SvgPicture.asset(
          svgPath,
          width: 24,
          height: 24,
        ),
        SizedBox(width: ResponsiveUtils.widthPercent(context, 2)),
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

  // 예약 정보 (날짜, 시간, 진료과) 상세 표시
  Widget _buildReservationInfo(BuildContext context, dynamic reservation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 방문 예정 날짜 섹션
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
        // 방문 예정 시간 섹션
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
        // 진료과 섹션
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

  // 날짜 포맷팅: 2024-12-31 -> 2024년 12월 31일
  String _formatDate(String date) {
    final parts = date.split('-');
    return '${parts[0]}년 ${int.parse(parts[1])}월 ${int.parse(parts[2])}일';
  }

  // 시간 포맷팅: 14:30 -> 오후 2:30
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    
    if (hour < 12) {
      return '오전 ${hour == 0 ? 12 : hour}:$minute';
    } else {
      return '오후 ${hour == 12 ? 12 : hour - 12}:$minute';
    }
  }

  // D-Day 계산 (예약일까지 남은 일수)
  int _getDaysDifference(String date) {
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

  // 페이지 인디케이터 (점으로 현재 페이지 표시)
  Widget _buildPageIndicator(int pageCount) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.heightPercent(context, 1), // 상하 패딩
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pageCount,
          (index) => Container(
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.widthPercent(context, 1),
            ),
            width: ResponsiveUtils.widthPercent(context, 2),
            height: ResponsiveUtils.widthPercent(context, 2),
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

  // 하단 예약하기 버튼
  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.lg)),
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
              SizedBox(width: ResponsiveUtils.widthPercent(context, 1)),
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

  // 상태별 안내 메시지 반환
  String _getStatusMessage(String status) {
    switch (status) {
      case 'SCHEDULED':
        return '예약시간에 맞게 도착해 주세요';
      case 'CHECKED_IN':
      case 'ARRIVED':
        return '병원에서 내원여부를 확인했어요';
      case 'CALLED':
        return '호출된 진료실로 와주세요!';
      default:
        return '예약시간에 맞게 도착해 주세요';
    }
  }
  
  // BLE 상태 리스닝
  void _listenToBleState() {
    _bleBloc.stream.listen((state) {
      // print('[HomeView] BLE 상태 변경: ${state.runtimeType}');
      
      if (state is BleBluetoothOff) {
        // print('[HomeView] 블루투스가 꺼져있음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('블루투스를 켜주세요'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (state is BlePermissionDenied) {
        // print('[HomeView] BLE 권한이 거부됨');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('블루투스 권한이 필요합니다'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (state is HospitalBeaconDetected) {
        print('[HomeView] 병원 비콘 감지됨! 체크인 자동 처리');
        // 체크인 성공 시 BLE 스캔이 자동으로 중지됨
        
        // 예약 목록 다시 로드하여 상태 업데이트
        if (_memberId != null) {
          Future.delayed(const Duration(seconds: 2), () {
            // 체크인 처리 완료 후 예약 목록 새로고침
            if (mounted) {
              context.read<ReservationBloc>().add(LoadReservations(memberId: _memberId!));
              
              // 스낵바로 체크인 완료 알림
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('체크인이 완료되었습니다!'),
                  backgroundColor: AppColors.primaryGreen,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        }
      }
    });
  }
  
  // 오늘 예약 확인 및 BLE 스캔 시작
  void _checkTodayAppointmentAndStartBLE(List<dynamic> reservations) {
    // print('[HomeView] _checkTodayAppointmentAndStartBLE 호출');
    // print('[HomeView] 예약 개수: ${reservations.length}');
    // print('[HomeView] 현재 스캔 중: $_isScanning');
    
    if (_isScanning) {
      // print('[HomeView] 이미 스캔 중이므로 중단');
      return; // 이미 스캔 중이면 중복 실행 방지
    }
    
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    // print('[HomeView] 오늘 날짜: $todayStr');
    
    print('====================================');
    print('[테스트] 첫 번째 WAITING 예약으로 체크인 테스트');
    
    // 오늘 예약 찾기 (테스트: 날짜 관계없이 첫 WAITING 예약 사용)
    for (var reservation in reservations) {
      // 테스트용: 날짜 관계없이 첫 번째 WAITING 예약 사용
      if (reservation.status == 'WAITING') {
      // 원래 코드: if (reservation.appointmentDate == todayStr) {
        _todayAppointment = reservation;
        print('예약 발견!');
        print('예약 ID: ${reservation.appointmentId}');
        print('예약 날짜: ${reservation.appointmentDate}');
        print('예약 시간: ${reservation.appointmentTime}');
        print('예약 상태: ${reservation.status}');
        
        // SCHEDULED 또는 WAITING 상태일 때 BLE 스캔 시작
        if (reservation.status == 'SCHEDULED' || reservation.status == 'WAITING') {
          print('→ BLE 스캔 시작');
          print('====================================');
          _startBleScanning(
            appointmentId: reservation.appointmentId,
            memberId: _memberId ?? 0,
          );
        } else if (reservation.status == 'ARRIVED' || reservation.status == 'CHECKED_IN') {
          print('→ 이미 체크인 완료, BLE 스캔 불필요');
          print('====================================');
          _stopBleScanning();
        } else {
          print('→ 상태(${reservation.status})로 인해 BLE 스캔 안 함');
          print('====================================');
        }
        break;
      }
    }
    
    if (_todayAppointment == null) {
      print('WAITING 상태 예약 없음');
      print('====================================');
    }
  }
  
  // BLE 스캔 시작
  void _startBleScanning({required int appointmentId, required int memberId}) async {
    if (_isScanning) return;
    
    // print('[HomeView] BLE 스캔 시작 - appointmentId: $appointmentId, memberId: $memberId');
    _isScanning = true;
    
    // BLE 권한 체크 먼저
    // print('[HomeView] CheckPermissions 이벤트 전송');
    _bleBloc.add(CheckPermissions());
    
    // iOS에서는 권한 체크 후 약간의 딜레이가 필요
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    
    // 실제 스캔 시작 (appointmentId와 memberId 전달)
    // print('[HomeView] StartScanning 이벤트 전송');
    _bleBloc.add(StartScanning(
      appointmentId: appointmentId,
      memberId: memberId,
    ));
  }
  
  // BLE 스캔 중지
  void _stopBleScanning() {
    if (!_isScanning) return;
    
    // print('[HomeView] BLE 스캔 중지');
    _isScanning = false;
    _bleBloc.add(StopScanning());
  }
}
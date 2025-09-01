import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import '../bloc/reservation/reservation_bloc.dart';
import '../bloc/reservation/reservation_state.dart';
import '../bloc/reservation/reservation_event.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<ReservationBloc>().add(LoadReservations());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    if (state.reservations.isEmpty) {
                      return _buildEmptyState(context);
                    } else {
                      return _buildReservationPages(context, state);
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
    );
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
              // 설정 화면으로 이동
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
            '김호중님,',
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
                    Icons.sentiment_satisfied_alt,
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
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildReservationPages(BuildContext context, ReservationLoaded state) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.reservations.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildReservationCard(context, state.reservations[index]);
            },
          ),
        ),
        if (state.reservations.length > 1)
          _buildPageIndicator(state.reservations.length),
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
            '김호중님,',
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
                SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xl)),
                _buildReservationInfo(context, reservation),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, dynamic reservation) {
    switch (reservation.status) {
      case 'confirmed':
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
              const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
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
      case 'waiting':
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
      case 'called':
        return Column(
          children: [
            Container(
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
                  const Icon(Icons.error, color: Colors.red, size: 20),
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
            ),
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.lg)),
            Text(
              '${reservation.callNumber}번',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.xxxl),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '창구로 입장해주세요',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReservationInfo(BuildContext context, dynamic reservation) {
    if (reservation.status == 'called') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '예약 시간',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                reservation.time ?? '오전 10:30',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '진료과',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                reservation.department ?? '내과',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('예약 날짜', reservation.date ?? '2025년 8월 31일'),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          _buildInfoRow('예약 시간', reservation.time ?? '오전 10:30'),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          _buildInfoRow('진료과', reservation.department ?? '내과'),
        ],
      );
    }
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
            // 예약하기 화면으로 이동
            context.read<ReservationBloc>().add(CreateReservation());
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.primaryGreen;
      case 'waiting':
        return Colors.blue;
      case 'called':
        return Colors.red;
      default:
        return AppColors.grayLight;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'confirmed':
        return '예약시간에 맞게 도착해 주세요';
      case 'waiting':
        return '병원에서 내원여부를 확인했어요';
      case 'called':
        return '호출된 창구로 와주세요!';
      default:
        return '';
    }
  }
}
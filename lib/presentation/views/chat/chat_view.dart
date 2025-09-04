import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../domain/entities/chat/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/custom_back_button.dart';
import '../general_appointment_view.dart';

class ChatView extends StatefulWidget {
  final int? memberId;
  final String? initialMessage;

  const ChatView({
    super.key,
    this.memberId,
    this.initialMessage,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  int? _memberId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // widget.memberId가 없으면 SharedPreferences에서 가져오기
    if (widget.memberId != null) {
      _memberId = widget.memberId;
    } else {
      final prefs = await SharedPreferences.getInstance();
      _memberId = prefs.getInt('member_id');
    }
    
    // memberId가 있으면 채팅 세션 시작
    if (_memberId != null && mounted) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.startChatSession(_memberId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.sendMessage(text);
    _messageController.clear();
    
    // 스크롤을 최하단으로
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            
            // 메시지 영역
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.errorMessage != null && provider.messages.isEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: ResponsiveUtils.defaultPadding(context),
                    itemCount: provider.messages.length + (provider.isTyping ? 1 : 0) + 1, // +1 챗봇 안내 메세지
                    itemBuilder: (context, index) {
                      // Typing indicator at bottom
                      if (provider.isTyping && index == 0) {
                        return _buildTypingIndicator();
                      }
                      
                      // 챗봇 안내 메세지와 버튼
                      final totalMessages = provider.messages.length + (provider.isTyping ? 1 : 0);
                      if (index == totalMessages) {
                        return Column(
                          children: [
                            // 안내 메시지 카드
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ResponsiveUtils.spacing(context, SpacingSize.md),
                              ),
                              child: _buildWelcomeCard(),
                            ),
                            
                            // 일반 예약으로 전환 버튼 (카드 밖)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ResponsiveUtils.spacing(context, SpacingSize.md),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const GeneralAppointmentView(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.surfaceLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveUtils.spacing(context, SpacingSize.lg),
                                    vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
                                  ),
                                ),
                                child: Text(
                                  '일반 예약으로 전환해줘',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      // Regular messages
                      final messageIndex = provider.isTyping ? index - 1 : index;
                      final message = provider.messages[messageIndex];
                      return _buildMessageBubble(message, provider);
                    },
                  );
                },
              ),
            ),
            
            // 입력 영역
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      child: Row(
        children: [
          const CustomBackButton(),
          Expanded(
            child: Center(
              child: Text(
                'AI 예약 도우미',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.xl),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.lg)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ChatProvider provider) {
    final isUser = message.senderType == SenderType.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.spacing(context, SpacingSize.xs),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser 
                      ? const Radius.circular(16)
                      : Radius.zero,
                  bottomRight: isUser 
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            
            // AI 분석 결과 표시
            if (!isUser && provider.currentSession?.symptomAnalysis != null)
              _buildAnalysisCard(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(ChatProvider provider) {
    final analysis = provider.currentSession!.symptomAnalysis!;
    
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveUtils.spacing(context, SpacingSize.sm),
      ),
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.primaryGreen,
                size: ResponsiveUtils.iconSize(context, IconSizeType.small),
              ),
              SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.xs)),
              Text(
                '추천 진료과',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.spacing(context, SpacingSize.sm),
              vertical: ResponsiveUtils.spacing(context, SpacingSize.xs),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
            ),
            child: Text(
              analysis.recommendedDepartment,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.lg),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          
          if (analysis.confidenceScore >= 0.8) ...[
            SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
            Text(
              '신뢰도: ${(analysis.confidenceScore * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: AppColors.textSecondary,
              ),
            ),
          ],
          
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 예약 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GeneralAppointmentView(
                      initialDepartment: analysis.recommendedDepartment,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.small),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                ),
              ),
              child: Text(
                '바로 예약하기',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.spacing(context, SpacingSize.xs),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
          vertical: ResponsiveUtils.spacing(context, SpacingSize.sm),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.xs)),
            _buildDot(1),
            SizedBox(width: ResponsiveUtils.spacing(context, SpacingSize.xs)),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.md)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
          border: Border.all(
            color: AppColors.grayLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '증상을 자세히 알려주세요...',
                  hintStyle: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing(context, SpacingSize.md),
                    vertical: ResponsiveUtils.spacing(context, SpacingSize.md),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Container(
              margin: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.xs)),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing(context, SpacingSize.lg)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: ResponsiveUtils.borderRadius(context, RadiusSize.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요! AI 병원 예약 도우미입니다. 😊',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.md),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.sm)),
          Text(
            '어떤 증상으로 문의해주셨나요? 자세히 말씀해 주시면 적절한 진료과를 추천해 드리겠습니다.',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.md)),
          
          // 예약 과정
          Text(
            '📝 예약 과정:',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: ResponsiveUtils.spacing(context, SpacingSize.xs)),
          _buildStepItem('1. 증상 설명 → 진료과 추천'),
          _buildStepItem('2. 예약 날짜와 시간 알려주기'),
          _buildStepItem('3. 구름대병원 예약 완료! ✅'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.spacing(context, SpacingSize.xs)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(
              top: ResponsiveUtils.spacing(context, SpacingSize.xs),
              right: ResponsiveUtils.spacing(context, SpacingSize.sm),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, FontSize.sm),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
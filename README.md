# 🏥 CareFreePass - 병원 방문을 편하게
  
  **디지털 취약 계층도 쉽게 사용하는 스마트 병원 체크인 시스템**

## 📌 프로젝트 소개

**CareFreePass**는 병원 방문이 익숙하지 않은 700만 디지털 취약 계층을 위해, **도착 인식부터 진료 호출까지** 모든 과정을 자동화한 스마트 헬스케어 솔루션입니다.

### 🎯 핵심 가치
> **"아무것도 하지 않아도 모든 것이 자동으로"**

키오스크도, QR 코드도 필요 없습니다. 그저 병원에 들어서기만 하면 됩니다.

---

## 🚀 주요 기능

### 1️⃣ **BLE 자동 체크인** 
- 병원 입구 진입 시 **Zero Touch** 자동 체크인
- SHA-256 해싱으로 보안 강화
- 3초 내 체크인 완료

### 2️⃣ **AI 챗봇 상담** 🤖
- 자연어로 증상 입력
- AI가 적절한 진료과 추천
- 예약까지 원스톱 처리

### 3️⃣ **개인 맞춤 호출** 📱
- 1초 간격 실시간 상태 확인 (폴링)
- 진료 순서 도래 시 즉시 푸시 알림
- 청각 장애인용 시각 알림 지원

### 4️⃣ **접근성 최우선 UI** ♿
- 초대형 글씨 (노인 친화적)
- 고대비 색상 (시각 장애 대응)
- 원터치 인터페이스

---

## 🔐 BLE 보안 (SHA-256)

### 보안 3단계 프로세스

```
1. Detection (감지)
   └─ 병원 BLE 비콘 신호 자동 감지

2. Authentication (인증)  
   └─ SHA-256 해시값 검증 (5ED4A4459CA1)
   
3. Check-in (체크인)
   └─ 환자 정보 매칭 → 자동 체크인 완료
```

### 🛡️ SHA-256 보안 구현
```dart
// 원본 (절대 전송 안 함)
String hospitalId = "Goormhospital";
String password = "123456";

// SHA-256 해싱
String fullHash = sha256("Goormhospital123456");
// = "5ed4a4459ca1d4bd7dd023d17aad8f89a1f2847c479eb7430aca84ef43543170"

// 실제 전송값 (상위 12자리만)
String beacon = "5ED4A4459CA1";  // 복호화 불가능
```

**💡 핵심**: 원본 정보는 절대 전송되지 않으며, 해시값 탈취 시에도 역산 불가능

---

## 🛠️ 기술 스택

### Frontend (Mobile)
- **Flutter 3.8.1** - 크로스플랫폼 앱 개발
- **Dart** - 프로그래밍 언어
- **Clean Architecture** - 확장 가능한 구조

### 상태 관리
- **Bloc 8.1.2** - 비즈니스 로직 분리
- **Provider 6.1.1** - 채팅 기능 상태 관리
- **GetIt 7.6.4** - 의존성 주입

### BLE & 네트워크
- **flutter_blue_plus 1.31.13** - BLE 통신
- **HTTP 1.1.0** - REST API
- **WebSocket 2.4.0** - 실시간 통신
- **Crypto 3.0.3** - SHA-256 해싱

### UI/UX
- **flutter_svg 2.0.10** - SVG 렌더링
- **flutter_screenutil 5.9.0** - 반응형 UI
- **Material Design 3** - 디자인 시스템

---

## 📂 프로젝트 구조

```
lib/
├── core/                 # 핵심 공통 기능
│   ├── constants/       # 색상, 상수
│   ├── utils/          # 유틸리티 (암호화, 반응형)
│   └── widgets/        # 공통 위젯
│
├── domain/              # 비즈니스 로직
│   ├── entities/       # 도메인 모델
│   ├── repositories/   # 레포지토리 인터페이스
│   └── usecases/       # 유즈케이스
│
├── data/                # 데이터 레이어
│   ├── datasources/    # API, BLE 통신
│   ├── models/         # 데이터 모델
│   └── repositories/   # 레포지토리 구현
│
└── presentation/        # UI 레이어
    ├── bloc/           # Bloc 상태 관리
    ├── views/          # 화면
    └── providers/      # Provider 상태 관리
```

---

## ⚡ 시작하기

### 필수 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK 3.0 이상
- iOS: Xcode 14.0 이상
- Android: Android Studio

### 설치 및 실행

```bash
# 1. 레포지토리 클론
git clone https://github.com/yourusername/carefreepass.git
cd carefreepass

# 2. 의존성 설치
flutter pub get

# 3. 앱 실행
flutter run

# 4. APK 빌드 (Android)
flutter build apk --release

# 5. IPA 빌드 (iOS)
flutter build ios --release
```

### BLE 테스트 설정

#### Android (비콘 역할)
1. nRF Connect 앱 설치
2. Advertiser 모드 선택
3. Device Name: `5ED4A4459CA1` 입력
4. Start Advertising

#### iOS/Android (환자 앱)
1. 앱 실행
2. 블루투스/위치 권한 허용
3. 병원 비콘 자동 감지

---

## 🌐 API 엔드포인트

### 인증
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/signup` - 회원가입
- `POST /api/v1/auth/refresh` - 토큰 갱신

### 예약 관리
- `GET /api/v1/appointments/my` - 내 예약 목록
- `POST /api/v1/appointments` - 예약 생성
- `PUT /api/v1/appointments/checkin` - 체크인

### AI 챗봇
- `POST /api/v1/chat/start` - 채팅 시작
- `POST /api/v1/chat/message` - 메시지 전송
- `GET /api/v1/chat/history` - 대화 내역

### 알림 (폴링)
- `GET /api/v1/notifications` - 알림 조회 (2초 간격)

---

## 📱 화면 구성

| 스플래시 | 로그인 | 홈 화면 | AI 챗봇 |
|---------|--------|---------|---------|
| ![Splash](docs/screenshots/splash.png) | ![Login](docs/screenshots/login.png) | ![Home](docs/screenshots/home.png) | ![Chat](docs/screenshots/chat.png) |

---

## 🏆 프로젝트 성과

- ✅ **BLE 자동 체크인** 구현 완료
- ✅ **SHA-256 보안** 적용
- ✅ **AI 챗봇** 통합
- ✅ **1초 실시간 폴링** 시스템
- ✅ **접근성 UI/UX** 최적화

---

## 👥 팀 정보

**2025 SEASONTHON TEAM 45**

| 역할 | 담당 | 기술 스택 |
|------|------|----------|
| Frontend | 앱 개발 | Flutter, Dart, Bloc |
| Backend | API 서버 | Spring Boot, MySQL |
| Design | UI/UX | Figma, SVG |
| PM | 기획 | 의료 도메인 전문 |

  Made with ❤️ by Team 45

// lib/main.dart
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/intro_screen.dart'; // ★ import 추가
import 'services/notification_service.dart'; // import 추가
import 'screens/payment_success_screen.dart'; // 결제 성공 화면
import 'screens/payment_fail_screen.dart'; // 결제 실패 화면

// 보안 인증서 무시
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  HttpOverrides.global = MyHttpOverrides();

  // 👇 [추가] 알림 서비스 초기화
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SJ Project',
      // ★★★ [여기 추가!] 마우스 드래그로도 스와이프가 되도록 허용 ★★★
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse, // 핵심: 마우스 허용
          PointerDeviceKind.trackpad,
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
        Locale('ja', 'JP'), // 일본어
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D3436)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Pretendard',
        ),
      ),

      // ★ 라우팅 추가
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroScreen(),
        '/home': (context) => const HomeScreen(),
        '/payment-success': (context) => const PaymentSuccessScreen(),
        '/payment-fail': (context) => const PaymentFailScreen(),
      },
    );
  }
}

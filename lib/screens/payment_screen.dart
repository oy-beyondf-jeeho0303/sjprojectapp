import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import '../utils/localization_data.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String orderName;
  final int amount;
  final String targetLanguage;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
    this.targetLanguage = 'ko',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ★ [테스트용 클라이언트 키]
  final String _clientKey = "test_ck_6bJXmgo28e1oxJ4kwWzw8LAnGKWx";
  late String _customerKey;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _customerKey = "USER_${DateTime.now().millisecondsSinceEpoch}";

    // 화면이 로드되면 자동으로 결제 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPayment();
      _setupPaymentResultListener();
    });
  }

  // ★ [추가] postMessage 이벤트 리스너 설정
  void _setupPaymentResultListener() {
    // URL 체크를 주기적으로 수행하여 결제 완료 감지
    Future.delayed(const Duration(seconds: 1), () {
      _checkPaymentStatus();
    });
  }

  void _checkPaymentStatus() async {
    try {
      // 현재 URL에서 쿼리 파라미터 체크
      final currentUrl = html.window.location.href;
      print('🔍 현재 URL 체크: $currentUrl');

      final uri = Uri.parse(currentUrl);

      if (uri.queryParameters.containsKey('payment')) {
        final paymentStatus = uri.queryParameters['payment'];
        print('💰 payment 파라미터 발견: $paymentStatus');

        if (paymentStatus == 'success') {
          // 결제 성공!
          final paymentKey = uri.queryParameters['paymentKey'] ?? '';
          final orderId = uri.queryParameters['orderId'] ?? '';
          final amountStr = uri.queryParameters['amount'] ?? '0';

          print('✅ 결제 완료 감지! paymentKey=$paymentKey, orderId=$orderId, amount=$amountStr');

          // HomeScreen으로 결과 반환
          if (mounted) {
            Navigator.pop(context, {
              'success': true,
              'paymentKey': paymentKey,
              'orderId': orderId,
              'amount': int.tryParse(amountStr) ?? 0,
            });
          }
          return;
        } else if (paymentStatus == 'fail') {
          // 결제 실패
          final errorMessage = uri.queryParameters['message'] ?? AppLocale.get(widget.targetLanguage, 'msg_payment_failed');

          print('❌ 결제 실패: $errorMessage');

          if (mounted) {
            Navigator.pop(context, {
              'success': false,
              'message': errorMessage,
            });
          }
          return;
        }
      } else {
        print('⏳ payment 파라미터 없음, 1초 후 재시도...');
      }

      // 아직 결제 완료 안 됨 - 1초 후 다시 체크
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          _checkPaymentStatus();
        });
      }
    } catch (e) {
      print('❌ 결제 상태 체크 오류: $e');
      // 오류 발생 시에도 계속 체크
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          _checkPaymentStatus();
        });
      }
    }
  }

  void _requestPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 현재 URL 가져오기
      final currentUrl = html.window.location.href;
      final baseUrl = currentUrl.split('#')[0].split('?')[0];

      // 토스페이먼츠 V1 SDK 사용
      final tossPayments = js.JsObject(js.context['TossPayments'], [_clientKey]);

      tossPayments.callMethod('requestPayment', [
        '카드', // 결제 수단
        js.JsObject.jsify({
          'amount': widget.amount,
          'orderId': widget.orderId,
          'orderName': widget.orderName,
          'successUrl': '$baseUrl?payment=success#/home',
          'failUrl': '$baseUrl?payment=fail#/home',
        })
      ]);

    } catch (e) {
      print('결제 요청 에러: $e');
      if (mounted) {
        Navigator.pop(context, {
          'success': false,
          'message': '${AppLocale.get(widget.targetLanguage, 'msg_error')}: $e',
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.targetLanguage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocale.get(lang, 'payment_title')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF3182F6),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocale.get(lang, 'payment_redirecting'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.amount}원',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

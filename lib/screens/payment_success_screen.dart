import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../home_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String? paymentKey;
  String? orderId;
  String? amount;

  @override
  void initState() {
    super.initState();
    _parseUrlParams();
  }

  void _parseUrlParams() {
    // URL 파라미터 파싱
    final uri = Uri.parse(html.window.location.href);
    setState(() {
      paymentKey = uri.queryParameters['paymentKey'];
      orderId = uri.queryParameters['orderId'];
      amount = uri.queryParameters['amount'];
    });

    // 결제 결과를 localStorage에 저장
    if (paymentKey != null) {
      html.window.localStorage['payment_result'] = 'success';
      html.window.localStorage['payment_key'] = paymentKey!;
      html.window.localStorage['order_id'] = orderId ?? '';
      html.window.localStorage['amount'] = amount ?? '';
    }

    // 2초 후 홈 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '결제가 완료되었습니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),
            if (amount != null)
              Text(
                '결제 금액: $amount원',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            if (orderId != null)
              Text(
                '주문번호: $orderId',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF3182F6),
            ),
            const SizedBox(height: 12),
            Text(
              '잠시 후 자동으로 이동합니다...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

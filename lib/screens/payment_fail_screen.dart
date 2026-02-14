import 'package:flutter/material.dart';
import 'dart:html' as html;

class PaymentFailScreen extends StatefulWidget {
  const PaymentFailScreen({super.key});

  @override
  State<PaymentFailScreen> createState() => _PaymentFailScreenState();
}

class _PaymentFailScreenState extends State<PaymentFailScreen> {
  String? code;
  String? message;

  @override
  void initState() {
    super.initState();
    _parseUrlParams();
  }

  void _parseUrlParams() {
    // URL 파라미터 파싱
    final uri = Uri.parse(html.window.location.href);
    setState(() {
      code = uri.queryParameters['code'];
      message = uri.queryParameters['message'];
    });

    // 결제 실패 결과를 localStorage에 저장
    html.window.localStorage['payment_result'] = 'fail';
    html.window.localStorage['payment_error_code'] = code ?? '';
    html.window.localStorage['payment_error_message'] = message ?? '';

    // 3초 후 홈 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Color(0xFFF44336),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '결제에 실패했습니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),
              if (message != null)
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 8),
              if (code != null)
                Text(
                  '오류 코드: $code',
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
      ),
    );
  }
}

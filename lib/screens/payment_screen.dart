import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String orderName;
  final int amount;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ★ [테스트용 클라이언트 키]
  // 실 서비스 배포 시에는 토스페이먼츠 개발자센터의 '라이브 클라이언트 키'로 교체해야 합니다.
  final String _clientKey = "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm"; 
  late String _customerKey;

  late PaymentWidget _paymentWidget;
  bool _isReady = false; // 위젯 렌더링 완료 상태

  @override
  void initState() {
    super.initState();
    // 고객 식별 키 생성 (고유해야 함 / 실제 앱에서는 유저 ID 권장)
    _customerKey = "USER_${DateTime.now().millisecondsSinceEpoch}";

    // 1. 위젯 인스턴스 생성
    _paymentWidget = PaymentWidget(
      clientKey: _clientKey,
      customerKey: _customerKey,
    );

    // 2. UI 렌더링 시작
    _renderWidgets();
  }

  Future<void> _renderWidgets() async {
    try {
      // (1) 결제 수단 위젯 렌더링 (일반 결제)
      // 정기결제(Billing) 로직을 제거하고, 넘어온 금액(amount)으로 고정합니다.
      await _paymentWidget.renderPaymentMethods(
        selector: 'methods',
        amount: Amount(
          value: widget.amount, 
          currency: Currency.KRW, // 원화(KRW) 고정
          country: "KR",
        ),
      );

      // (2) 이용약관 위젯 렌더링
      await _paymentWidget.renderAgreement(selector: 'agreement');

      // (3) 준비 완료 상태 업데이트 (버튼 활성화용)
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      print("위젯 렌더링 에러: $e");
    }
  }

  Future<void> _requestPayment() async {
    try {
      // 결제 요청 (일반 결제)
      final paymentResult = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: widget.orderId,
          orderName: widget.orderName,
        ),
      );

      if (!mounted) return;

      // 성공 시 처리
      if (paymentResult.success != null) {
        final success = paymentResult.success!;
        
        // 이전 화면(ResultScreen/HomeScreen)으로 성공 데이터 전달
        Navigator.pop(context, {
          'success': true,
          'paymentKey': success.paymentKey, // 결제 승인 키
          'orderId': success.orderId,
          'amount': success.amount,
        });

      } else if (paymentResult.fail != null) {
        // 실패 시 처리
        final fail = paymentResult.fail!;
        Navigator.pop(context, {
          'success': false,
          'message': fail.errorMessage,
        });
      }
    } catch (e) {
      print("결제 요청 에러: $e");
      // 예외 발생 시 창 닫기 또는 에러 메시지 표시
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("결제하기"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // 글자색 검정
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // 토스 위젯이 들어갈 영역
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  PaymentMethodWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'methods',
                  ),
                  const SizedBox(height: 20),
                  AgreementWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'agreement',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // 하단 결제 버튼 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isReady ? _requestPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6), // 토스 브랜드 컬러 (파랑)
                    disabledBackgroundColor: Colors.grey[300], // 비활성 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isReady 
                        ? "${widget.amount}원 결제하기" 
                        : "로딩 중...",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
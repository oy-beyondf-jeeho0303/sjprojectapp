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
  final String currency;
  final bool isBilling; // 정기결제 여부

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
    required this.currency,
    this.isBilling = false, // 기본값은 일반 결제
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ★ 본인의 클라이언트 키로 교체하세요
  final String _clientKey = "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm"; 
  late String _customerKey;

  late PaymentWidget _paymentWidget;
  bool _isReady = false; // 버튼 활성화 여부

  @override
  void initState() {
    super.initState();
    // 고객 키 생성 (고유해야 함)
    _customerKey = "USER_${DateTime.now().millisecondsSinceEpoch}";

    // 1. 위젯 생성
    _paymentWidget = PaymentWidget(
      clientKey: _clientKey,
      customerKey: _customerKey,
    );

    // 2. 렌더링 시작
    _renderWidgets();
  }

  Future<void> _renderWidgets() async {
    try {
      // (1) 결제 수단 렌더링
      if (!widget.isBilling) {
        // 일반 결제: 금액 표시
        await _paymentWidget.renderPaymentMethods(
          selector: 'methods',
          amount: Amount(
            value: widget.amount,
            currency: widget.currency == 'KRW' ? Currency.KRW : Currency.USD,
          ),
        );
      } else {
        // 정기 결제(빌링): 금액 0원 (카드 등록용)
        await _paymentWidget.renderPaymentMethods(
          selector: 'methods',
          amount: Amount(value: 0, currency: Currency.KRW),
        );
      }

      // (2) 약관 렌더링
      await _paymentWidget.renderAgreement(selector: 'agreement');

      // (3) 준비 완료 상태 업데이트
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
      // ★ [핵심] 위젯 SDK는 'requestBillingAuth'가 없습니다.
      // 결제든 카드 등록이든 무조건 'requestPayment'를 사용합니다.
      final paymentResult = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: widget.orderId,
          orderName: widget.orderName,
     //     successUrl: "https://docs.tosspayments.com/guides/success", 
     //     failUrl: "https://docs.tosspayments.com/guides/fail",
        ),
      );

      if (!mounted) return;

      // 성공 시 처리
      if (paymentResult.success != null) {
        final success = paymentResult.success!;
        
        // ★ [중요] 정기 결제(Billing)일 경우
        // 서버는 'authKey'를 원하므로, 받은 'paymentKey'를 'authKey'로 이름만 바꿔서 줍니다.
        // (위젯 SDK에서는 paymentKey가 곧 카드 등록 인증 키 역할을 합니다)
        if (widget.isBilling) {
           Navigator.pop(context, {
            'success': true,
            'authKey': success.paymentKey, // paymentKey를 authKey로 전달
            'customerKey': _customerKey, // 저장해둔 고객 키 전달
            'orderId': success.orderId,
          });
        } else {
          // 일반 결제일 경우
          Navigator.pop(context, {
            'success': true,
            'paymentKey': success.paymentKey,
            'orderId': success.orderId,
            'amount': success.amount,
            'currency': widget.currency,
          });
        }
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
      // 에러 발생 시 (취소 등) 아무것도 하지 않거나 창 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isBilling ? "정기 결제 수단 등록" : "결제하기"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // 위젯 영역
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
            // 하단 버튼 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  // 렌더링 완료(_isReady) 전에는 버튼 비활성화
                  onPressed: _isReady ? _requestPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isReady 
                        ? (widget.isBilling ? "자동결제 카드 등록하기" : "결제하기") 
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
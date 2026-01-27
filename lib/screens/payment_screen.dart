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
  final String currency; // ★ [추가] 외부에서 'KRW' 또는 'USD'를 받음

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.orderName,
    required this.amount,
    required this.currency, // ★ [추가] 필수 파라미터
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ★ 테스트용 클라이언트 키 (본인 키로 교체 가능)
  final String _clientKey = "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm";
  final String _customerKey =
      "ANONYMOUS_USER_${DateTime.now().millisecondsSinceEpoch}";

  late PaymentWidget _paymentWidget;
  bool _isReady = false; // 버튼 활성화 여부 확인용

  @override
  void initState() {
    super.initState();

    // 1. 위젯 생성
    _paymentWidget = PaymentWidget(
      clientKey: _clientKey,
      customerKey: _customerKey,
    );

    // 2. 렌더링 요청 (화면이 빌드된 후에 실행하지 않아도, 위젯이 트리에 있으면 됨)
    // 하지만 안전을 위해 약간의 딜레이를 주거나 바로 실행
    _initPaymentWidget();
  }

  void _initPaymentWidget() async {
    try {
      // ★ [중요] 받아온 widget.currency에 따라 토스 Currency Enum 설정
      Currency tossCurrency =
          widget.currency == 'USD' ? Currency.USD : Currency.KRW;
      String countryCode = widget.currency == 'USD' ? "US" : "KR";

      // 결제 수단 렌더링
      await _paymentWidget.renderPaymentMethods(
        selector: 'methods',
        amount: Amount(
            value: widget.amount,
            currency: tossCurrency, // ★ 동적으로 설정됨
            country: countryCode),
        options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
      );

      // 이용약관 렌더링
      await _paymentWidget.renderAgreement(selector: 'agreement');

      // 렌더링 성공하면 버튼 활성화
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
      final paymentResult = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: widget.orderId,
          orderName: widget.orderName,
        ),
      );

      if (!mounted) return;

      // 성공/실패 처리
      if (paymentResult.success != null) {
        final success = paymentResult.success!;
        Navigator.pop(context, {
          'success': true,
          'paymentKey': success.paymentKey,
          'orderId': success.orderId,
          'amount': success.amount,
          'currency': 'KRW',
        });
      } else if (paymentResult.fail != null) {
        final fail = paymentResult.fail!;
        Navigator.pop(context, {
          'success': false,
          'message': fail.errorMessage,
        });
      }
    } catch (e) {
      print("결제 요청 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("결제하기"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              // ★ [핵심 수정] _isReady 체크를 제거했습니다.
              // 위젯은 항상 화면에 존재해야 렌더링 함수가 찾을 수 있습니다.
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // 1. 결제 수단 위젯 (selector: 'methods')
                  PaymentMethodWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'methods',
                  ),
                  const SizedBox(height: 20),
                  // 2. 이용약관 위젯 (selector: 'agreement')
                  AgreementWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'agreement',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 하단 결제 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  // ★ 버튼은 렌더링이 끝나야(_isReady) 눌림
                  onPressed: _isReady ? _requestPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6),
                    disabledBackgroundColor: Colors.grey[300], // 비활성 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isReady ? "결제하기" : "로딩 중...",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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

/*import 'package:flutter/material.dart';
// ★ 사용자님이 보내주신 예제에 맞는 import 경로
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
  // ★ [테스트용 키] 보내주신 예제에 있는 테스트 키를 그대로 넣었습니다.
  // 나중에 본인의 'test_ck_...' 키로 교체하시면 됩니다.
  final String _clientKey = "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm";
  // 고객 식별 키 (랜덤 혹은 사용자 ID)
  final String _customerKey =
      "ANONYMOUS_USER_${DateTime.now().millisecondsSinceEpoch}";

  late PaymentWidget _paymentWidget;
  bool _isReady = false; // 위젯 렌더링 완료 여부

  @override
  void initState() {
    super.initState();
    _initPaymentWidget();
  }

  void _initPaymentWidget() async {
    try {
      print("Step 1: 위젯 인스턴스 생성 시작");
      // 1. 위젯 인스턴스 생성
      _paymentWidget = PaymentWidget(
        clientKey: _clientKey,
        customerKey: _customerKey,
      );

      // 2. 결제 수단 위젯 렌더링
      // selector: 'methods'는 화면에 표시할 위젯 영역 ID입니다.
      await _paymentWidget.renderPaymentMethods(
        selector: 'methods',
        amount:
            Amount(value: widget.amount, currency: Currency.KRW, country: "KR"),
        options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
      );
      print("Step 2 완료");

      // 3. 약관 위젯 렌더링
      await _paymentWidget.renderAgreement(selector: 'agreement');
      print("Step 3 완료");

      // 렌더링 완료 후 화면 갱신
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      // ★ 여기서 에러가 잡힙니다! 터미널(Run탭)을 확인하세요.
      print("🔴 위젯 초기화 에러 발생: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("결제 로딩 실패: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 결제 요청 함수
  Future<void> _requestPayment() async {
    try {
      // 4. 결제 요청
      final paymentResult = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: widget.orderId,
          orderName: widget.orderName,
        ),
      );

      // 5. 결과 처리 (보내주신 예제 코드 방식 적용)
      if (!mounted) return;

      // 성공 시 (success 객체가 null이 아님)
      if (paymentResult.success != null) {
        final success = paymentResult.success!;
        // HomeScreen으로 성공 데이터 전달하며 복귀
        Navigator.pop(context, {
          'success': true,
          'paymentKey': success.paymentKey,
          'orderId': success.orderId,
          'amount': success.amount,
        });
      }
      // 실패 시 (fail 객체가 null이 아님)
      else if (paymentResult.fail != null) {
        final fail = paymentResult.fail!;
        // 실패 메시지와 함께 복귀
        Navigator.pop(context, {
          'success': false,
          'message': fail.errorMessage,
        });
      }
    } catch (e) {
      print("결제 요청 중 에러: $e");
      if (mounted) Navigator.pop(context, {'success': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("결제하기"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 위젯 영역 (스크롤 가능)
            Expanded(
              child: _isReady
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // 결제 수단 위젯
                        PaymentMethodWidget(
                          paymentWidget: _paymentWidget,
                          selector: 'methods',
                        ),
                        const SizedBox(height: 20),
                        // 이용약관 위젯
                        AgreementWidget(
                          paymentWidget: _paymentWidget,
                          selector: 'agreement',
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),

            // 하단 결제 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isReady ? _requestPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182F6), // 토스 파랑색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "결제하기",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
*/

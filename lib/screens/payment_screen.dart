import 'package:flutter/material.dart';
// ★ 패키지 설치 후 빨간 줄이 사라질 겁니다.
//import 'package:iamport_flutter/iamport_payment.dart';
//import 'package:iamport_flutter/model/payment_data.dart';

class PaymentScreen extends StatelessWidget {
  // 포트원 관리자 콘솔 -> [결제 연동] -> [내 식별코드] 확인 필요
  // 예시 코드는 테스트용입니다. 본인의 코드로 바꾸세요!
  final String userCode = 'imp35077188';

  final String orderId; // 주문 번호 (고유해야 함)
  final int amount; // 결제 금액
  final String name; // 상품명

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

/*
  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      appBar: AppBar(
        title: const Text('카카오페이 결제'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      initialChild: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      userCode: userCode,
      data: PaymentData(
        pg: 'kakaopay', // PG사: 카카오페이
        payMethod: 'card', // 결제수단: 카드 (카카오페이 머니도 포함됨)
        name: name, // 주문명
        merchantUid: orderId, // 주문번호
        amount: amount, // 금액
        buyerName: '테스트유저', // 구매자 이름 (User 데이터 연동 권장)
        buyerTel: '01012345678', // 구매자 전화번호
        buyerEmail: 'test@test.com', // 구매자 이메일
        appScheme: 'sajuapp', // ★ 중요: AndroidManifest.xml 설정과 같아야 함
      ),
      callback: (Map<String, String> result) {
        // 결제 완료 후 실행되는 콜백
        print('결제 결과: $result');

        if (result['imp_success'] == 'true') {
          // [성공] -> imp_uid와 merchant_uid를 가지고 돌아감
          Navigator.pop(context, {
            'success': true,
            'imp_uid': result['imp_uid'],
            'merchant_uid': result['merchant_uid']
          });
        } else {
          // [실패] -> 에러 메시지를 가지고 돌아감
          Navigator.pop(
              context, {'success': false, 'error_msg': result['error_msg']});
        }
      },
    );
  }
  */
}

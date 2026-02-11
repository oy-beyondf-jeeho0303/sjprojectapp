import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'payment_screen.dart'; // 결제 화면 import (경로 확인 필요)
import '../services/notification_service.dart';


class DailyFortuneCard extends StatefulWidget {
  final String orderId;   
  final String serverUrl; 

  const DailyFortuneCard({
    Key? key,
    required this.orderId,
    required this.serverUrl,
  }) : super(key: key);

  @override
  _DailyFortuneCardState createState() => _DailyFortuneCardState();
}

class _DailyFortuneCardState extends State<DailyFortuneCard> {
  bool isLoading = true;
  bool isSubscribed = false;
  Map<String, dynamic>? fortuneData;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성되자마자 서버 찌르기
    _fetchSubscriptionStatus();
  }

  Future<void> _fetchSubscriptionStatus() async {
    // 주문번호가 없으면 -> 그냥 미구독 상태로 보여주기 (숨기지 않음!)
    if (widget.orderId.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/subscription/status?orderId=${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            isSubscribed = data['isSubscribed'] ?? false;
            if (isSubscribed && data['dailyFortune'] != null) {
              fortuneData = data['dailyFortune'];
            }
          });
        }
      } 
    } catch (e) {
      print("서버 통신 에러 (UI는 띄웁니다): $e");
    } finally {
      // 성공하든 실패하든 로딩은 끝난 걸로 처리 -> 그래야 UI가 보임
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ★ [수정] 로딩 중이어도, 공간을 차지하고 로딩 표시를 보여줍니다 (숨기지 않음)
    if (isLoading) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSubscribed ? Colors.blueAccent.withOpacity(0.3) : const Color(0xFFFFCC80),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 1. 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSubscribed ? Colors.blue.shade50 : const Color(0xFFFFF3E0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(
                  isSubscribed ? Icons.auto_awesome : Icons.lock_clock,
                  color: isSubscribed ? Colors.blue : Colors.orange[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isSubscribed ? "내일의 맞춤 운세 도착" : "내 사주로 분석한 '내일의 운세'",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // 2. 본문
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: isSubscribed ? _buildUnlockedContent() : _buildLockedUpsell(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedContent() {
    String content = fortuneData?['dailyContent'] ?? "운세 데이터를 가져오는 중입니다.";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text("정통 명리학 분석 완료", style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        )
      ],
    );
  }

  Widget _buildLockedUpsell() {
    return Column(
      children: [
        const Text(
          "방금 확인하신 사주 원국을 바탕으로\n매일 달라지는 '하루의 기운'을 알려드립니다.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fakeTextLine(0.9), _fakeTextLine(0.6), _fakeTextLine(0.4),
                ],
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.95)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.lock_outline, color: Colors.grey[400], size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton(
            onPressed: _startSubscriptionFlow,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("월 9,600원으로 매일 받아보기", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _fakeTextLine(double ratio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      height: 10,
      width: MediaQuery.of(context).size.width * ratio,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
    );
  }

  // 구독 프로세스 시작
  void _startSubscriptionFlow() async {
    String subOrderId = "SUB_${DateTime.now().millisecondsSinceEpoch}";

    // 결제 화면으로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          orderId: subOrderId,
          orderName: '월간 운세 구독 (매일 아침)',
          amount: 9600,
        //  currency: 'KRW',
          
          // ⭐ [추가됨] 이 한 줄이 핵심입니다! 
          // isSubscribed: true
//
        ),
      ),
    );

    if (result != null && result['success'] == true) {
      String key = result['authKey'] ?? result['paymentKey'];
      await _requestSubscriptionStart(key, "user@test.com", 4900);
    }
  }

  Future<void> _requestSubscriptionStart(String authKey, String email, int amount) async {
    setState(() => isLoading = true);
    try {
      final body = {
        "AuthKey": authKey,
        "CustomerKey": email,
        "OrderId": widget.orderId,
        "Amount": amount
      };
      final res = await http.post(
        Uri.parse('${widget.serverUrl}/api/subscription/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (res.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("구독 성공! 내일의 운세가 열렸습니다. \n 매일 아침 8시에 알림이 도착해요.")));

           // ⭐ [여기 추가] 구독 성공했으니 알림 예약 시작!
         await NotificationService().scheduleDaily7AMNotification();

           _fetchSubscriptionStatus(); // 바로 새로고침
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if(mounted) setState(() => isLoading = false);
    }
  }
}
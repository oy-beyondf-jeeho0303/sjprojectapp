import 'package:flutter/material.dart';

class SubscriptionBanner extends StatefulWidget {
  final String orderId; // 현재 보고 있는 사주 주문 번호

  const SubscriptionBanner({Key? key, required this.orderId}) : super(key: key);

  @override
  _SubscriptionBannerState createState() => _SubscriptionBannerState();
}

class _SubscriptionBannerState extends State<SubscriptionBanner> {
  bool isSubscribed = false;
  Map<String, dynamic>? dailyFortune;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  // 백엔드에서 구독 상태 확인
  Future<void> _checkSubscriptionStatus() async {
    // 실제 API 호출 (가정)
    // var response = await ApiService.get('/api/subscription/status?orderId=${widget.orderId}');
    
    // [테스트용 더미 데이터]
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isSubscribed = false; // true로 바꾸면 운세 내용이 보임
      isLoading = false;
      if (isSubscribed) {
        dailyFortune = {
          "dailyContent": "### 📅 2월 8일의 운세\n오늘은 불의 기운이 강하여...",
          "targetDate": "2026-02-08"
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
        border: Border.all(color: isSubscribed ? Colors.indigoAccent : Colors.orangeAccent, width: 2),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSubscribed ? Colors.indigoAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(isSubscribed ? Icons.auto_awesome : Icons.lock, 
                     color: isSubscribed ? Colors.indigo : Colors.orange),
                SizedBox(width: 8),
                Text(
                  isSubscribed ? "내일의 맞춤 운세가 도착했어요!" : "내 사주로 보는 '내일의 운세'",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          
          // 내용 (구독 여부에 따라 갈림)
          Padding(
            padding: EdgeInsets.all(20),
            child: isSubscribed 
              ? _buildFortuneContent() 
              : _buildUpsellContent(),
          ),
        ],
      ),
    );
  }

  // 🔓 구독자에게 보여줄 화면
  Widget _buildFortuneContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dailyFortune?['dailyContent'] ?? "운세 데이터를 불러오는 중...",
          style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text("매일 아침 7시에 자동 갱신됩니다.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        )
      ],
    );
  }

  // 🔒 미구독자에게 보여줄 유도 화면 (Upsell)
  Widget _buildUpsellContent() {
    return Column(
      children: [
        Text(
          "지금 보신 사주 원국을 바탕으로\n매일 달라지는 '하루의 흐름'을 분석해드립니다.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
        SizedBox(height: 20),
        // 맛보기 블러 처리 (궁금증 유발)
        Stack(
          children: [
            Column(
              children: [
                _fakeLine(100), _fakeLine(250), _fakeLine(200),
              ],
            ),
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.6), // 뿌옇게 처리
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _startSubscriptionProcess,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text("월 9,600원으로 매일 받아보기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _fakeLine(double width) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 12,
      width: width,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
    );
  }

  void _startSubscriptionProcess() {
    // 여기서 토스 페이먼트 위젯 호출 -> 성공 시 API 호출
    print("토스 결제창 띄우기 -> 성공 시 서버 /start 호출");
  }
}
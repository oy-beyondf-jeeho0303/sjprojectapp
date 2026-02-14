import 'package:flutter/material.dart';

class SajuFooter extends StatefulWidget {
  final bool isSimple; 
  final bool isTransparent; // 인트로용 투명 배경 모드

  const SajuFooter({
    super.key, 
    this.isSimple = false, 
    this.isTransparent = false
  });

  @override
  State<SajuFooter> createState() => _SajuFooterState();
}

class _SajuFooterState extends State<SajuFooter> {
  bool _isExpanded = false; 

  // ★ [팝업 1] 개인정보 처리방침 (비회원 최적화 내용)
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("개인정보 처리방침", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("본 서비스는 별도의 회원가입 없이 운영됩니다.", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text("1. 수집 항목\n- 필수: 생년월일, 태어난 시간, 성별 (사주 분석용)\n- 결제: 결제기록, 접속 IP (토스페이먼츠 위탁)"),
              SizedBox(height: 10),
              Text("2. 이용 목적\n- 사주 명리학 운세 분석 결과 제공\n- 서비스 이용 및 결제 정산"),
              SizedBox(height: 10),
              Text("3. 보유 기간\n- 분석 정보: 분석 후 즉시 파기 (서버 비저장)\n- 결제 기록: 관련 법령에 따라 5년간 보관"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("닫기", style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }

  // ★ [팝업 2] 이용약관 팝업
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("서비스 이용약관", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            "제 1조 (목적)\n본 약관은 제이에이티소프트가 제공하는 운세 서비스 이용조건 및 절차를 규정합니다.\n\n"
            "제 2조 (서비스 성격)\n제공되는 분석 결과는 명리학적 데이터에 기반한 해석이며, 사용자의 판단에 대한 참고 자료로만 활용됩니다.\n\n"
            "제 3조 (환불 안내)\n디지털 컨텐츠 특성상 결과 조회가 완료된 이후에는 환불이 불가할 수 있습니다."
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("닫기", style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 600;

    // 투명 모드/일반 모드 색상 설정
    Color textColor = widget.isTransparent ? Colors.white70 : Colors.grey[700]!;
    Color subTextColor = widget.isTransparent ? Colors.white38 : Colors.grey[400]!;
    Color bgColor = widget.isTransparent ? Colors.transparent : const Color(0xFFF5F5F5);

    // [결과 화면용 심플 모드]
    if (widget.isSimple) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: const Color(0xFFFAFAFA),
        child: Column(
          children: [
            Text("Copyright © 2026 SJ Project.", style: TextStyle(color: Colors.grey[400], fontSize: 9)),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("사업자 정보 확인 ", style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 12, color: Colors.grey[500])
                  ],
                ),
              ),
            ),
            if (_isExpanded) _buildBusinessInfoText(alignCenter: true, color: Colors.grey[500]!),
          ],
        ),
      );
    }

    // [메인/인트로용 일반 모드]
    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 세로폭 슬림화
      child: Column(
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              _buildLink("이용약관", color: textColor, onTap: () => _showTermsDialog(context)),
              _buildDivider(color: subTextColor),
              _buildLink("개인정보처리방침", color: textColor, isBold: true, onTap: () => _showPrivacyDialog(context)),
            ],
          ),
          const SizedBox(height: 6),
          if (isDesktop)
             _buildBusinessInfoText(alignCenter: false, color: subTextColor)
          else
             _buildMobileInfo(textColor, subTextColor),
          const SizedBox(height: 8),
          Text(
            "Copyright © 2026 SJ Project. All rights reserved.",
            style: TextStyle(color: subTextColor, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoText({required bool alignCenter, required Color color}) {
    TextStyle style = TextStyle(fontSize: 9, color: color, height: 1.2);
    return Column(
      crossAxisAlignment: alignCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text("상호: 제이에이티소프트 | 대표: 문지호 | 사업자번호: 788-02-02228", style: style),
        Text("주소: 서울특별시 광진구 동일로 459 | 통신판매신고: 2026-서울광진-0000", style: style),
        Text("이메일: huyaa0303@gmail.com", style: style),
      ],
    );
  }

  Widget _buildMobileInfo(Color textColor, Color subColor) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isExpanded ? "사업자 정보 닫기" : "사업자 정보 확인", style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
              Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: textColor),
            ],
          ),
        ),
        if (_isExpanded) ...[const SizedBox(height: 4), _buildBusinessInfoText(alignCenter: true, color: subColor)],
      ],
    );
  }

  Widget _buildLink(String text, {bool isBold = false, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildDivider({required Color color}) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 8, color: color);
  }
}
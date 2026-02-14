import 'package:flutter/material.dart';

// [데이터 모델] 월별 운세 데이터 구조
class MonthlyFortuneModel {
  final int month;        // 월 (1~12)
  final String gan;       // 천간 (예: 甲)
  final String ji;        // 지지 (예: 子)
  final String content;   // 운세 상세 내용

  MonthlyFortuneModel({
    required this.month, 
    required this.gan, 
    required this.ji, 
    required this.content
  });
}

class MonthlyFortuneDisplay extends StatefulWidget {
  final List<MonthlyFortuneModel> monthlyData;
  final String targetLanguage;

  const MonthlyFortuneDisplay({
    super.key,
    required this.monthlyData,
    this.targetLanguage = 'ko',
  });

  @override
  State<MonthlyFortuneDisplay> createState() => _MonthlyFortuneDisplayState();
}

class _MonthlyFortuneDisplayState extends State<MonthlyFortuneDisplay> {
  int _selectedIndex = 0;

  // 한글 발음 변환 함수
  String _getHangul(String hanja) {
    const map = {
      '甲': '갑', '乙': '을', '丙': '병', '丁': '정', '戊': '무', '己': '기', '庚': '경', '辛': '신', '壬': '임', '癸': '계',
      '子': '자', '丑': '축', '寅': '인', '卯': '묘', '辰': '진', '巳': '사', '午': '오', '未': '미', '申': '신', '酉': '유', '戌': '술', '亥': '해'
    };
    return map[hanja] ?? '';
  }

  // 오행 색상 변환 함수
  Color _getFiveElementColor(String hanja) {
    if (['甲', '乙', '寅', '卯'].contains(hanja)) return const Color(0xFF4CAF50); // 목
    if (['丙', '丁', '巳', '午'].contains(hanja)) return const Color(0xFFF44336); // 화
    if (['戊', '己', '辰', '戌', '丑', '未'].contains(hanja)) return const Color(0xFFFFC107); // 토
    if (['庚', '辛', '申', '酉'].contains(hanja)) return const Color(0xFF9E9E9E); // 금
    if (['壬', '癸', '亥', '子'].contains(hanja)) return const Color(0xFF2196F3); // 수
    return Colors.black87;
  }

  // ★ [다국어 패치 1] 월(Month) 텍스트 자동 변환
  String _getMonthText(int month, String lang) {
    if (lang == 'en') {
      const enMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return enMonths[month - 1]; // 영어는 Jan, Feb 등으로 짧게 표시
    } else if (lang == 'ja') {
      return "$month月"; // 일본어
    } else {
      return "$month월"; // 한국어 (기본)
    }
  }

  // ★ [다국어 패치 2] "상세 풀이" 텍스트 자동 변환
  String _getDetailTitleText(String lang) {
    if (lang == 'en') return "Details";
    if (lang == 'ja') return "詳細";
    return "상세 풀이";
  }

  // ★ [다국어 패치 3] "월별 상세 흐름" 타이틀 텍스트 자동 변환
  String _getMainTitleText(String lang, int year) {
    if (lang == 'en') return "$year Monthly Flow";
    if (lang == 'ja') return "$year年 月別の詳細";
    return "$year년 월별 상세 흐름";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monthlyData.isEmpty) return const SizedBox.shrink();

    final currentData = widget.monthlyData[_selectedIndex];
    final int currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. [헤더] 타이틀
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            _getMainTitleText(widget.targetLanguage, currentYear), // 다국어 적용
            style: const TextStyle(
                fontSize: 21.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111)),
          ),
        ),

        // 2. [가로 스크롤] 12개월 기둥 리스트
        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.monthlyData.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = widget.monthlyData[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 62,
                  margin: const EdgeInsets.only(bottom: 8, top: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[200] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2D3436)
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 천간 (한자 옆에 작은 한글 배치)
                      _buildHanjaRow(item.gan),
                      
                      const SizedBox(height: 8), 

                      // 지지 (한자 옆에 작은 한글 배치)
                      _buildHanjaRow(item.ji),

                      const SizedBox(height: 12), 

                      // 월 표시 배지 (다국어 적용)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getMonthText(item.month, widget.targetLanguage), // ★ 다국어 월 함수 호출
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 3. [상세 내용] 운세 텍스트 카드
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      // 상세 풀이 제목 다국어 분기
                      widget.targetLanguage == 'ko'
                          ? "${_getMonthText(currentData.month, 'ko')} (${currentData.gan}(${_getHangul(currentData.gan)})${currentData.ji}(${_getHangul(currentData.ji)}))"
                          : "${_getMonthText(currentData.month, widget.targetLanguage)} (${currentData.gan}${currentData.ji})",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getDetailTitleText(widget.targetLanguage), // ★ 다국어 상세 풀이 함수 호출
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                currentData.content,
                style: const TextStyle(
                  fontSize: 18, // ★ 모바일 가독성 향상 (17 -> 18.5)
                  height: 1.7,
                  color: Color(0xFF333333),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 한자와 한글을 가로로 배치하는 헬퍼 위젯
  Widget _buildHanjaRow(String hanja) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        Text(
          hanja,
          style: TextStyle(
            fontSize: 23.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Serif",
            color: _getFiveElementColor(hanja),
            height: 1.0,
          ),
        ),
        if (widget.targetLanguage == 'ko') ...[
          const SizedBox(width: 2), 
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0), 
            child: Text(
              _getHangul(hanja),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500], 
                height: 1.0,
              ),
            ),
          ),
        ]
      ],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import '../home_screen.dart'; // 경로는 션 님의 프로젝트 구조에 맞게 확인해주세요.

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ★ [다국어 처리] 현재 언어 상태
  String _currentLang = 'en';

  // ★ [데이터] 
  final Map<String, List<Map<String, dynamic>>> _introDataMap = {
    'ko': [
      {
        "title": "나만 뒤쳐진 건 아닐까? \n남들은 다 잘나가는 것 같은데\n어찌해야 하지?",
        "desc": "당신이 태어난 날과 시간 속에 숨겨진\n고유한 기질과 잠재력을 통해 \n진정한 나만의 힘과 강점을 찾아보세요.",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "어떻게 살아야 하는가?\n무엇을 도모하여 내 운세와 기를 \n극대화 할 것인가?",
        "desc": "엔지니어 출신의 20년 경력 \n사주 운세 전문가가 직접 개발하고\n참여한 믿을 수 있는 사주 분석",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "그것이 대체 무엇인가? \n나의 타고난 운명은?\n내 인생의 길흉화복은?",
        "desc": "수천 년의 동양 철학 데이터를\n최첨단 AI와 20년의 전문가가 \n정밀하게 분석합니다.",
        "icon": Icons.auto_graph_outlined,
      },
      {
        "title": "다가올 시간, 불안정한 시대에 \n올라갈 수 있는 힘을 얻자",
        "desc": "재물운, 연애운, 그리고 대운의 흐름 \n올해의 운세까지.\n다가올 미래를 미리 준비하세요.",
        "icon": Icons.trending_up,
      },
    ],
    'en': [
      {
        "title": "Feeling left behind? \nEveryone else seems to be succeeding.\nWhat should I do?",
        "desc": "Discover your true power and hidden potential\nthrough the unique energy embedded in\nyour date and time of birth.",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "How should I navigate my life?\nHow can I maximize my fortune\nand energy?",
        "desc": "Reliable analysis developed by a\nformer engineer and Saju expert\nwith 20 years of experience.",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "What is my destiny?\nThe highs and lows of my life?\nIs it predetermined?",
        "desc": "Thousands of years of Eastern philosophy data,\nprecisely analyzed by cutting-edge AI\nand expert insight.",
        "icon": Icons.auto_graph_outlined,
      },
      {
        "title": "Gain the strength to rise\nabove uncertainty and prepare\nfor what's coming.",
        "desc": "Wealth, Love, and your Life Cycle.\nFrom daily flows to yearly fortunes.\nPrepare for your future today.",
        "icon": Icons.trending_up,
      },
    ],
    'ja': [
      {
        "title": "周りと比べて焦っていませんか？\n自分だけ取り残されているような\n不安を感じていませんか?",
        "desc": "生年月日に隠されたあなただけの\n気質と潜在能力を知り、\n本来の強みを見つけ出しましょう。",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "人生をどう歩むべきか？\n自分の運気を最大限に高めるには\nどうすればいいのか?",
        "desc": "エンジニア出身、鑑定歴20年の\n四柱推命専門家が開発に直接参加。\n論理的で信頼できる運勢分析。",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "私の宿命とは何か？\n人生の吉凶禍福(きっきょうかふく)は\nどこにあるのか?",
        "desc": "数千年の東洋哲学データと\n最先端AI、そして専門家の知見で\nあなたの運命を精密に分析します。",
        "icon": Icons.auto_graph_outlined,
      },
      {
        "title": "不確実な時代に備え、\n人生を切り拓く力を手に入れよう",
        "desc": "金運、恋愛運、そして大運の流れ。\n今年の運勢から未来の備えまで。\n来るべき時に備えましょう。",
        "icon": Icons.trending_up,
      },
    ],
  };

  final Map<String, String> _buttonTextMap = {
    'ko': '나의 운명 흐름 확인하기',
    'en': 'Discover My True Destiny',
    'ja': '自分の運命を読み解く',
  };

  // ★ [핵심] 앱이 켜질 때 폰의 언어를 감지하는 함수
  @override
  void initState() {
    super.initState();
    try {
      // 폰의 시스템 언어 가져오기 (예: 'ko_KR', 'en_US', 'ja_JP')
      String systemLang = Platform.localeName.split('_')[0]; 
      
      // 우리가 지원하는 언어(ko, en, ja)에 포함되면 그 언어로 설정
      if (_introDataMap.containsKey(systemLang)) {
        _currentLang = systemLang;
      } else {
        // 지원하지 않는 언어(예: 프랑스어)면 기본값 영어(en)로 설정
        _currentLang = 'en';
      }
    } catch (e) {
      // 혹시라도 에러 나면 영어로 안전하게
      _currentLang = 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIntroData = _introDataMap[_currentLang]!;
    final currentButtonText = _buttonTextMap[_currentLang]!;

    return Scaffold(
      body: Stack(
        children: [
          // 1. 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/intro_bg.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. 메인 레이아웃 (SafeArea로 감싸서 상단바 침범 방지)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // [중앙] 슬라이더 (남은 공간 모두 차지 = Expanded)
                // Spacer 제거하고 Expanded 하나만 써서 공간 확보
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _currentPage = value),
                    itemCount: currentIntroData.length,
                    itemBuilder: (context, index) => _buildIntroContent(
                      currentIntroData[index]['title'],
                      currentIntroData[index]['desc'],
                      currentIntroData[index]['icon'],
                    ),
                  ),
                ),

                // [하단] 인디케이터(점) + 버튼 영역
                // 화면 아래쪽에 고정되도록 Column의 맨 아래에 배치
                Column(
                  mainAxisSize: MainAxisSize.min, // 내용물만큼만 공간 차지
                  children: [
                    // 슬라이드 점 (버튼 바로 위에 위치)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          currentIntroData.length,
                          (index) => _buildDot(index),
                        ),
                      ),
                    ),

                    // 하단 버튼 (마지막 페이지에서만 등장)
                    Container(
                      width: double.infinity,
                      height: 56, // 버튼 높이 고정
                      // ★ [수정] 두 개였던 margin을 하나로 합쳤습니다! (좌우 24, 아래 30)
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30), 
                      
                      child: _currentPage == currentIntroData.length - 1
                          ? ElevatedButton(
                              onPressed: _goToHome,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE94560),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)
                                ),
                                elevation: 10,
                              ),
                              child: Text(
                                currentButtonText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox(), 
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen 존재 확인
    );
  }

  // ★ [핵심] 내용이 길어지면 스크롤 되게 하여 '오버플로우' 원천 차단
  Widget _buildIntroContent(String title, String desc, IconData icon) {
    return Center( // 화면 중앙 정렬
      child: SingleChildScrollView( // 안전장치: 화면이 작으면 스크롤 됨
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Icon(icon, size: 60, color: const Color(0xFFFFD700)),
              ),
              const SizedBox(height: 30),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                  shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0))],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ★ [수정] 황금색 점
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFFFD700) : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
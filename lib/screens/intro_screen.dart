import 'package:flutter/material.dart';
import '../home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ★ [다국어 처리] 현재 언어 상태 (테스트용 기본값: 'ko')
  String _currentLang = 'ko';

  // ★ [다국어 처리] 소개 데이터 (한국어, 영어, 일본어)
  final Map<String, List<Map<String, dynamic>>> _introDataMap = {
    'ko': [
      {
        "title": "나만 뒤쳐진 것 같아? \n 남들은 다 잘나가는 것 같은데",
        "desc": "당신이 태어난 날과 시간 속에 숨겨진\n고유한 기질과 잠재력을 통해 \n진정한 나만의 힘과 강점을 찾아보세요.",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "엔지니어 출신의 20년 경력 \n운세 전문가가 직접 개발한 분석",
        "desc": "수천년 동양 철학 데이터를\n최첨단 AI와 20년 전문가가 \n정밀하게 분석합니다.",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "완벽한 미래 \n올라갈 수 있는 힘",
        "desc": "재물운, 연애운, 그리고 대운의 흐름 \n올해의 운세까지.\n다가올 미래를 미리 준비하세요.",
        "icon": Icons.auto_graph_outlined,
      },
    ],
    'en': [
      {
        "title": "Feel like you're falling behind? \n Everyone else seems to be succeeding.",
        "desc": "Discover your unique temperament and potential hidden in your birth date and time. \n Find your true strength and advantages.",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "Developed by an Engineer turned \n Fortune Expert with 20 Years Experience",
        "desc": "Thousands of years of \n Eastern philosophy data precisely analyzed by \n cutting-edge AI and experts.",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "Perfect Future \n The Power to Rise",
        "desc": "From wealth and love luck to \n major life flows and this year's fortune. \n Prepare for your upcoming future.",
        "icon": Icons.auto_graph_outlined,
      },
    ],
    'ja': [
      {
        "title": "自分だけ取り残されている気がする？ \n 他の人はみんなうまくいっているのに。",
        "desc": "あなたが生まれた日と時間の中に隠された固有の気質と潜在能力を通じて、\n真の自分の力と強みを見つけてください。",
        "icon": Icons.compass_calibration_outlined,
      },
      {
        "title": "エンジニア出身の20年の経歴を持つ \n 運勢専門家が直接開発した分析",
        "desc": "数千年の東洋哲学データを最先端AIと20年の専門家が精密に分析します。",
        "icon": Icons.psychology_alt,
      },
      {
        "title": "完璧な未来 \n 上がっていく力",
        "desc": "財運、恋愛運、そして大運の流れに、\n今年の運勢まで。\nやってくる未来をあらかじめ準備してください。",
        "icon": Icons.auto_graph_outlined,
      },
    ],
  };

  // ★ [다국어 처리] 하단 버튼 텍스트
  final Map<String, String> _buttonTextMap = {
    'ko': '내 운명 확인하기',
    'en': 'Check My Destiny',
    'ja': '私の運命を確認する',
  };

  @override
  Widget build(BuildContext context) {
    // 현재 언어에 맞는 데이터 가져오기
    final currentIntroData = _introDataMap[_currentLang]!;
    final currentButtonText = _buttonTextMap[_currentLang]!;

    return Scaffold(
      body: Stack(
        children: [
          // 1층: 배경 이미지 (기존 유지)
          Positioned.fill(
            child: Image.asset(
              'assets/images/intro_bg.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2층: 콘텐츠
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // [1] 상단 영역 (언어 변경 버튼 + SKIP 버튼)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ★ [테스트용] 언어 변경 드롭다운 버튼
                        DropdownButton<String>(
                          value: _currentLang,
                          dropdownColor: Colors.black87, // 드롭다운 배경색
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          underline: Container(), // 밑줄 제거
                          icon: const Icon(Icons.language, color: Colors.white70),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentLang = newValue!;
                            });
                          },
                          items: ['ko', 'en', 'ja'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            );
                          }).toList(),
                        ),
                        // SKIP 버튼
                        TextButton(
                          onPressed: _goToHome,
                          child: const Text("SKIP", style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // [2] 중앙 슬라이더 PageView (다국어 데이터 연결)
                  Expanded(
                    flex: 5,
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

                  // [3] 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      currentIntroData.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const Spacer(flex: 1),

                  // [4] 하단 CTA 버튼 (다국어 텍스트 연결)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _goToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: const Color(0xFFE94560).withOpacity(0.5),
                        ),
                        child: Text(
                          currentButtonText, // ★ 언어별 텍스트 표시
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
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // 슬라이드 내용 위젯 (기존 유지)
  Widget _buildIntroContent(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, size: 80, color: const Color(0xFFFFD700)),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24, // 폰트 사이즈 약간 조정 (긴 텍스트 대응)
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
    );
  }

  // 인디케이터 점 위젯 (기존 유지)
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFE94560) : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
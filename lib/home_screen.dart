import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sj_project_app/services/purchase_service.dart';
import 'package:sj_project_app/utils/localization_data.dart'; // ★ 추가

// ★ 파일 import 확인
import 'city_data.dart';
import 'five_elements.dart';
import 'dart:ui' as ui; // 언어 감지용

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = "https://10.0.2.2:7033/api/Orders";

  DateTime _selectedDate = DateTime(1981, 3, 3);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 13, minute: 30);
  String _gender = "M";
  bool _isLunar = false;

  // 기본값은 한국어
  String _targetLanguage = "ko";

  @override
  void initState() {
    super.initState();
    _detectLanguage();
  }

  void _detectLanguage() {
    // 기기 설정 언어 가져오기 (예: ko_KR, en_US)
    Locale deviceLocale = ui.window.locale;

    // 한국어가 아니면 무조건 영어로 설정
    if (deviceLocale.languageCode != 'ko') {
      setState(() {
        _targetLanguage = 'en';
      });
      print("🌍 외국어 사용자 감지: English Mode Activated");
    } else {
      print("🇰🇷 한국어 사용자 감지");
    }
  }

  // 기본 도시
  City _selectedCity = globalCities[0];

  bool _isLoading = false;
  Map<String, dynamic>? _sajuDetail;
  String? _fortuneReport;

  Future<void> _fetchSajuData() async {
    setState(() {
      _isLoading = true;
      _sajuDetail = null;
      _fortuneReport = null;
    });

    try {
      final String birthDate = DateFormat(
        "yyyy-MM-dd'T'00:00:00",
      ).format(_selectedDate);
      final String birthTime =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      final bodyData = {
        "email": "user@test.com",
        "targetLanguage": "ko",
        "birthDate": birthDate,
        "birthTime": birthTime,
        "isLunar": false,
        "gender": _gender,
        "birthCountry": _selectedCity.country,
        "birthCity": _selectedCity.name,
        "latitude": _selectedCity.lat,
        "longitude": _selectedCity.lng,
        "timezone": _selectedCity.timezone,
        "targetLanguage": _targetLanguage
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _sajuDetail = data['sajuDetail'];
          _fortuneReport = data['fortuneReport'];
        });

        // 1. 저장을 위한 키(Key) 다시 생성
        // (_onAnalyzePressed에서 만들었던 것과 똑같은 재료로 만들어야 합니다)
        String formattedTime =
            "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

        final purchaseService = PurchaseService();
        String profileKey = purchaseService.generateProfileKey(
          _selectedDate,
          formattedTime, // Formatted String 시간
          _gender,
          _isLunar,
        );

        // 데이터 저장 (이제 다음번엔 서버 안 부름)
        await purchaseService.savePurchase(profileKey, data);
      } else {
        _showError("서버 오류: ${response.statusCode}");
      }
    } catch (e) {
      _showError("서버 연결 실패.\n$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  // ★★★ 여기가 에러 잡는 핵심 부분입니다 ★★★
  void _openCitySearch() async {
    // 1. showSearch 뒤에 <City?>를 붙여서 "이 검색창은 City나 null을 뱉는다"고 알려줍니다.
    final City? result = await showSearch<City?>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    // 2. 결과가 null이 아닐 때만 업데이트
    if (result != null) {
      setState(() => _selectedCity = result);
    }
  }

  String _getHangul(String? hanja) {
    const Map<String, String> map = {
      '甲': '갑',
      '乙': '을',
      '丙': '병',
      '丁': '정',
      '戊': '무',
      '己': '기',
      '庚': '경',
      '辛': '신',
      '壬': '임',
      '癸': '계',
      '子': '자',
      '丑': '축',
      '寅': '인',
      '卯': '묘',
      '辰': '진',
      '巳': '사',
      '午': '오',
      '未': '미',
      '申': '신',
      '酉': '유',
      '戌': '술',
      '亥': '해',
    };
    return map[hanja] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "SJ Project",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3436),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader('header_input'), // "사주 정보 입력"
            _buildInputCard(),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.black87),
              )
            else if (_sajuDetail != null) ...[
              _buildHeader('header_manse'),
              _buildManseGrid(),
              const SizedBox(height: 30),
              _buildDaewoonList(),
              const SizedBox(height: 20),
              _buildSeunList(),
              const SizedBox(height: 30),
              _buildHeader('header_analysis'), // "오행 분석"
              _buildAnalysisCard(),
              const SizedBox(height: 30),
              _buildHeader('header_yongsin'), // "용신"
              _buildYongsinCard(),
              const SizedBox(height: 30),
              _buildHeader('header_diagram'), // "관계도"
              FiveElementsDiagram(
                elementRun: _sajuDetail!['elementRun'],
                dayMasterElement: _sajuDetail!['dayMasterElement'],
                // ★ 이 줄만 추가하면 됩니다!
                targetLanguage: _targetLanguage,
              ),
              const SizedBox(height: 30),
              _buildHeader('header_report'), // "리포트"
              _buildReportCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String key, {Map<String, String>? params}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        // ★ 키를 받아서 언어에 맞는 텍스트로 변환
        AppLocale.get(_targetLanguage, key, params: params),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPicker(
                  "생년월일",
                  DateFormat("yyyy.MM.dd").format(_selectedDate),
                  Icons.calendar_today_outlined,
                  () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _selectedDate = d);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildPicker(
                  "태어난 시",
                  _selectedTime.format(context),
                  Icons.access_time,
                  () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (t != null) setState(() => _selectedTime = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: _openCitySearch,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "태어난 도시 (위도/경도 보정)",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_selectedCity.country}, ${_selectedCity.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.search, color: Colors.blueGrey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGenderBtn("남성", "M"),
              const SizedBox(width: 10),
              _buildGenderBtn("여성", "F"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onAnalyzePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3436),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "운세 분석 시작",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================

  Widget _buildPicker(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderBtn(String label, String val) {
    bool isSelected = _gender == val;
    return GestureDetector(
      onTap: () => setState(() => _gender = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // [1. 전체 틀 수정] 좌측 라벨 컬럼 추가
  Widget _buildManseGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // IntrinsicHeight: 자식들의 높이를 가장 높은 놈(내용물)에 맞춤
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ★★★ [신규] 좌측 라벨 (천간, 지지 등 이름표) ★★★
            _buildTableLabelColumn(),

            // 우측 데이터 (시, 일, 월, 연)
            _buildTablePillar(AppLocale.get(_targetLanguage, "label_siju"),
                _sajuDetail!['time'],
                isLast: false),
            _buildTablePillar(
              AppLocale.get(_targetLanguage, "label_ilju"),
              _sajuDetail!['day'],
              isMe: true,
              isLast: false,
            ),
            _buildTablePillar(AppLocale.get(_targetLanguage, "label_wolju"),
                _sajuDetail!['month'],
                isLast: false),
            _buildTablePillar(AppLocale.get(_targetLanguage, "label_yeonju"),
                _sajuDetail!['year'],
                isLast: true),
          ],
        ),
      ),
    );
  }

  // [신규] 대운 흐름 리스트 (가로 스크롤)
  Widget _buildDaewoonList() {
    if (_sajuDetail == null || _sajuDetail!['daewoonList'] == null)
      return const SizedBox();

    List<dynamic> daewoonList = _sajuDetail!['daewoonList'];
    int daewoonNum = _sajuDetail!['daewoonNum'] ?? 4; // 기본값

    // 현재 내 나이 계산 (만 나이 대략 계산)
    int currentYear = DateTime.now().year;
    int birthYear = _selectedDate.year;
    int myAge = currentYear - birthYear + 1; // 한국식 세는 나이 기준 (대운은 보통 세는 나이 표기)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocale.get(_targetLanguage, 'header_daewoon',
                params: {'num': '$daewoonNum'}),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(), // 부드러운 스크롤
          child: Row(
            children: daewoonList.map((dw) {
              int age = dw['age'];
              // 현재 대운인지 확인 (내 나이가 대운 범위 안에 있는지)
              bool isCurrent = myAge >= age && myAge < (age + 10);

              return Container(
                width: 50,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF2D3436)
                      : Colors.white, // 현재 대운은 검은색 배경
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF2D3436)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    // 간지 (한자)
                    Text(
                      dw['gan']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        color: isCurrent
                            ? Colors.white
                            : _parseColor(dw['gan']['color']),
                      ),
                    ),
                    Text(
                      dw['ji']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        color: isCurrent
                            ? Colors.white
                            : _parseColor(dw['ji']['color']),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 나이 (숫자)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$age",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // [신규] 세운(연운) 리스트
  Widget _buildSeunList() {
    if (_sajuDetail == null || _sajuDetail!['seunList'] == null)
      return const SizedBox();

    List<dynamic> seunList = _sajuDetail!['seunList'];
    int currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocale.get(_targetLanguage, 'header_seun'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: seunList.map((seun) {
              int year = seun['year'];
              bool isCurrent = (year == currentYear);

              return Container(
                width: 50, // ★ 60 -> 50으로 줄임 (더 슬림하게!)
                margin: const EdgeInsets.only(right: 6), // 간격도 8->6으로 살짝 줄임
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFF3F51B5) : Colors.white,
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // 모서리도 살짝 덜 둥글게 (비율 맞춤)
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF3F51B5)
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Text(
                      seun['gan']['hanja'],
                      style: TextStyle(
                        fontSize: 20, // 폭이 좁아지니 글자도 22->20으로 살짝 조정
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        color: isCurrent
                            ? Colors.white
                            : _parseColor(seun['gan']['color']),
                        height: 1.0,
                      ),
                    ),
                    Text(
                      seun['ji']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        color: isCurrent
                            ? Colors.white
                            : _parseColor(seun['ji']['color']),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ), // 내부 여백 최소화
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$year",
                        style: TextStyle(
                          fontSize: 10, // 연도 글자 크기 11->10 (폭에 맞춤)
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // [3. 우측 데이터 기둥 수정]
  Widget _buildTablePillar(
    String label,
    Map<String, dynamic> data, {
    bool isMe = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Container(
        // ❌ [삭제] 여기에 color를 두면 decoration과 충돌합니다!
        // color: isMe ? const Color(0xFFFFFDE7) : Colors.transparent,

        // ✅ [수정] decoration 안으로 color를 옮깁니다.
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFFFFDE7)
              : Colors.transparent, // ★ 여기로 이사 옴!
          border: isLast
              ? null
              : Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
        ),
        child: Column(
          children: [
            // 1. 헤더
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // 2. 천간 데이터
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: Center(
                child: _buildGridChar(
                  data['gan']['hanja'],
                  data['gan']['color'],
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 20,
              child: Center(
                child: _buildGridShipseong(data['gan']['shipseong']),
              ),
            ),
            const SizedBox(height: 12),

            const Divider(height: 1, thickness: 1, color: Color(0xFFBDBDBD)),

            // 3. 지지 데이터
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: Center(
                child: _buildGridChar(data['ji']['hanja'], data['ji']['color']),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 20,
              child: Center(
                child: _buildGridShipseong(data['ji']['shipseong']),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // [수정 3] 글자 위젯 (큰 한자 + 작은 한글)
  Widget _buildGridChar(String? hanja, String? colorHex) {
    Color color = _parseColor(colorHex);
    String hangul = _getHangul(hanja);

    return Column(
      children: [
        Text(
          hanja ?? "",
          style: TextStyle(
            fontSize: 32, // 글자 크기 확대
            fontWeight: FontWeight.bold,
            fontFamily: "Serif", // 명조체 느낌
            color: color,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hangul,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // [2. 좌측 라벨 기둥 구현] 우측 데이터와 높이/간격을 100% 동기화
  Widget _buildTableLabelColumn() {
    return Container(
      width: 40, // 라벨 칸 너비
      decoration: BoxDecoration(
        color: Colors.grey[50], // 아주 연한 회색 배경 (구분감)
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 1. 헤더 높이 맞춤 (내용 없음)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "",
              style: TextStyle(fontSize: 13, height: 1.0),
            ), // 높이 점유용
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

          // ================= 천간 라벨 =================
          const SizedBox(height: 12), // 우측과 동일한 여백
          // 큰 글자(한자) 위치에 '천간' 배치
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                AppLocale.get(_targetLanguage, 'label_gan'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 십성 위치에 '십성' 배치
          Container(
            height: 20, // 우측 십성 텍스트 대략적 높이
            alignment: Alignment.center,
            child: Text(
              AppLocale.get(_targetLanguage, 'label_shipseong'),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 12),

          // 구분선
          const Divider(height: 1, thickness: 1, color: Color(0xFFBDBDBD)),

          // ================= 지지 라벨 =================
          const SizedBox(height: 12),
          // 큰 글자(한자) 위치에 '지지' 배치
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                AppLocale.get(_targetLanguage, 'label_ji'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 십성 위치에 '십성' 배치
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              AppLocale.get(_targetLanguage, 'label_shipseong'),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // [수정 4] 십성 위젯 (깔끔한 텍스트)
  Widget _buildGridShipseong(String? text) {
    if (text == null || text.isEmpty) return const SizedBox();
    // 2. ★ [핵심] 번역 적용 (한글 '편관' -> 영어 'Power')
    String translatedText = AppLocale.get(_targetLanguage, text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        translatedText,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLeftLabelColumn() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 12),
          _buildLabelText("천간"),
          const SizedBox(height: 6),
          _buildLabelText("십성", isSmall: true),
          const SizedBox(height: 14),
          _buildLabelText("지지"),
          const SizedBox(height: 6),
          _buildLabelText("십성", isSmall: true),
        ],
      ),
    );
  }

  Widget _buildLabelText(String text, {bool isSmall = false}) {
    return Container(
      height: isSmall ? 24 : 52,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmall ? 11 : 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildPillar(
    String label,
    Map<String, dynamic> data, {
    bool isMe = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCharBox(data['gan'], isMe),
        const SizedBox(height: 6),
        SizedBox(
          height: 24,
          child: _buildShipseongTag(data['gan']['shipseong']),
        ),
        const SizedBox(height: 14),
        _buildCharBox(data['ji'], false),
        const SizedBox(height: 6),
        SizedBox(
          height: 24,
          child: _buildShipseongTag(data['ji']['shipseong']),
        ),
      ],
    );
  }

  Widget _buildCharBox(Map<String, dynamic> charData, bool isMe) {
    Color elementColor = _parseColor(charData['color']);
    String hanja = charData['hanja'] ?? "";
    String hangul = _getHangul(hanja);
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFFFF9C4) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isMe ? const Color(0xFFFFD54F) : elementColor,
          width: isMe ? 2 : 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            hanja,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: "Serif",
              color: Colors.black87,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              hangul,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipseongTag(String? text) {
    if (text == null || text.isEmpty) return const SizedBox();

    // ★ [수정] 변수 선언이 빠져 있었습니다! 여기서 선언합니다.
    String translatedText = AppLocale.get(_targetLanguage, text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        translatedText,
        style: TextStyle(
          fontSize: _targetLanguage == 'en' ? 9 : 10,
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    if (_sajuDetail == null) return const SizedBox();
    Map<String, dynamic> run = _sajuDetail!['elementRun'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 25,
                sections: [
                  _makeSection(run['목'], const Color(0xFF4CAF50)),
                  _makeSection(run['화'], const Color(0xFFF44336)),
                  _makeSection(run['토'], const Color(0xFFFFC107)),
                  _makeSection(run['금'], const Color(0xFF9E9E9E)),
                  _makeSection(run['수'], const Color(0xFF2196F3)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'wood'),
                    run['목'], const Color(0xFF4CAF50)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'fire'),
                    run['화'], const Color(0xFFF44336)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'Earth'),
                    run['토'], const Color(0xFFFFC107)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'Metal'),
                    run['금'], const Color(0xFF9E9E9E)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'Water'),
                    run['수'], const Color(0xFF2196F3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _makeSection(dynamic value, Color color) {
    double val = (value is int) ? value.toDouble() : (value as double);
    return PieChartSectionData(
      color: color,
      value: val,
      radius: 20,
      showTitle: false,
    );
  }

  Widget _buildAnalysisRow(String label, dynamic value, Color color) {
    double val = (value is int) ? value.toDouble() : (value as double);
    //  String status = val > 35 ? "과다" : (val < 10 ? "부족" : "적정");

    // 1. 상태(과다/부족) 다국어 처리
    String statusKey = val > 35
        ? 'status_excess'
        : (val < 10 ? 'status_lack' : 'status_proper');
    String statusText = AppLocale.get(_targetLanguage, statusKey);

    // 2. 오행 라벨(목, 화...) 다국어 처리
    // label이 "목(Tree)" 처럼 들어올 수 있으므로, 핵심 단어만 뽑아서 키로 변환
    String elemKey = _getElemKey(label);
    String elemText = AppLocale.get(_targetLanguage, elemKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
          Text(
            "${val.toInt()}% ($statusText)", // 50% (Excess)
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusKey == 'status_proper' ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }

  // [수정] 용신 카드 (다국어 완벽 적용)
  Widget _buildYongsinCard() {
    if (_sajuDetail == null) return const SizedBox();

    // 서버에서 받은 원본 데이터 (예: "수", "금")
    String yongsin = _sajuDetail!['yongsin'] ?? "알 수 없음";
    String dayMasterElem = _sajuDetail!['dayMasterElement'] ?? "";

    // ★ [핵심] 한글 오행 -> 영어 키(wood, fire...)로 변환 -> 다국어 텍스트 가져오기
    String yongsinKey = _getElemKey(yongsin);
    String dayMasterKey = _getElemKey(dayMasterElem);

    String yongsinTrans = AppLocale.get(_targetLanguage, yongsinKey);
    String dayMasterElemTrans = AppLocale.get(_targetLanguage, dayMasterKey);

    Color yColor = _getElementColor(yongsin);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
        border: Border.all(color: yColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // 왼쪽 원형 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: yColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              yongsinTrans, // 번역된 텍스트 (Water / 수)
              style: TextStyle(
                // 영문일 경우 글자가 길어서 폰트 조정
                fontSize: _targetLanguage == 'en' ? 14 : 32,
                fontWeight: FontWeight.bold,
                color: yColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 오른쪽 설명 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "To support your Day Master (Metal),"
                Text(
                  AppLocale.get(_targetLanguage, 'yongsin_desc_1',
                      params: {'elem': dayMasterElemTrans}),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      yongsinTrans,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: yColor,
                      ),
                    ),
                    // " energy is needed."
                    Text(
                      AppLocale.get(_targetLanguage, 'yongsin_desc_2'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // "Using this element balances your life."
                Text(
                  AppLocale.get(_targetLanguage, 'yongsin_sub'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ★★★ [신규 추가] 오행 한글 이름을 키값(wood, fire)으로 바꾸는 함수
  // 이 함수가 없으면 _buildYongsinCard에서 에러가 납니다!
  String _getElemKey(String korName) {
    if (korName.contains('목')) return 'wood';
    if (korName.contains('화')) return 'fire';
    if (korName.contains('토')) return 'earth';
    if (korName.contains('금')) return 'metal';
    if (korName.contains('수')) return 'water';
    return 'unknown';
  }

  // [수정] 운세 리포트 카드 (매거진 스타일 UI)
  Widget _buildReportCard() {
    if (_fortuneReport == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // 내부 여백 넉넉하게
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 둥근 모서리
        border: Border.all(color: Colors.grey.shade200), // 연한 테두리
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 리포트 헤더 (아이콘 + 제목)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD), // 연한 파란색 배경
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "상세 운세 분석",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),

          // 2. HTML 본문 렌더링 (스타일링 적용)
          HtmlWidget(
            _fortuneReport ?? "",
            textStyle: const TextStyle(
              fontSize: 15,
              height: 1.8, // 줄 간격을 넓혀서 읽기 편하게 (1.8배)
              color: Color(0xFF424242), // 너무 까만색보다 진한 회색이 눈이 편함
              letterSpacing: -0.2, // 자간을 살짝 좁혀서 단단한 느낌
            ),
            customStylesBuilder: (element) {
              // HTML 태그별 커스텀 스타일
              if (element.localName == 'h3') {
                return {
                  'font-size': '18px',
                  'font-weight': 'bold',
                  'color': '#1565C0', // 제목은 파란색 계열로 강조
                  'margin-top': '24px',
                  'margin-bottom': '12px',
                  'border-bottom': '2px solid #E3F2FD', // 제목 아래 밑줄 장식
                  'padding-bottom': '4px',
                  'display': 'inline-block', // 밑줄 길이를 글자에 맞춤
                };
              }
              if (element.localName == 'b' || element.localName == 'strong') {
                return {'color': '#212121', 'font-weight': '700'}; // 강조 텍스트 진하게
              }
              if (element.localName == 'li') {
                return {'margin-bottom': '8px'}; // 리스트 항목 간격
              }
              return null;
            },
          ),

          // 3. 하단 안내 문구 (선택 사항)
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "이 운세는 사주 명리학 이론을 바탕으로 분석한 결과입니다.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.black;
    try {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } catch (e) {
      return Colors.black;
    }
  }

  Color _getElementColor(String element) {
    switch (element) {
      case "목":
        return const Color(0xFF4CAF50);
      case "화":
        return const Color(0xFFF44336);
      case "토":
        return const Color(0xFFFFC107);
      case "금":
        return const Color(0xFF9E9E9E);
      case "수":
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // ★★★ [수정됨] 결제 체크 및 분석 시작 로직 ★★★
  // ============================================================
  void _onAnalyzePressed() async {
    // 1. 시간 포맷팅 (TimeOfDay -> String 변환)
    // 컨트롤러 대신 _selectedTime 변수를 사용합니다.
    String formattedTime =
        "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    // (유효성 검사: TimeOfDay는 기본값이 있으므로 null 체크 불필요)

    // 2. 사주 고유 키 생성
    final purchaseService = PurchaseService();
    String profileKey = purchaseService.generateProfileKey(
      _selectedDate,
      formattedTime, // ★ _birthTimeController.text 대신 이거 사용!
      _gender,
      _isLunar,
    );

    // 3. 구매 여부 확인
    bool isPaid = await purchaseService.isPurchased(profileKey);

    if (isPaid) {
      print("🎉 이미 결제된 사주입니다.");

      // ★ [신규] 저장된 데이터가 있는지 확인
      var savedData = await purchaseService.getSavedData(profileKey);

      if (savedData != null) {
        // A. 저장된 게 있으면 -> 호출!
        setState(() {
          _sajuDetail = savedData['sajuDetail'];
          _fortuneReport = savedData['fortuneReport'];
        });
      } else {
        // B. 결제는 했는데 데이터가 날아갔으면(드문 경우) -> 서버 호출 (무료 재조회)
        _fetchSajuData();
      }
    } else {
      // 2. 결제 안 함 -> 결제창 띄우기
      _showPaymentDialog(profileKey);
    }
  }

  // [신규 추가] 모의 결제 다이얼로그
  void _showPaymentDialog(String profileKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("결제 요청"),
          content: const Text(
            "상세 운세를 보려면 결제가 필요합니다.\n(현재 테스트 모드: 무료로 통과됩니다)",
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3436),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                // --- 결제 성공 처리 ---
                Navigator.pop(context); // 창 닫기

                // ★ 로컬 저장소에 '구매 완료' 저장
                await PurchaseService().savePurchase(profileKey, null);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("결제 성공! 분석을 시작합니다.")),
                  );
                  _fetchSajuData(); // 분석 시작
                }
              },
              child: const Text("결제하기 (무료)",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

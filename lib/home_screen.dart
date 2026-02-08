import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui; // 언어 감지용

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:screenshot/screenshot.dart'; // 캡처 패키지
import 'package:share_plus/share_plus.dart'; // 공유 패키지
import 'package:path_provider/path_provider.dart'; // 경로 패키지
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:uuid/uuid.dart';

// 프로젝트 내부 파일 import
import 'package:sj_project_app/services/purchase_service.dart';
import 'package:sj_project_app/services/profile_service.dart';
import 'package:sj_project_app/screens/profile_list_dialog.dart';
import 'package:sj_project_app/utils/localization_data.dart';
import 'city_data.dart';
import 'five_elements.dart';
import '../screens/payment_screen.dart';
import '../screens/daily_fortune_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //final String baseUrl = "https://10.0.2.2:7033/api/Orders";  // PC 에뮬레이터 테스트 시
  //final String baseUrl = "http://192.168.219.149:5110/api/Orders"; // 실제 서버 운영 시 수정 필
  final String baseUrl = "https://joepro-sajuapp-api-linux-bmfvc6dzd0esayhg.koreacentral-01.azurewebsites.net/api/Orders"; // Azure 서버 운영

  // ★ [수정] 캡처 컨트롤러를 여기(변수 선언부)로 옮겨서 에러를 방지했습니다.
  final ScreenshotController _screenshotController = ScreenshotController();

  DateTime _selectedDate = DateTime(1981, 3, 3);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 13, minute: 30);
  String _gender = "M";
  bool _isLunar = false;

  // 기본값은 한국어
  String _targetLanguage = "ko";

  // 기본 도시
  City _selectedCity = globalCities[0];

  bool _isLoading = false;
  bool _isPaymentProcessing = false;
  Map<String, dynamic>? _sajuDetail;
  String? _fortuneReport;

  @override
  void initState() {
    super.initState();
    _detectLanguage();
  }

  void _detectLanguage() {
    // 1. 기기의 현재 시스템 언어 가져오기
    final Locale systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale;

    setState(() {
      _targetLanguage = systemLocale.languageCode == 'ko'
          ? "ko"
          : systemLocale.languageCode == "ja"
              ? "ja"
              : "en";
    });

    print("시스템 언어 감지: ${systemLocale.languageCode} -> 앱 설정: $_targetLanguage");
  }

  // ============================================================
  // [기능 1] 서버 통신 및 데이터 저장
  // ============================================================
  Future<void> _fetchSajuData([String? profileKey]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String birthDate =
          DateFormat("yyyy-MM-dd'T'00:00:00").format(_selectedDate);
      final String birthTime =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      final bodyData = {
        "email": "user@test.com",
        "birthDate": birthDate,
        "birthTime": birthTime,
        "isLunar": _isLunar,
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
        data['lang'] = _targetLanguage; // 언어 정보 추가

        setState(() {
          _sajuDetail = data['sajuDetail'];
          _fortuneReport = data['fortuneReport'];
        });

        // ★ [핵심] 키가 없으면 생성 후 데이터 저장
        if (profileKey == null) {
          final purchaseService = PurchaseService();
          profileKey = purchaseService.generateProfileKey(
              _selectedDate, birthTime, _gender, _isLunar);
        }

        // 내부 저장소에 데이터 캐싱
        await PurchaseService().savePurchase(profileKey, data);
      } else {
        if (mounted) {
          _showError("서버 오류: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        _showError("서버 연결 실패: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // [기능 2] 공유하기 (캡처 후 전송)
  // ============================================================
  Future<void> _shareResult() async {
    // 결과가 없으면 공유 불가
    if (_sajuDetail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("먼저 운세를 분석해주세요!")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 화면 캡처
      final Uint8List? image = await _screenshotController.capture();

      if (image != null) {
        // 임시 저장소 경로 확보
        final directory = await getTemporaryDirectory();
        final imagePath =
            await File('${directory.path}/saju_result.png').create();

        // 이미지 파일 저장
        await imagePath.writeAsBytes(image);

        // 공유 팝업 실행
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: '2026년 내 운세 분석 결과! (SJ Project)',
        );
      }
    } catch (e) {
      print("공유 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("공유하기 실패: 권한을 확인해주세요.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  // 도시 검색
  void _openCitySearch() async {
    final City? result = await showSearch<City?>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (result != null) {
      setState(() => _selectedCity = result);
    }
  }

  // [기능] 프로필 저장
  void _saveCurrentProfile() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("이름 저장"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "예: 남편, 우리 딸"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("취소")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final newProfile = SajuProfile(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                birthDate: _selectedDate,
                birthTime: "${_selectedTime.hour}:${_selectedTime.minute}",
                gender: _gender,
                isLunar: _isLunar,
              );

              await ProfileService().addProfile(newProfile);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("저장되었습니다!")));
              }
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  // [기능] 프로필 불러오기
  void _showLoadProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => ProfileListDialog(
        onSelect: (profile) {
          setState(() {
            _selectedDate = profile.birthDate;
            final parts = profile.birthTime.split(":");
            _selectedTime = TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
            _gender = profile.gender;
            _isLunar = profile.isLunar;

            _sajuDetail = null;
            _fortuneReport = null;
          });
        },
      ),
    );
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

  // ============================================================
  // [메인 UI 빌드]
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        // 제목도 다국어로 나오게 설정
        title: Text(AppLocale.get(_targetLanguage, 'title'),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // 제목 가운데 정렬
        actions: [
          // ★ [언어 선택 팝업 버튼]
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.black),
            onSelected: (String value) {
              setState(() {
                _targetLanguage = value; // 선택한 언어로 변경
              });
              // (선택 사항) 언어 변경 시 안내 메시지
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Language changed to $value"),
                    duration: const Duration(milliseconds: 500)),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'ko',
                child: Text('🇰🇷 한국어'),
              ),
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('🇺🇸 English'),
              ),
              const PopupMenuItem<String>(
                value: 'ja',
                child: Text('🇯🇵 日本語'),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      // ★ Screenshot 위젯으로 전체 감싸기
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: const Color(0xFFF5F6FA), // 배경색 지정 (캡처시 필수)
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader('header_input'),
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
                      targetLanguage: _targetLanguage,
                    ),
                    // ----------------------------------------------------
                    // ⭐ [여기 추가] 오행 분석과 상세 리포트 사이!
                    // ----------------------------------------------------
                    DailyFortuneCard(
                      orderId: _sajuDetail?['orderId'] ?? _sajuDetail?['OrderId'] ?? "",
                      serverUrl: "https://joepro-sajuapp-api-linux-bmfvc6dzd0esayhg.koreacentral-01.azurewebsites.net", // 션 님의 서버 주소
                    ),
                    const SizedBox(height: 30),
                    _buildHeader('header_report'), // "리포트"
                    _buildReportCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String key, {Map<String, String>? params}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        AppLocale.get(_targetLanguage, key, params: params),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
        ),
      ),
    );
  }

  // [입력 카드 위젯]
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
          // 1. 상단 헤더 & 불러오기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocale.get(_targetLanguage, 'header_basic_info'),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                icon: const Icon(Icons.folder_open, size: 20),
                label: Text(AppLocale.get(_targetLanguage, 'btn_load')),
                onPressed: _showLoadProfileDialog,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6C5CE7),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. 날짜/시간 입력
          // 2. 날짜 & 시간 선택 행
          Row(
            children: [
              // 생년월일
              Expanded(
                child: _buildTimePickerField(
                  label: AppLocale.get(
                      _targetLanguage, 'label_birthdate'), // "생년월일"
                  value: DateFormat('yyyy.MM.dd').format(_selectedDate),
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      // 달력도 한국어/영어로 나오게 설정
                      locale: Locale(
                          _targetLanguage == 'ja' ? 'ja' : _targetLanguage),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // 태어난 시
              Expanded(
                child: _buildTimePickerField(
                  label: AppLocale.get(
                      _targetLanguage, 'label_birthtime'), // "태어난 시"
                  value: _selectedTime.format(context),
                  icon: Icons.access_time_outlined,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) setState(() => _selectedTime = time);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 3. 태어난 도시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.get(_targetLanguage, 'label_city'), // "태어난 도시"
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _showCitySearchDialog,
                  child: Row(
                    children: [
                      const Icon(Icons.location_city,
                          size: 20, color: Color(0xFF2D3436)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          // 도시 이름은 번역하기 어려우니 그대로 둡니다 (또는 별도 처리)
                          "${_selectedCity.country}, ${_selectedCity.name}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      const Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. 성별 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGenderBtn(
                  AppLocale.get(_targetLanguage, 'gender_male'), "M"),
              const SizedBox(width: 10),
              _buildGenderBtn(
                  AppLocale.get(_targetLanguage, 'gender_female'), "F"),
            ],
          ),

          // 5. 저장 버튼
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.save_alt, size: 18),
              label: Text(AppLocale.get(
                  _targetLanguage, 'btn_save_info')), // "현재 정보 저장"
              onPressed: _saveCurrentProfile,
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[770],
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // 6. 분석 시작 버튼
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_isLoading || _isPaymentProcessing) ? null : _onAnalyzePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3436),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: (_isLoading || _isPaymentProcessing)
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      AppLocale.get(
                          _targetLanguage, 'btn_analyze'), // "운세 분석 시작"
                        style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. 날짜/시간 선택 버튼 디자인 함수
  Widget _buildTimePickerField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2D3436)),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. 성별 선택 버튼 디자인 함수
  Widget _buildGenderOption(String genderCode, String label) {
    bool isSelected = _gender == genderCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = genderCode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // [수정] 도시 검색 다이얼로그 (기존 데이터 globalCities 활용)
  void _showCitySearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            AppLocale.get(_targetLanguage, 'label_city'), // "태어난 도시" 타이틀
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // 리스트 높이 제한
            child: ListView.builder(
              shrinkWrap: true,
              // ★ 기존에 만드신 'globalCities' 리스트를 여기서 씁니다.
              itemCount: globalCities.length,
              itemBuilder: (context, index) {
                final city = globalCities[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Colors.grey),
                  title: Text(
                    "${city.country}, ${city.name}", // 예: 대한민국, 서울
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    "GMT ${city.timezone >= 0 ? '+' : ''}${city.timezone}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  onTap: () {
                    // 선택 시 상태 업데이트 및 창 닫기
                    setState(() {
                      _selectedCity = city;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  // 4. 저장/불러오기 기능 (에러 방지용 빈 함수)
  void _saveCurrentData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("현재 정보가 저장되었습니다.")),
    );
  }

  void _loadSavedData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("저장된 정보를 불러왔습니다.")),
    );
  }

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

  // [만세력 그리드 위젯]
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildTableLabelColumn(),
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

  // [수정] 대운 리스트 (배경 연하게 + 글자 오행색 복구)
  Widget _buildDaewoonList() {
    if (_sajuDetail == null || _sajuDetail!['daewoonList'] == null)
      return const SizedBox();

    List<dynamic> daewoonList = _sajuDetail!['daewoonList'];
    int daewoonNum = _sajuDetail!['daewoonNum'] ?? 4;

    int currentYear = DateTime.now().year;
    int birthYear = _selectedDate.year;
    int myAge = currentYear - birthYear + 1;

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
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: daewoonList.map((dw) {
              int age = dw['age'];
              bool isCurrent = myAge >= age && myAge < (age + 10);
              int startYear = birthYear + (age - 1); // 대운 시작 연도

              return Container(
                width: 62, // 너비 유지
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  // ★ [수정] 배경색: 선택되면 연한 회색, 아니면 흰색
                  color: isCurrent ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // ★ [수정] 테두리: 선택되면 진한색으로 강조
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF2D3436)
                        : Colors.grey.shade300,
                    width: isCurrent ? 1.5 : 1.0, // 선택되면 조금 더 두껍게
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      dw['gan']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        // ★ [수정] 글자색: 무조건 오행 색상 사용
                        color: _parseColor(dw['gan']['color']),
                      ),
                    ),
                    Text(
                      dw['ji']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        // ★ [수정] 글자색: 무조건 오행 색상 사용
                        color: _parseColor(dw['ji']['color']),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 나이 박스
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        // 나이 배경도 톤에 맞춰 조정
                        color: isCurrent ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$age",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // 연도 텍스트
                    const SizedBox(height: 2),
                    Text(
                      "($startYear)",
                      style: TextStyle(
                        fontSize: 10,
                        // 선택된 항목의 연도를 좀 더 진하게
                        color: isCurrent ? Colors.black54 : Colors.grey[400],
                        fontWeight: FontWeight.w500,
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

  // [수정] 세운 리스트 (배경 연하게 + 글자 오행색 복구)
  Widget _buildSeunList() {
    if (_sajuDetail == null || _sajuDetail!['seunList'] == null)
      return const SizedBox();

    List<dynamic> seunList = _sajuDetail!['seunList'];
    int currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
          child: Text(
            AppLocale.get(_targetLanguage, 'header_seun'),
            style: const TextStyle(
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
            children: seunList.map((sw) {
              int year = sw['year'];
              bool isCurrent = (year == currentYear);

              return Container(
                width: 62, // 대운과 너비 통일
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  // ★ [수정] 배경: 연한 회색
                  color: isCurrent ? Colors.grey[200] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // ★ [수정] 테두리
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF2D3436)
                        : Colors.grey.shade300,
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      sw['gan']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        // ★ [수정] 오행 색상 복구
                        color: _parseColor(sw['gan']['color']),
                      ),
                    ),
                    Text(
                      sw['ji']['hanja'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Serif",
                        // ★ [수정] 오행 색상 복구
                        color: _parseColor(sw['ji']['color']),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrent ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "$year",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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

  Widget _buildTablePillar(
    String label,
    Map<String, dynamic> data, {
    bool isMe = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFFFDE7) : Colors.transparent,
          border: isLast
              ? null
              : Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
        ),
        child: Column(
          children: [
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

  Widget _buildGridChar(String? hanja, String? colorHex) {
    Color color = _parseColor(colorHex);
    String hangul = _getHangul(hanja);

    return Column(
      children: [
        Text(
          hanja ?? "",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: "Serif",
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

  Widget _buildTableLabelColumn() {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey[50],
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "",
              style: TextStyle(fontSize: 13, height: 1.0),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
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
          Container(
            height: 20,
            alignment: Alignment.center,
            child: Text(
              AppLocale.get(_targetLanguage, 'label_shipseong'),
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 12),
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

  Widget _buildGridShipseong(String? text) {
    if (text == null || text.isEmpty) return const SizedBox();
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

  Widget _buildAnalysisCard() {
    if (_sajuDetail == null) return const SizedBox();
    Map<String, dynamic> run = _sajuDetail!['elementRun'];
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 33,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'wood'),
                    run['목'], const Color(0xFF4CAF50)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'fire'),
                    run['화'], const Color(0xFFF44336)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'earth'),
                    run['토'], const Color(0xFFFFC107)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'metal'),
                    run['금'], const Color(0xFF9E9E9E)),
                _buildAnalysisRow(AppLocale.get(_targetLanguage, 'water'),
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
      radius: 22,
      showTitle: false,
    );
  }

  Widget _buildAnalysisRow(String label, dynamic value, Color color) {
    double val = (value is int) ? value.toDouble() : (value as double);
    String statusKey = val > 35
        ? 'status_excess'
        : (val < 10 ? 'status_lack' : 'status_proper');
    String statusText = AppLocale.get(_targetLanguage, statusKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12, color: Color.fromARGB(221, 47, 47, 47)),
              ),
            ],
          ),
          Text(
            "${val.toInt()}% ($statusText)",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: statusKey == 'status_proper' ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYongsinCard() {
    if (_sajuDetail == null) return const SizedBox();

    String yongsin = _sajuDetail!['yongsin'] ?? "알 수 없음";
    String dayMasterElem = _sajuDetail!['dayMasterElement'] ?? "";

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: yColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              yongsinTrans,
              style: TextStyle(
                fontSize: _targetLanguage == 'en' ? 15 : 30,
                fontWeight: FontWeight.bold,
                color: yColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  String _getElemKey(String korName) {
    if (korName.contains('목')) return 'wood';
    if (korName.contains('화')) return 'fire';
    if (korName.contains('토')) return 'earth';
    if (korName.contains('금')) return 'metal';
    if (korName.contains('수')) return 'water';
    return 'unknown';
  }

  // [수정] 상세 운세 리포트 카드 (기존 디자인 유지 + 왼쪽 정렬 고정)
  Widget _buildReportCard() {
    // 데이터가 없으면 빈 공간 표시
    if (_fortuneReport == null) return const SizedBox();

    return Container(
      width: double.infinity, // 가로로 꽉 채우기
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 기존 둥근 모서리 유지
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // ★★★ [핵심] 글자들을 왼쪽(Start)으로 정렬 ★★★
        // 이 한 줄이 없어서 가운데 정렬(시 처럼) 되었던 것입니다.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 헤더 (아이콘 + 제목)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF1976D2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocale.get(_targetLanguage, 'header_report'), // "상세 운세 리포트"
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),

          // 2. HTML 내용 (왼쪽 정렬 적용)
          HtmlWidget(
            _fortuneReport?.replaceAll("```", "") ?? "", // 코드 블록 마커 제거
            textStyle: const TextStyle(
              fontSize: 15,
              height: 1.8, // 줄 간격 시원하게
              color: Color(0xFF424242),
              letterSpacing: -0.2,
            ),
            // 태그별 스타일 지정 (기존 코드 유지하되 왼쪽 정렬 확실히 적용)
            customStylesBuilder: (element) {
              // 제목(h3) 스타일
              if (element.localName == 'h3') {
                return {
                  'font-size': '18px',
                  'font-weight': 'bold',
                  'color': '#1565C0',
                  'margin-top': '24px',
                  'margin-bottom': '12px',
                  'border-bottom': '2px solid #E3F2FD',
                  'padding-bottom': '4px',
                  'display': 'block', // 블록 요소로 처리
                  'text-align': 'left', // ★ 왼쪽 정렬 강제
                };
              }
              // 강조(b, strong) 스타일
              if (element.localName == 'b' || element.localName == 'strong') {
                return {'color': '#212121', 'font-weight': '700'};
              }
              // 리스트(li) 간격
              if (element.localName == 'li') {
                return {
                  'margin-bottom': '8px',
                  'text-align': 'left' // ★ 왼쪽 정렬 강제
                };
              }
              // 기본적으로 왼쪽 정렬
              return {'text-align': 'left'};
            },
          ),

          const SizedBox(height: 30),

          // 3. 하단 안내 문구
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
  // [메인 로직] 운세 분석 시작 버튼 클릭 시
  // ============================================================
  void _onAnalyzePressed() async {
    // 1. 이미 분석 중이거나 결제 중이면 클릭 무시 (중복 방지)
    if (_isLoading || _isPaymentProcessing) return;

    try {
      final purchaseService = PurchaseService();
      
      // 날짜/시간 포맷팅
      String birthTimeStr =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      // 프로필 키 생성
      String profileKey = purchaseService.generateProfileKey(
        _selectedDate,
        birthTimeStr,
        _gender,
        _isLunar,
      );

      // 2. 먼저 결제 여부 확인
      bool isPurchased = await purchaseService.isPurchased(profileKey);

      if (isPurchased) {
        // [CASE A] 이미 결제된 내역이 있음 -> 바로 분석 시작
        await _startAnalysisProcess(profileKey, purchaseService);
      } else {
        // [CASE B] 결제 안 됨 -> 결제 진행
        
        // 버튼을 '결제 중' 로딩 상태로 변경
        setState(() {
          _isPaymentProcessing = true; 
        });

        // ★ 결제 화면으로 이동하고 결과가 나올 때까지 대기(await)
        await _showPaymentScreen(profileKey);

        // 결제 화면에서 돌아옴 (성공이든 취소든) -> 일단 결제 로딩 끔
        setState(() {
          _isPaymentProcessing = false;
        });

        // 3. 돌아왔으니 진짜 결제 성공했는지 재확인
        bool isPaidNow = await purchaseService.isPurchased(profileKey);
        
        if (isPaidNow) {
          // 결제 성공 확인됨 -> 분석 시작
          await _startAnalysisProcess(profileKey, purchaseService);
        } 
        // 결제 실패/취소 시에는 아무것도 안 함 (버튼이 다시 활성화됨)
      }

    } catch (e) {
      // 에러 발생 시 모든 상태 초기화
      setState(() { 
        _isLoading = false;
        _isPaymentProcessing = false;
      });
      print("에러 발생: $e");
      if (mounted) _showError("오류가 발생했습니다: $e");
    }
  }

  // ============================================================
  // [보조 로직] 실제 분석 데이터 처리 (캐시 확인 or 서버 호출)
  // ============================================================
  Future<void> _startAnalysisProcess(String profileKey, PurchaseService purchaseService) async {
    setState(() {
      _isLoading = true; // 이제부터는 '분석 중' 로딩 표시
    });

    try {
      // 캐시 데이터 확인
      var savedData = await purchaseService.getSavedData(profileKey);

      // 캐시가 있고 언어가 같으면 서버 호출 없이 바로 적용
      if (savedData != null && savedData['lang'] == _targetLanguage) {
        setState(() {
          _sajuDetail = savedData['sajuDetail'];
          _fortuneReport = savedData['fortuneReport'];
          _isLoading = false; // 분석 완료
        });
        return;
      }

      // 캐시 없으면 서버 호출 (이 함수 내부에서 로딩 끄는 처리가 있다고 가정)
      await _fetchSajuData(profileKey);
      
    } catch (e) {
      setState(() { _isLoading = false; });
      rethrow; // 상위 catch로 에러 전달
    }
  }

  // [토스페이먼츠] 결제 화면 호출
  Future<void> _showPaymentScreen(String profileKey) async {
        // 1. [추가] 주문 번호 생성 (이게 없어서 에러가 났습니다!)
    String newOrderId = "ORDER_${DateTime.now().millisecondsSinceEpoch}";

    // 2. 통화와 금액 결정
    String selectedCurrency = _targetLanguage == 'ko' ? 'KRW' : 'USD';
    int amount = _targetLanguage == 'ko' ? 9600 : 7;


    // [기존 코드] 결제 화면으로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          orderId: newOrderId,
          orderName: '사주 운세 분석', // 1회성 상품 이름
          amount: 9600, // 1회성 가격
          currency: "KRW",
          isBilling: false, // ★ HomeScreen은 무조건 일반 결제입니다!
        ),
      ),
    );
    
      print("👀 결제 화면에서 돌아옴. 결과값: $result");
   // String paymentKey = result['paymentKey'] ?? result['authKey'] ?? "";
  //  String orderId = result['orderId'] ?? "";

    if (result != null && result['success'] == true) {
      
      // 1. 데이터 안전하게 꺼내기
      String paymentKey = result['paymentKey'] ?? result['authKey'] ?? "";
      String resOrderId = result['orderId'] ?? "";
      num resAmount = result['amount'] ?? 0;
      String resCurrency = result['currency'] ?? "KRW";

      if (paymentKey.isEmpty) {
        print("❌ 결제 키가 없습니다.");
        return;
      }

      // 2. 서버 검증 요청 (HomeScreen은 무조건 _verifyPaymentWithServer 호출)
      // ★ 주석을 풀고 변수에 결과를 담습니다!
      bool serverSaved = await _verifyPaymentWithServer(
        paymentKey, 
        resOrderId, 
        resAmount, 
        resCurrency
      );

      // 3. 검증 결과에 따른 처리
      if (serverSaved) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("결제가 완료되었습니다! 분석을 시작합니다.")),
           );

           await _fetchSajuData(profileKey);        
           // TODO: 분석 결과 화면으로 이동하는 코드 추가
           // Navigator.pushReplacement(context, ...);

        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("결제는 됐으나 서버 저장에 실패했습니다.")),
           );
        }
      }
    } else {
       print("결제 취소 또는 실패");
    }   
  }

  // [서버 통신] C# 서버에 토스 결제 승인 요청
  Future<bool> _verifyPaymentWithServer(
      String paymentKey, String orderId, num amount, String currency) async {
    try {
      final bodyData = {
        "paymentKey": paymentKey,
        "orderId": orderId,
        "amount": amount,
        "currency": currency,
      };

      // ★ 서버 주소: PaymentController의 ConfirmPayment 함수 주소
      String paymentUrl = baseUrl.replaceAll("/Orders", "/Payment");
      final response = await http.post(
        Uri.parse("$paymentUrl/complete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        // 서버 응답이 OK(200)이면 성공
        return true;
      } else {
        print("서버 승인 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      print("서버 통신 오류: $e");
      return false;
    }
  }
}


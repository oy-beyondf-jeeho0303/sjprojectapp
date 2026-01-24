import 'dart:convert'; // jsonEncode, jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  // 싱글톤 패턴 (어디서든 똑같은 녀석을 부르기 위해)
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // ★ 사주 고유 ID(Hash) 생성기
  // 예: "19810303_1330_M_SOLAR" 처럼 만듭니다.
  String generateProfileKey(
      DateTime date, String? time, String gender, bool isLunar) {
    String dateStr =
        "${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}";
    String timeStr =
        (time == null || time.isEmpty) ? "UNKNOWN" : time.replaceAll(":", "");
    String lunarStr = isLunar ? "L" : "S";

    // 키 조합: 년월일_시간_성별_음양
    return "${dateStr}_${timeStr}_${gender}_$lunarStr";
  }

  // 1. 이미 구매했는지 확인
  Future<bool> isPurchased(String profileKey) async {
    final prefs = await SharedPreferences.getInstance();
    // 저장소에 키가 있으면 true, 없으면 false
    return prefs.getBool(profileKey) ?? false;
  }

  // [수정] data 파라미터에 '?'를 붙여서 null 허용
  Future<void> savePurchase(
      String profileKey, Map<String, dynamic>? data) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. "구매했음" 표시는 무조건 저장
    await prefs.setBool(profileKey, true);

    // 2. 데이터는 "있을 때만" 저장
    if (data != null) {
      String jsonString = jsonEncode(data);
      await prefs.setString("${profileKey}_DATA", jsonString);
    }
  }

  // [신규] 저장된 데이터 불러오기
  Future<Map<String, dynamic>?> getSavedData(String profileKey) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("${profileKey}_DATA");

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // (선택) 모든 구매 내역 삭제 (테스트용)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

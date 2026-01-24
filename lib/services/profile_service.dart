import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 1. 프로필 데이터 모델 (DTO)
class SajuProfile {
  final String id; // 고유 ID (식별용)
  final String name; // 이름 (예: 남편, 우리 아기)
  final DateTime birthDate;
  final String birthTime; // "13:30" 형식
  final String gender; // "M" or "F"
  final bool isLunar;

  SajuProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    required this.isLunar,
  });

  // JSON 변환 로직 (저장용)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'birthTime': birthTime,
        'gender': gender,
        'isLunar': isLunar,
      };

  factory SajuProfile.fromJson(Map<String, dynamic> json) => SajuProfile(
        id: json['id'],
        name: json['name'],
        birthDate: DateTime.parse(json['birthDate']),
        birthTime: json['birthTime'],
        gender: json['gender'],
        isLunar: json['isLunar'],
      );
}

// 2. 서비스 클래스
class ProfileService {
  static const String _storageKey = 'saved_profiles';

  // 프로필 목록 불러오기
  Future<List<SajuProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => SajuProfile.fromJson(e)).toList();
  }

  // 프로필 추가하기
  Future<void> addProfile(SajuProfile profile) async {
    final profiles = await getProfiles();
    profiles.add(profile);
    await _saveToDisk(profiles);
  }

  // 프로필 삭제하기
  Future<void> deleteProfile(String id) async {
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _saveToDisk(profiles);
  }

  // 내부 저장 로직
  Future<void> _saveToDisk(List<SajuProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        jsonEncode(profiles.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}

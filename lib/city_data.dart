import 'package:flutter/material.dart';

// 1. 도시 데이터 모델
class City {
  final String name; // 도시명
  final String country; // 국가명
  final double lat; // 위도
  final double lng; // 경도
  final double timezone; // 시차

  City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
    required this.timezone,
  });
}

// 2. 전세계 주요 도시 데이터
final List<City> globalCities = [
  City(name: "서울", country: "대한민국", lat: 37.5665, lng: 126.9780, timezone: 9.0),
  City(name: "부산", country: "대한민국", lat: 35.1796, lng: 129.0756, timezone: 9.0),
  City(name: "도쿄", country: "일본", lat: 35.6762, lng: 139.6503, timezone: 9.0),
  City(name: "베이징", country: "중국", lat: 39.9042, lng: 116.4074, timezone: 8.0),
  City(name: "뉴욕", country: "미국", lat: 40.7128, lng: -74.0060, timezone: -5.0),
  City(name: "LA", country: "미국", lat: 34.0522, lng: -118.2437, timezone: -8.0),
  City(name: "런던", country: "영국", lat: 51.5074, lng: -0.1278, timezone: 0.0),
  City(name: "파리", country: "프랑스", lat: 48.8566, lng: 2.3522, timezone: 1.0),
  City(
    name: "시드니",
    country: "호주",
    lat: -33.8688,
    lng: 151.2093,
    timezone: 10.0,
  ),
  City(
    name: "상파울루",
    country: "브라질",
    lat: -23.5505,
    lng: -46.6333,
    timezone: -3.0,
  ),
  City(name: "호치민", country: "베트남", lat: 10.8231, lng: 106.6297, timezone: 7.0),
];

// 3. ★★★ 도시 검색 기능 ★★★
// <City?> 물음표가 있어야 '뒤로가기' 했을 때 null을 반환할 수 있습니다.
class CitySearchDelegate extends SearchDelegate<City?> {
  @override
  String get searchFieldLabel => "도시명 검색 (예: 서울, 뉴욕)";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = "", icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () =>
          close(context, null), // ★ 여기서 에러가 안 나려면 위 클래스 정의에 ?가 있어야 함
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = globalCities
        .where(
          (city) => city.name.contains(query) || city.country.contains(query),
        )
        .toList();
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? globalCities
        : globalCities
              .where(
                (city) =>
                    city.name.contains(query) || city.country.contains(query),
              )
              .toList();
    return _buildList(suggestions);
  }

  Widget _buildList(List<City> cities) {
    if (cities.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return ListTile(
          leading: const Icon(Icons.location_city, color: Colors.blueGrey),
          title: Text(
            city.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${city.country} (GMT ${city.timezone >= 0 ? '+' : ''}${city.timezone})",
          ),
          onTap: () {
            close(context, city); // 선택한 도시 반환
          },
        );
      },
    );
  }
}

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
  City(name: "Seoul", country: "South Korea", lat: 37.5665, lng: 126.9780, timezone: 9.0),
  City(name: "Busan", country: "South Korea", lat: 35.1796, lng: 129.0756, timezone: 9.0),
  City(name: "Incheon", country: "South Korea", lat: 37.4563, lng: 126.7052, timezone: 9.0),
  City(name: "Jeju", country: "South Korea", lat: 33.4996, lng: 126.5312, timezone: 9.0),

// 🇯🇵 Japan
  City(name: "Tokyo", country: "Japan", lat: 35.6762, lng: 139.6503, timezone: 9.0),
  City(name: "Osaka", country: "Japan", lat: 34.6937, lng: 135.5023, timezone: 9.0),
  City(name: "Fukuoka", country: "Japan", lat: 33.5904, lng: 130.4017, timezone: 9.0),
  City(name: "Sapporo", country: "Japan", lat: 43.0618, lng: 141.3545, timezone: 9.0),

  // 🇺🇸 USA (Timezone & Longitude diversity)
  City(name: "New York", country: "USA", lat: 40.7128, lng: -74.0060, timezone: -5.0), // EST
  City(name: "Chicago", country: "USA", lat: 41.8781, lng: -87.6298, timezone: -6.0), // CST
  City(name: "Denver", country: "USA", lat: 39.7392, lng: -104.9903, timezone: -7.0), // MST
  City(name: "Los Angeles", country: "USA", lat: 34.0522, lng: -118.2437, timezone: -8.0), // PST
  City(name: "San Francisco", country: "USA", lat: 37.7749, lng: -122.4194, timezone: -8.0),
  City(name: "Seattle", country: "USA", lat: 47.6062, lng: -122.3321, timezone: -8.0),
  City(name: "Honolulu", country: "USA", lat: 21.3069, lng: -157.8583, timezone: -10.0), // HST

  // 🇨🇳 China
  City(name: "Beijing", country: "China", lat: 39.9042, lng: 116.4074, timezone: 8.0),
  City(name: "Shanghai", country: "China", lat: 31.2304, lng: 121.4737, timezone: 8.0),

  // 🇪🇺 Europe
  City(name: "London", country: "UK", lat: 51.5074, lng: -0.1278, timezone: 0.0),
  City(name: "Paris", country: "France", lat: 48.8566, lng: 2.3522, timezone: 1.0),
  City(name: "Berlin", country: "Germany", lat: 52.5200, lng: 13.4050, timezone: 1.0),
  
  City(name: "Singapore", country: "Singapore", lat: 1.3521, lng: 103.8198, timezone: 8.0),
  City(name: "Ho Chi Minh", country: "Vietnam", lat: 10.8231, lng: 106.6297, timezone: 7.0),
];

// 3. ★★★ 도시 검색 기능 ★★★
// <City?> 물음표가 있어야 '뒤로가기' 했을 때 null을 반환할 수 있습니다.
class CitySearchDelegate extends SearchDelegate<City?> {
  @override
  String get searchFieldLabel => "Search for city (e.g., Seoul, LA, Tokyo)";

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

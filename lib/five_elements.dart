import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sj_project_app/utils/localization_data.dart';

class FiveElementsDiagram extends StatelessWidget {
  final Map<String, dynamic>? elementRun;
  final String? dayMasterElement;
  final String targetLanguage;

  const FiveElementsDiagram({
    super.key,
    required this.elementRun,
    required this.dayMasterElement,
    required this.targetLanguage,
  });

  @override
  Widget build(BuildContext context) {
    // 데이터 없으면 0으로 초기화
    final data = elementRun ?? {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};

    // 로직용 순서 (고정)
    final List<String> standardOrder = ['목', '화', '토', '금', '수'];

    // 1. 일간을 맨 위(12시 방향)로 보내기 위한 회전 로직
    List<String> rotatedOrder = [];
    if (dayMasterElement != null && standardOrder.contains(dayMasterElement)) {
      int startIndex = standardOrder.indexOf(dayMasterElement!);
      rotatedOrder = [
        ...standardOrder.sublist(startIndex),
        ...standardOrder.sublist(0, startIndex),
      ];
    } else {
      rotatedOrder = standardOrder;
    }

    // 2. 화면 표시용 데이터 변환
    final List<Map<String, dynamic>> displayElements = rotatedOrder.map((key) {
      String isoKey = _getIsoKey(key);
      String translatedName = AppLocale.get(targetLanguage, isoKey);

      return {
        'key': key,
        'name': translatedName,
        'color': _getElementColor(key),
        'value': data[key], // 여기서는 값 그대로 전달 (int or double)
        'isDayMaster': key == dayMasterElement,
      };
    }).toList();

    // 3. 일간 이름 번역
    String dayMasterKey = _getIsoKey(dayMasterElement ?? "");
    String dayMasterName = AppLocale.get(targetLanguage, dayMasterKey);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ★ [수정] 헤더 레이아웃: Row 대신 Column + Wrap 사용으로 넘침 방지
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocale.get(targetLanguage, 'diagram_standard',
                    params: {'elem': dayMasterName}),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildLegendItem(
                      AppLocale.get(targetLanguage, 'diagram_saeng'),
                      Colors.blue),
                  const SizedBox(width: 12),
                  _buildLegendItem(
                      AppLocale.get(targetLanguage, 'diagram_geuk'),
                      Colors.redAccent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 다이어그램 영역
          SizedBox(
            height: 300,
            width: double.infinity,
            child: CustomPaint(
              painter: _PentagonPainter(displayElements),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.arrow_right_alt, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getElementColor(String key) {
    if (key.contains('목')) return const Color(0xFF4CAF50);
    if (key.contains('화')) return const Color(0xFFF44336);
    if (key.contains('토')) return const Color(0xFFFFC107);
    if (key.contains('금')) return const Color(0xFF9E9E9E);
    if (key.contains('수')) return const Color(0xFF2196F3);
    return Colors.grey;
  }

  String _getIsoKey(String korName) {
    if (korName.contains('목')) return 'wood';
    if (korName.contains('화')) return 'fire';
    if (korName.contains('토')) return 'earth';
    if (korName.contains('금')) return 'metal';
    if (korName.contains('수')) return 'water';
    return 'unknown';
  }
}

// =========================================================
// 화가 클래스 (Painter)
// =========================================================
class _PentagonPainter extends CustomPainter {
  final List<Map<String, dynamic>> elements;

  _PentagonPainter(this.elements);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // 반지름을 조금 줄여서 글자가 잘리지 않게 함
    final radius = min(size.width, size.height) / 2 - 40;

    final paintLineSaeng = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintLineGeuk = Paint()
      ..color = Colors.redAccent.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    List<Offset> points = [];

    // 1. 꼭짓점 좌표 계산
    for (int i = 0; i < 5; i++) {
      double angle = (2 * pi * i) / 5 - (pi / 2);
      points.add(Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      ));
    }

    // 2. 화살표 그리기
    for (int i = 0; i < 5; i++) {
      // 생 (i -> i+1)
      _drawArrow(canvas, points[i], points[(i + 1) % 5], paintLineSaeng,
          isGeuk: false);
      // 극 (i -> i+2)
      _drawArrow(canvas, points[i], points[(i + 2) % 5], paintLineGeuk,
          isGeuk: true);
    }

    // 3. 원 그리기
    for (int i = 0; i < 5; i++) {
      _drawElementCircle(canvas, points[i], elements[i]);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint,
      {required bool isGeuk}) {
    double circleRadius = 35.0; // 원 크기 고려
    double angle = atan2(end.dy - start.dy, end.dx - start.dx);

    // 선이 원 안쪽까지 들어오지 않게 시작/끝점 조정
    Offset startAdjusted = Offset(
      start.dx + circleRadius * cos(angle),
      start.dy + circleRadius * sin(angle),
    );
    Offset endAdjusted = Offset(
      end.dx - circleRadius * cos(angle),
      end.dy - circleRadius * sin(angle),
    );

    canvas.drawLine(startAdjusted, endAdjusted, paint);

    // 화살표 머리
    double arrowSize = isGeuk ? 4 : 6;
    var path = Path();
    path.moveTo(endAdjusted.dx, endAdjusted.dy);
    path.lineTo(
      endAdjusted.dx - arrowSize * cos(angle - pi / 6),
      endAdjusted.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      endAdjusted.dx - arrowSize * cos(angle + pi / 6),
      endAdjusted.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    var arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, arrowPaint);
  }

  void _drawElementCircle(
      Canvas canvas, Offset center, Map<String, dynamic> data) {
    bool isMe = data['isDayMaster'];
    Color color = data['color'];
    String name = data['name'];

    // ★ [수정 핵심] int가 아니라 num으로 받아서 소수점 에러 방지!
    num rawValue = data['value'];

    // 소수점이 있으면 보여주고(.1), 없으면 정수로 표시
    String valueText = (rawValue % 1 == 0)
        ? "${rawValue.toInt()}%"
        : "${rawValue.toStringAsFixed(1)}%";

    Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = color
      ..strokeWidth = isMe ? 4 : 2
      ..style = PaintingStyle.stroke;

    // 그림자
    canvas.drawCircle(
        center,
        30,
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // 원 그리기
    canvas.drawCircle(center, 30, circlePaint);
    canvas.drawCircle(center, 30, borderPaint);

    // 텍스트 (이름) - 영어일 때 글자가 길어질 수 있으므로 조정
    TextSpan spanName = TextSpan(
      style: TextStyle(
          color: color,
          fontSize: name.length > 3 ? 11 : 14, // 글자 길이에 따라 크기 조절
          fontWeight: FontWeight.bold),
      text: name,
    );
    TextPainter tpName = TextPainter(
        text: spanName,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tpName.layout();
    tpName.paint(canvas, Offset(center.dx - tpName.width / 2, center.dy - 8));

    // 텍스트 (값)
    TextSpan spanValue = TextSpan(
      style: TextStyle(color: Colors.grey[600], fontSize: 10),
      text: valueText, // 수정된 텍스트 사용
    );
    TextPainter tpValue = TextPainter(
        text: spanValue,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tpValue.layout();
    tpValue.paint(canvas, Offset(center.dx - tpValue.width / 2, center.dy + 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

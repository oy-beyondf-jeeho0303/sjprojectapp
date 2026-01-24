// lib/five_elements.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

// 오행 생극도 위젯
class FiveElementsDiagram extends StatelessWidget {
  final Map<String, dynamic>? elementRun;
  final String? dayMasterElement;

  const FiveElementsDiagram({
    super.key,
    this.elementRun,
    this.dayMasterElement,
  });

  @override
  Widget build(BuildContext context) {
    final data = elementRun ?? {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0};
    final List<String> standardOrder = ['목', '화', '토', '금', '수'];

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

    final List<Map<String, dynamic>> displayElements = rotatedOrder.map((key) {
      return {
        'name': key,
        'color': _getElementColor(key),
        'value': data[key],
        'isDayMaster': key == dayMasterElement,
      };
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "기준: ${dayMasterElement ?? '목'} 일간",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  _buildLegend(Colors.blue, "생(生)"),
                  const SizedBox(width: 15),
                  _buildLegend(Colors.red, "극(剋)"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double size = constraints.maxWidth;
                final double layoutRadius = size / 2.8;
                final double center = size / 2;
                final double nodeSize = 70.0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(size, size),
                      painter: FiveElementsPainter(
                        layoutRadius: layoutRadius,
                        nodeRadius: nodeSize / 2,
                      ),
                    ),
                    ...List.generate(displayElements.length, (index) {
                      final double angle = (index * 72 - 90) * (math.pi / 180);
                      final double x = center + layoutRadius * math.cos(angle);
                      final double y = center + layoutRadius * math.sin(angle);

                      return Positioned(
                        left: x - nodeSize / 2,
                        top: y - nodeSize / 2,
                        child: _buildElementNode(
                          displayElements[index],
                          nodeSize,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementNode(Map<String, dynamic> item, double size) {
    bool isDM = item['isDayMaster'];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDM ? item['color'].withOpacity(0.1) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: item['color'], width: isDM ? 4 : 3),
        boxShadow: [
          BoxShadow(
            color: (item['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: item['color'],
            ),
          ),
          Text(
            "${item['value']}%",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.arrow_right_alt, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
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
}

// 화살표 그리는 화가 클래스
class FiveElementsPainter extends CustomPainter {
  final double layoutRadius;
  final double nodeRadius;

  FiveElementsPainter({required this.layoutRadius, required this.nodeRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Paint sangsaengPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final Paint sanggeukPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    List<Offset> centers = [];
    for (int i = 0; i < 5; i++) {
      final double angle = (i * 72 - 90) * (math.pi / 180);
      centers.add(
        Offset(
          center.dx + layoutRadius * math.cos(angle),
          center.dy + layoutRadius * math.sin(angle),
        ),
      );
    }

    for (int i = 0; i < 5; i++) {
      int next = (i + 1) % 5;
      _drawShortArrow(
        canvas,
        centers[i],
        centers[next],
        nodeRadius,
        sangsaengPaint,
      );
    }

    List<int> starPath = [0, 2, 4, 1, 3, 0];
    for (int i = 0; i < 5; i++) {
      int start = starPath[i];
      int end = starPath[i + 1];
      _drawShortArrow(
        canvas,
        centers[start],
        centers[end],
        nodeRadius,
        sanggeukPaint,
      );
    }
  }

  void _drawShortArrow(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double radius,
    Paint paint,
  ) {
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    double distance = math.sqrt(dx * dx + dy * dy);
    double unitX = dx / distance;
    double unitY = dy / distance;

    Offset startDraw = Offset(
      p1.dx + unitX * (radius * 1.05),
      p1.dy + unitY * (radius * 1.05),
    );
    Offset endDraw = Offset(
      p2.dx - unitX * (radius * 1.35),
      p2.dy - unitY * (radius * 1.35),
    );

    canvas.drawLine(startDraw, endDraw, paint);
    _drawArrowHead(canvas, startDraw, endDraw, paint.color);
  }

  void _drawArrowHead(Canvas canvas, Offset p1, Offset p2, Color color) {
    double angle = math.atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    final double arrowSize = 10;
    final Path arrowPath = Path();
    arrowPath.moveTo(p2.dx, p2.dy);
    arrowPath.lineTo(
      p2.dx - arrowSize * math.cos(angle - math.pi / 7),
      p2.dy - arrowSize * math.sin(angle - math.pi / 7),
    );
    arrowPath.lineTo(
      p2.dx - arrowSize * math.cos(angle + math.pi / 7),
      p2.dy - arrowSize * math.sin(angle + math.pi / 7),
    );
    arrowPath.close();
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

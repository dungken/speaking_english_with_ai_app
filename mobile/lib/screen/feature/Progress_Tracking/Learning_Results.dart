import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class LearningResultScreen extends StatelessWidget {
  const LearningResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.06, vertical: mq.height * 0.04),
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: mq.width * 0.7,
              padding: EdgeInsets.all(mq.width * 0.06),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Số lần nói tiếng anh',
                    style: TextStyle(
                      fontSize: mq.width * 0.045,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '200',
                    style: TextStyle(
                      fontSize: mq.width * 0.12,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Tình hình học học tập của tôi',
            style: TextStyle(
              fontSize: mq.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              PronunciationItem(percent: 100, delta: 0, label: 'Luyện cụm'),
              PronunciationItem(percent: 93, delta: 7, label: 'Mô tả tranh'),
              PronunciationItem(percent: 16, delta: -19, label: 'Hội thoại'),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Luyện tập phần còn yếu'),
          ),
          const SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(mq.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến trình học hôm nay so với hôm qua',
                  style: TextStyle(fontSize: mq.width * 0.045, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: mq.height * 0.25,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.teal.withOpacity(0.8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y} điểm',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, _) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Hôm qua');
                                case 1:
                                  return const Text('Hôm nay');
                                default:
                                  return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        // Đường cho điểm hôm qua
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          spots: const [
                            FlSpot(0, 60), // Hội thoại hôm qua
                            FlSpot(1, 80), // Luyện cụm hôm qua
                            FlSpot(2, 70), // Mô tả tranh hôm qua
                          ],
                          dotData: FlDotData(show: true),
                        ),
                        // Đường cho điểm hôm nay
                        LineChartBarData(
                          isCurved: true,
                          color: Colors.teal,
                          barWidth: 3,
                          spots: const [
                            FlSpot(0, 75), // Hội thoại hôm nay
                            FlSpot(1, 90), // Luyện cụm hôm nay
                            FlSpot(2, 85), // Mô tả tranh hôm nay
                          ],
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PronunciationItem extends StatelessWidget {
  final int percent;
  final int delta;
  final String label;

  const PronunciationItem({
    super.key,
    required this.percent,
    required this.delta,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isUp = delta >= 0;
    final Color color = isUp ? Colors.green : Colors.red;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: mq.width * 0.05,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                '$percent%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: mq.width * 0.04,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 18,
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

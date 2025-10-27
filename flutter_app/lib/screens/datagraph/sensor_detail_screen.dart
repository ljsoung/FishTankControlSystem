import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class SensorDetailScreen extends StatefulWidget {
  const SensorDetailScreen({super.key});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  // 선택 상태
  String selectedParameter = '수온'; // '수온' / '수질' / '용존산소'
  String selectedRange = '1시간 단위'; // '1시간 단위' / '하루 단위' / '일주일 단위'

  bool isParameterOpen = true;
  bool isRangeOpen = false;

  // 샘플 데이터 생성 (실제선은 서버/센서 값으로 바꿔서 사용)
  List<FlSpot> _generateSample(String param, String range) {
    final rnd = Random(param.hashCode ^ range.hashCode);
    int points;
    double xStep;
    if (range == '1시간 단위') {
      points = 5; // 12~24시 등 13점 (예)
      xStep = 1;
    } else if (range == '일주일 단위') {
      points = 8; // 7일 + 시작점
      xStep = 1;
    } else {
      points = 30; // 한달(예시)
      xStep = 1;
    }

    double base;
    if (param == '수온') base = 20; // 섭씨 기준
    else if (param == '수질') base = 250; // TDS 기준
    else base = 8; // DO 기준

    return List.generate(points, (i) {
      final jitter = (rnd.nextDouble() - 0.5) * (base * 0.12);
      final value = base + jitter + sin(i / max(1, points / 3)) * (base * 0.12);
      return FlSpot(i * xStep.toDouble(), double.parse(value.toStringAsFixed(2)));
    });
  }

  // 차트 스타일 데이터 생성
  LineChartData _makeLineChartData(List<FlSpot> spots, String param) {
    final minY = spots.map((s) => s.y).reduce(min);
    final maxY = spots.map((s) => s.y).reduce(max);
    final yMargin = (maxY - minY) * 0.15;

    return LineChartData(
      minX: spots.first.x,
      maxX: spots.last.x,
      minY: (minY - yMargin),
      maxY: (maxY + yMargin),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: ((maxY - minY) / 4).abs() > 0 ? ((maxY - minY) / 4) : 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: ((maxY - minY) / 4).abs() > 0 ? ((maxY - minY) / 4) : 1,
            getTitlesWidget: (val, meta) {
              return Text(val.toStringAsFixed(0), style: const TextStyle(color: Colors.white70, fontSize: 12));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (spots.length / 4).floor().clamp(1, spots.length).toDouble(),
            getTitlesWidget: (val, meta) {
              final idx = val.toInt();
              // 간단한 라벨 예시 (시간/일 등)
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  ' ${idx.toString()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: param == '수온' ? Colors.yellowAccent : (param == '수질' ? Colors.tealAccent : Colors.cyanAccent),
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                (param == '수온' ? Colors.yellowAccent : (param == '수질' ? Colors.tealAccent : Colors.cyanAccent)).withOpacity(0.35),
                Colors.transparent
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          // 각 툴팁 박스의 배경색을 스팟 단위로 반환
          getTooltipColor: (LineBarSpot touchedSpot) {
            return Colors.black87;
          },
          // 툴팁 내용 생성
          getTooltipItems: (touched) {
            return touched.map((t) {
              return LineTooltipItem(
                '${t.y}',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    // 현재 선택된 파라미터/범위에 따른 데이터
    final spots = _generateSample(selectedParameter, selectedRange);
    final chartData = _makeLineChartData(spots, selectedParameter);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.redAccent),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              height: sh * 0.37,
              child: Card(
                color: const Color(0xFF0E8DB6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // 상단 small label row (토글처럼 보이게)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildToggleLabel('수온', selectedParameter == '수온', onTap: () {
                            setState(() {
                              selectedParameter = '수온';
                            });
                          }),
                          _buildToggleLabel('수질', selectedParameter == '수질', onTap: () {
                            setState(() {
                              selectedParameter = '수질';
                            });
                          }),
                          _buildToggleLabel('용존산소', selectedParameter == '용존산소', onTap: () {
                            setState(() {
                              selectedParameter = '용존산소';
                            });
                          }),
                          // 오른쪽 간단한 현재값 박스
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${spots.last.y.toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Expanded(
                        child: LineChart(
                          chartData,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 옵션: ExpansionTiles
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.thermostat),
                      title: const Text('파라미터 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        _buildSelectableTile('수온'),
                        _buildSelectableTile('수질'),
                        _buildSelectableTile('용존산소'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.timeline),
                      title: const Text('범위 / 단위', style: TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        _buildRangeTile('1시간 단위'),
                        _buildRangeTile('일주일 단위'),
                        _buildRangeTile('한달 단위'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 여기에 추가 컨트롤이나 통계요약 카드 넣어도 됨
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // 예: CSV export or request historical
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('내보내기'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 실시간 모드 토글
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('실시간 보기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildToggleLabel(String label, bool active, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSelectableTile(String label) {
    final selected = selectedParameter == label;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.blue) : const Icon(Icons.circle_outlined),
      onTap: () => setState(() => selectedParameter = label),
    );
  }

  Widget _buildRangeTile(String label) {
    final selected = selectedRange == label;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.blue) : const Icon(Icons.circle_outlined),
      onTap: () => setState(() => selectedRange = label),
    );
  }
}

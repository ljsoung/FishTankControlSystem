import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────────────
/// SensorDetailScreen
/// - 좌우 드래그로 과거/현재 탐색
/// - 왼쪽 끝 도달 시 10포인트씩 과거 데이터 추가 로딩
/// - 파라미터/범위 전환 시 서버 재요청 후 차트 리빌드
/// ─────────────────────────────────────────────────────────────────────────
class SensorDetailScreen extends StatefulWidget {
  final String token;
  const SensorDetailScreen({super.key, required this.token});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  // ── Range 옵션: 라벨, API코드, 기본 뷰윈도 사이즈
  static const _rangeOptions = [
    ('1시간 단위', '1h', 5),
    ('하루 단위', '1d', 5),
    ('일주일 단위', '1w', 5),
  ];

  // === 선택 상태 ===
  String selectedParameter = '수온'; // '수온'/'수질'/'용존산소'
  String selectedRangeCode = '1h'; // '1시간 단위: 1h'/'하루 단위: 1d'/'일주일 단위: 1w'

  // === 서버 설정 ===
  // final String _base = 'https://jwejweiya.shop';
  final String _base = 'http://192.168.34.17:8080';
  int count = 10; // 서버에서 가져온 포인트 수(최초 10)
  bool _isLoading = false;

  // === 원본 데이터 저장 ===
  List<String> _labels = [];    // index 0 = 가장 과거
  List<double> _values = [];

  // === 뷰포트(창) 설정 ===
  // 화면에 보이는 구간 길이(포인트 단위). 범위에 따라 기본값 다르게.
  int _viewWindow = 5;
  // 현재 창의 시작 인덱스(0.._values.length - _viewWindow)
  int _viewStart = 0;

  // === 드래그-픽셀 변환 보정 ===
  // 한 포인트를 화면에서 몇 픽셀로 볼지(= 차트 width / _viewWindow)
  double _pxPerPoint = 20;

  @override
  void initState() {
    super.initState();
    _fetchAndBuild(reset: true); // 최초 로드
  }

  // 코드 기준으로 뷰윈도 조정
  void _syncViewWindowWithRange() {
    final opt = _rangeOptions.firstWhere((o) => o.$2 == selectedRangeCode);
    _viewWindow = opt.$3;
  }

  // 파라미터 → 서버 키 매핑
  String get _paramKey {
    if (selectedParameter == '수온') return 'temperatureData';
    if (selectedParameter == '수질') return 'phData';
    return 'doData'; // 용존산소
  }

  // range → 서버 쿼리 문자열 (코드 그대로)
  String get _rangeQuery => selectedRangeCode;

  Future<void> _fetchAndBuild({required bool reset}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (reset) count = 10;

      final uri = Uri.parse(
        '$_base/api/sensor/data?range=${Uri.encodeComponent(_rangeQuery)}&count=$count',
      );

      final res = await http.get(uri,
        headers: {
          'Accept': 'application/json',
          if (widget.token.isNotEmpty) 'Authorization': 'Bearer ${widget.token}',
          // "Authorization": "Bearer ${widget.token}",
          // "Content-Type": "application/json"
        }
      );
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null || data[_paramKey] == null) {
        throw Exception('서버 응답 포맷 오류: $_paramKey 없음');
      }

      final List<dynamic> arr = data[_paramKey] as List<dynamic>;
      final labels = <String>[];
      final values = <double>[];

      for (final item in arr) {
        final timeStr = (item['time'] ?? '').toString();
        final valStr = (item['value'] ?? '').toString();
        final val = double.tryParse(valStr);
        if (val != null) {
          labels.add(timeStr);
          values.add(val);
        }
      }

      if (reset) {
        _labels = labels;
        _values = values;
        _viewStart = max(0, _values.length - _viewWindow);
      } else {
        // 이전에 불러온 것보다 더 많이 불러온 상태이므로 전체를 교체
        final oldLen = _values.length;
        _labels = labels;
        _values = values;
        final added = _values.length - oldLen;
        _viewStart += added;    // 현재 화면 위치 유지
        _viewStart = _clampViewStart(_viewStart);
      }
    } catch (e) {
      // 간단 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _clampViewStart(int v) {
    if (_values.isEmpty) return 0;
    final maxStart = max(0, _values.length - _viewWindow);
    return v.clamp(0, maxStart);
  }

  // 왼쪽 끝 도달 시 더 과거 데이터 10포인트 추가 로드
  Future<void> _maybeLoadMoreOlder() async {
    if (_isLoading) return;
    // 이미 제일 왼쪽인데 더 왼쪽으로 가려 한다면
    if (_viewStart <= 0) {
      // 1년 제한은 서버에서 판단/절단한다고 가정. 필요 시 여기서도 가드 가능.
      count += 10;
      await _fetchAndBuild(reset: false);
    }
  }

  // 드래그 처리: 화면 픽셀 → 데이터 포인트 이동량 변환
  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    if (_values.isEmpty) return;
    final dx = d.delta.dx; // 왼쪽으로 밀면 음수
    final deltaPoints = -(dx / _pxPerPoint);
    int nextStart = _viewStart + deltaPoints.round();
    nextStart = _clampViewStart(nextStart);
    setState(() => _viewStart = nextStart);

    // 만약 "실제로 더 왼쪽으로 가려 했다"가 감지되면 추가 로드 시도
    if (dx < 0 && _viewStart == 0) {
      _maybeLoadMoreOlder();
    }
  }

  // 차트에 넣을 현재 뷰포트 스팟 구성
  List<FlSpot> _viewportSpots() {
    final spots = <FlSpot>[];
    if (_values.isEmpty) return spots;

    final end = min(_values.length, _viewStart + _viewWindow);
    for (int i = _viewStart; i < end; i++) {
      // x는 전역 인덱스 i를 그대로 쓰되, 차트 minX/maxX에 맞춰 상대좌표로 보이게 처리
      final localX = (i - _viewStart).toDouble();
      spots.add(FlSpot(localX, _values[i]));
    }
    return spots;
  }

  // 뷰포트에 맞춘 라벨 함수
  String _labelForLocalX(int localX) {
    final idx = _viewStart + localX;
    if (idx < 0 || idx >= _labels.length) return '';
    return _labels[idx];
  }

  LineChartData _makeLineChartData(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return LineChartData(
        minX: 0, maxX: 1, minY: 0, maxY: 1,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    final ys = spots.map((s) => s.y).toList();
    final minYv = ys.reduce(min);
    final maxYv = ys.reduce(max);
    final yMargin = max(0.0001, (maxYv - minYv) * 0.15);

    return LineChartData(
      minX: 0,
      maxX: max(1, _viewWindow - 1).toDouble(),
      minY: minYv - yMargin,
      maxY: maxYv + yMargin,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: ((maxYv - minYv) / 4).abs() > 0 ? ((maxYv - minYv) / 4) : 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.white24, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: ((maxYv - minYv) / 4).abs() > 0 ? ((maxYv - minYv) / 4) : 1,
            getTitlesWidget: (val, meta) {
              return Text(val.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white70, fontSize: 12));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // 4~6개 정도만 찍히도록
            interval: max(1, (_viewWindow / 5).floor()).toDouble(),
            getTitlesWidget: (val, meta) {
              final local = val.round();
              final lbl = _labelForLocalX(local);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(lbl, style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: selectedParameter == '수온'
              ? Colors.yellowAccent
              : (selectedParameter == '수질' ? Colors.tealAccent : Colors.cyanAccent),
          barWidth: 3,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                (selectedParameter == '수온'
                    ? Colors.yellowAccent
                    : (selectedParameter == '수질' ? Colors.tealAccent : Colors.cyanAccent))
                    .withOpacity(0.35),
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
          getTooltipColor: (t) => Colors.black87,
          getTooltipItems: (touched) {
            return touched
                .map((t) => LineTooltipItem(
                    '${t.y}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ))
                .toList();
          },
        ),
      ),
    );
  }

  // 파라미터/범위 변경 시 서버 재요청
  Future<void> _onChangeParameter(String label) async {
    if (selectedParameter == label) return;
    setState(() => selectedParameter = label);
    await _fetchAndBuild(reset: true);
  }

  Future<void> _onChangeRange(String code) async {
    if (selectedRangeCode == code) return;
    setState(() {
      selectedRangeCode = code;
      _syncViewWindowWithRange();
    });
    await _fetchAndBuild(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final spots = _viewportSpots();
    final currentValue = _values.isNotEmpty ? _values.last : null;

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
                      // 상단 토글 + 현재값
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildToggleLabel('수온', selectedParameter == '수온',
                              onTap: () => _onChangeParameter('수온')),
                          _buildToggleLabel('수질', selectedParameter == '수질',
                              onTap: () => _onChangeParameter('수질')),
                          _buildToggleLabel('용존산소', selectedParameter == '용존산소',
                              onTap: () => _onChangeParameter('용존산소')),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currentValue != null ? currentValue.toStringAsFixed(1) : '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 차트 + 드래그 처리
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // 현재 화면 너비에 맞춰 포인트 당 픽셀 계산
                            _pxPerPoint =
                                max(8.0, constraints.maxWidth / max(1, _viewWindow).toDouble());

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragUpdate: _onHorizontalDragUpdate,
                              child: LineChart(
                                _makeLineChartData(spots),
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              ),
                            );
                          },
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(minHeight: 2),
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
                        for (final o in _rangeOptions)
                          _buildRangeTile(o.$1, o.$2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  // ─────────────────── UI helpers ───────────────────

  Widget _buildToggleLabel(String label, bool active, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(color: active ? Colors.black : Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSelectableTile(String label) {
    final selected = selectedParameter == label;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.blue) : const Icon(Icons.circle_outlined),
      onTap: () => _onChangeParameter(label),
    );
  }

  Widget _buildRangeTile(String label, String code) {
    final selected = selectedRangeCode == code;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check_circle, color: Colors.blue) : const Icon(Icons.circle_outlined),
      onTap: () => _onChangeRange(code),
    );
  }
}

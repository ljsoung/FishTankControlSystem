import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // 타이머용
import '../fish/select_fish_species.dart';
import '../datagraph/sensor_detail_screen.dart';
import '../fish/feed_time_picker.dart';
import '../../widgets/animated_fish.dart';
import '../../utils/network_config.dart';
import '../../utils/feed_timer_manager.dart';


class MainFishTankScreen extends StatefulWidget {
  final String token;
  const MainFishTankScreen({super.key, required this.token});

  @override
  State<MainFishTankScreen> createState() => _MainFishTankScreenState();
}

class _MainFishTankScreenState extends State<MainFishTankScreen> {
  double? temperature;
  double? doValue;
  double? phValue;
  bool isLoading = true;

  Duration? remainingTime; // ⏳ 남은 시간
  Timer? timer; // ⏱ 카운트다운용 타이머
  String? feedTimeText; // 선택된 배식 시간 텍스트

  late FeedTimerManager feedTimer;

  // ✅ 이상 감지 여부 저장용
  bool tempAlert = false;
  bool doAlert = false;
  bool phAlert = false;

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    feedTimer = FeedTimerManager(
      context: context,
      onTimeUpdate: () {
        setState(() {
          feedTimeText = feedTimer.formatDuration(feedTimer.remainingTime!);
        });
      },
    );
  }

  @override
  void dispose() {
    feedTimer.dispose();
    super.dispose();
  }

  Future<void> fetchSensorData() async {

    try {
      final response = await http.get(
        Uri.parse("http://192.168.34.17:8080/api/sensor/main"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data["status"];
        final sensor = data["data"]; // ✅ 공통으로 센서 데이터 참조

        // ✅ 센서값 기본 세팅 (어종 없어도 표시)
        if (sensor != null) {
          setState(() {
            temperature = (sensor["temperature"]["value"] ?? 0).toDouble();
            doValue = (sensor["dissolvedOxygen"]["value"] ?? 0).toDouble();
            phValue = (sensor["tds"]["value"] ?? 0).toDouble();
          });
        }

        if (status == "OK" || status == "WARNING") {
          final abnormalItems = List<String>.from(data["abnormalItems"] ?? []);

          setState(() {
            tempAlert = abnormalItems.contains("temperature");
            doAlert = abnormalItems.contains("dissolvedOxygen");
            phAlert = abnormalItems.contains("tds");
            isLoading = false;
          });

          print("✅ 센서 데이터 로드 완료 (상태: $status)");
        }
        else if (status == "NO_FISH_TYPE") {
          final msg = data["message"] ?? "어종 정보가 없습니다. 먼저 어종을 등록해주세요.";
          print("🐠 어종 정보 없음: $msg");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.blueAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );

          // ✅ 어종이 없어도 센서 데이터는 표시
          setState(() => isLoading = false);
        }
        else if (status == "NO_SENSOR_DATA") {
          final msg = data["message"] ?? "센서 데이터가 존재하지 않습니다.";
          print("⚠️ 센서 데이터 없음: $msg");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.orangeAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );

          // 디바이스 자동 등록 로직
          final deviceResponse = await http.post(
            Uri.parse("http://192.168.34.17:8080/api/device/register"),
            headers: {
              "Authorization": "Bearer ${widget.token}",
              "Content-Type": "application/json",
            },
          );

          if (deviceResponse.statusCode == 200) {
            final deviceData = jsonDecode(deviceResponse.body);
            final sensorToken = deviceData["sensorToken"];

            print("센서 디바이스 등록 완료: $sensorToken");

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ 센서 디바이스 자동 등록 완료"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );

            setState(() => isLoading = true);
            await Future.delayed(const Duration(seconds: 2));
            await fetchSensorData();
          }
        }
        else {
          print("⚠️ 알 수 없는 상태 코드: $status");
          setState(() => isLoading = false);
        }
      } else {
        print("서버 응답 오류: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("API 요청 오류: $e");
      setState(() => isLoading = false);
    }

  }


  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery
        .of(context)
        .size
        .width;
    final sh = MediaQuery
        .of(context)
        .size
        .height;
    final base = sw < sh ? sw : sh;
    final fishWidth = (base * 0.80).clamp(120.0, 280.0);
    final fishHeight = fishWidth * 0.75;
    final horizontalPadding = (sw * 0.03).clamp(8.0, 24.0);
    final verticalPadding = (sh * 0.012).clamp(6.0, 16.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00BCD4),
                Color(0xFF2196F3),
                Color(0xFF006064),
              ],
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 상단 수질 데이터
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  children: [
                    // 🔹 기존 수질 데이터 Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: _buildDataBox(
                              "DO: ${doValue?.toStringAsFixed(2) ?? '--'}",
                              isAlert: doAlert,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: _buildDataBox(
                              "TDS: ${phValue?.toStringAsFixed(2) ?? '--'}",
                              isAlert: phAlert,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: _buildDataBox(
                              "${temperature?.toStringAsFixed(2) ?? '--'}°C",
                              isAlert: tempAlert,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 🔹 수질 데이터 아래에 "사료 배식 시간" 표시
                    if (feedTimeText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '사료 배식 시간: $feedTimeText',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 중앙 물고기 영역
              Expanded(
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: fishWidth,
                          height: fishHeight,
                          child: Image.asset(
                            'assets/pin_fish.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.17, -1.3),
                        child: SizedBox(
                          width: 70,
                          height: 40,
                          child: Image.asset(
                            'assets/doolifish.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.1, -1.3),
                        child: SizedBox(
                          width: 70,
                          height: 40,
                          child: Image.asset(
                            'assets/hyung.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      AnimatedFish(
                        asset: 'assets/fish.gif',
                        alignment: const Alignment(0.3, -1),
                        size: 150,
                        duration: const Duration(seconds: 7),
                        flipHorizontally: true,
                      ),
                      AnimatedFish(
                        asset: 'assets/small_fish.gif',
                        alignment: const Alignment(-0.7, -0.5),
                        size: 150,
                        duration: const Duration(seconds: 4),
                      ),
                      AnimatedFish(
                        asset: 'assets/pattern_fish.gif',
                        alignment: const Alignment(0.85, -0.6),
                        size: 150,
                        duration: const Duration(seconds: 5),
                        flipHorizontally: true,
                      ),
                      AnimatedFish(
                        asset: 'assets/jellyfish.gif',
                        alignment: const Alignment(0.7, 0.5),
                        size: 150,
                        duration: const Duration(seconds: 6),
                        flipHorizontally: true,
                      ),
                      AnimatedFish(
                        asset: 'assets/puffer_fish.gif',
                        alignment: const Alignment(-0.6, 0.8),
                        size: 180,
                        duration: const Duration(seconds: 5),
                        flipHorizontally: true,
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: SizedBox(
                  height: 130,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    childAspectRatio: 3.8,
                    children: [
                      _buildMenuButton("꾸미기", Icons.brush),
                      _buildMenuButton("어종 선택", Icons.pets),
                      _buildMenuButton("센서 데이터", Icons.sensors),
                      _buildMenuButton("사료 배식 시간", Icons.alarm),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 데이터 박스 (이상일 경우 배경색 변경)
  Widget _buildDataBox(String label, {bool isAlert = false}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAlert ? Colors.redAccent.withOpacity(0.85) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlert ? Colors.red : Colors.black38,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }


  // 🔹 하단 버튼
  Widget _buildMenuButton(String label, IconData icon) {
    return ElevatedButton.icon(
      // ✅ onPressed 콜백을 async로 선언
      onPressed: () async {
        if (label == "어종 선택") {
          showFishSelectionSheet(context);
        } else if (label == "센서 데이터") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SensorDetailScreen(),
            ),
          );
        } else if (label == "사료 배식 시간") {
          final selected = await showFeedTimePicker(context);
          if (selected != null) {
            // ✅ feed_time_picker.dart에서 “X시간 X분 후” 문자열을 받아서 Duration으로 변환
            final match = RegExp(r'(\d+)시간 (\d+)분').firstMatch(selected);
            if (match != null) {
              final hours = int.parse(match.group(1)!);
              final minutes = int.parse(match.group(2)!);
              feedTimer.startCountdown(Duration(hours: hours, minutes: minutes));
            }
          }
        }
      },

      icon: Icon(icon, size: 20),
      label: Text(label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black26),
        ),
      ),
    );
  }
}



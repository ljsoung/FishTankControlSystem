import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widgets/animated_fish.dart';

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

  @override
  void initState() {
    super.initState();
    fetchSensorData(); // 화면 시작 시 API 호출
  }

  Future<void> fetchSensorData() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/sensor/main"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      // ✅ HTTP 상태 코드 확인
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ 서버 status 확인
        final status = data["status"];

        if (status == "OK") {
          final sensor = data["data"];
          setState(() {
            temperature = sensor["temperature"]["value"]?.toDouble();
            doValue = sensor["dissolvedOxygen"]["value"]?.toDouble();
            phValue = sensor["tds"]["value"]?.toDouble();
            isLoading = false;
          });
        } else if (status == "NO_SENSOR_DATA") { //  센서 데이터가 없는 경우
          print("센서 데이터 없음: ${data["message"]}");
          /* 센서가 서버에 최초 센서 데이터 값을 input할 수 있게 센서에게
           * 요청하는 로직 작성해야 함
           */
          setState(() => isLoading = false);
        } else if (status == "NO_FISH_TYPE") { // 어종이 등록되지 않은 경우
          print("어종 정보 없음: ${data["message"]}");
          setState(() => isLoading = false);
        } else {
          print("알 수 없는 상태: $status");
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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final base = sw < sh ? sw : sh;
    final fishWidth = (base * 0.65).clamp(120.0, 280.0);
    final fishHeight = fishWidth * 0.6;
    final horizontalPadding = (sw * 0.03).clamp(8.0, 24.0);
    final verticalPadding = (sh * 0.012).clamp(6.0, 16.0);

    return Scaffold(
      body: SafeArea(
        child: Container(
          // ✅ 배경: 그라데이션 효과 적용
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
              ? const Center(child: CircularProgressIndicator()) // ✅ 로딩 중
              : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 상단 수질 데이터
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: verticalPadding, horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: _buildDataBox(
                            "DO: ${doValue?.toStringAsFixed(2) ?? '--'}")),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                        child: _buildDataBox(
                            "TDS: ${phValue?.toStringAsFixed(2) ?? '--'}")),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                        child: _buildDataBox(
                            "${temperature?.toStringAsFixed(2) ?? '--'}°C")),
                  ],
                ),
              ),

              // 중앙 이미지
              Expanded(
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      // 중앙 물고기 (화면비율 대비 크기 설정)
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

                      // 좌상 (왼쪽 위 대각)
                      AnimatedFish(
                        asset: 'assets/small_fish.gif',
                        alignment: const Alignment(-0.7, -0.6),
                        size: 150,
                        duration: const Duration(seconds: 4),
                        flipHorizontally: false,
                      ),

                      // 우상 (오른쪽 위 대각)
                      AnimatedFish(
                        asset: 'assets/pattern_fish.gif',
                        alignment: const Alignment(0.7, -0.6),
                        size: 150,
                        duration: const Duration(seconds: 5),
                        flipHorizontally: true,
                      ),

                      // 좌하 (왼쪽 아래 대각)
                      AnimatedFish(
                        asset: 'assets/jellyfish.gif',
                        alignment: const Alignment(-0.7, 0.6),
                        size: 120,
                        duration: const Duration(seconds: 6),
                        flipHorizontally: false,
                      ),

                      // 우하 (오른쪽 아래 대각)
                      AnimatedFish(
                        asset: 'assets/puffer_fish.gif',
                        alignment: const Alignment(0.7, 0.6),
                        size: 180,
                        duration: const Duration(seconds: 5),
                        flipHorizontally: false,
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

  // 🔹 상단 데이터 박스 위젯
  Widget _buildDataBox(String label) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black38, width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // 🔹 하단 버튼 위젯
  Widget _buildMenuButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: 페이지 이동 기능 추가 가능
      },
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
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

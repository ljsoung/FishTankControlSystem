import 'package:flutter/material.dart';
import '../../widgets/animated_fish.dart';

class MainFishTankScreen extends StatelessWidget {
  const MainFishTankScreen({super.key});

  // 메인 화면 UI
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final base = sw < sh ? sw : sh; // 화면의 짧은 쪽을 기준으로
    final fishWidth = (base * 0.65).clamp(120.0, 280.0); // 너비: 기준의 65%, 최소120 최대280
    final fishHeight = fishWidth * 0.6; // 종횡비 유지
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
                Color(0xFF00BCD4), // 청록색
                Color(0xFF2196F3), // 밝은 파랑
                Color(0xFF006064), // 어두운 민트 블루
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ 상단 수질 데이터
              Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [ // 추후 센서 데이터와 연동시 고정값 변경
                    Expanded(child: _buildDataBox("DO: 100")),
                    SizedBox(width: sw * 0.02),
                    Expanded(child: _buildDataBox("TDS: 250")),
                    SizedBox(width: sw * 0.02),
                    Expanded(child: _buildDataBox("23°C")),
                  ],
                ),
              ),

              // 중앙 이미지 부분
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


              //하단 메뉴 버튼 3개
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: SizedBox(
                  height: 130, // 버튼 2줄을 보여줄 충분한 높이 확보
                  child: GridView.count(
                    crossAxisCount: 2, //한 줄에 2개씩
                    mainAxisSpacing: 10, // 세로 간격
                    crossAxisSpacing: 10, // 가로 간격
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    childAspectRatio: 3.8, //버튼 비율 (가로 : 세로) - 화면에 맞춰 조절 가능
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
        fit: BoxFit.scaleDown, // 텍스트가 박스보다 커지면 자동 축소
        child: Text(
          label,
          textAlign: TextAlign.center, // 여러 줄일 때 중앙 정렬
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
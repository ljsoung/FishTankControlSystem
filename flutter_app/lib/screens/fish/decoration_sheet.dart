import 'package:flutter/material.dart';

class DecorationSheet extends StatelessWidget {
  const DecorationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // 처음 높이 (60%)
      minChildSize: 0.4,     // 최소 높이
      maxChildSize: 0.95,    // 최대 확장 높이
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                "물고기 꾸미기 🎨",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "내 물고기를 꾸밀 수 있는 다양한 옵션을 선택해보세요!\n(호감도에 따라 사용할 수 있는 아이템이 다릅니다!)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _buildDecorationOption("assets/decoration_image/은색왕관.png", "은색 왕관 (호감도 100)"),
              _buildDecorationOption("assets/plant.png", "산호 배치하기"),
              _buildDecorationOption("assets/plant.png", "조명 색상 변경"),
              _buildDecorationOption("assets/plant.png", "바닥 모래 색상 변경"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorationOption(String imagePath, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          // TODO: 꾸미기 기능 동작 추가
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            // 🖼️ 아이콘 대신 이미지 표시
            Container(
              width: 45,
              height: 45,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

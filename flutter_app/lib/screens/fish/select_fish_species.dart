import 'package:flutter/material.dart';

// 어종 선택 모달을 띄우는 함수
void showFishSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white.withOpacity(0.95),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        builder: (_, scrollController) {
          final List<Map<String, String>> fishList = [
            {"name": "구피", "asset": "assets/fish_species/구피.png"},
            {"name": "복어", "asset": "assets/fish_species/복어.png"},
            {"name": "그린테러", "asset": "assets/fish_species/그린테러.png"},
            {"name": "글라스 캣피쉬", "asset": "assets/fish_species/글라스 캣피쉬.png"},
            {"name": "코리도라스", "asset": "assets/fish_species/코리도라스.png"},
            {"name": "엔젤피쉬", "asset": "assets/fish_species/엔젤피쉬.png"},
          ];

          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "🐟 어종 선택",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: fishList
                        .map((fish) => _buildFishChoiceButton(
                      context,
                      fish["name"]!,
                      fish["asset"]!,
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// 어종 버튼 위젯
Widget _buildFishChoiceButton(BuildContext context, String name, String assetPath) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name 선택됨 🐠"),
          duration: const Duration(seconds: 2),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, height: 60, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

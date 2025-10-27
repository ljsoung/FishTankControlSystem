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
            {"name": "테트라", "asset": "assets/fish_species/테트라.png"},
            {"name": "금붕어", "asset": "assets/fish_species/금붕어.png"},
            {"name": "네온 테트라", "asset": "assets/fish_species/네온 테트라.png"},
            {"name": "비단잉어", "asset": "assets/fish_species/비단잉어.png"},
            {"name": "바브", "asset": "assets/fish_species/바브.png"},
            {"name": "데마소니", "asset": "assets/fish_species/데마소니.png"},
            {"name": "구라미", "asset": "assets/fish_species/구라미.png"},
            {"name": "레인보우", "asset": "assets/fish_species/레인보우.png"},
            {"name": "디스커스", "asset": "assets/fish_species/디스커스.png"},
            {"name": "라미레지", "asset": "assets/fish_species/라미레지.png"},
            {"name": "라스보라", "asset": "assets/fish_species/라스보라.png"},
            {"name": "상어", "asset": "assets/fish_species/상어.png"},
            {"name": "범블비 고비", "asset": "assets/fish_species/범블비 고비.png"},
            {"name": "베타", "asset": "assets/fish_species/베타.png"},
            {"name": "볼리비안 램", "asset": "assets/fish_species/볼리비안 램.png"},
            {"name": "코리도라스", "asset": "assets/fish_species/코리도라스.png"},
            {"name": "플레이코", "asset": "assets/fish_species/플레이코.png"},
            {"name": "블랙 몰리", "asset": "assets/fish_species/블랙 몰리.png"},
            {"name": "블랙 무어", "asset": "assets/fish_species/블랙 무어.png"},
            {"name": "사이아미즈 알지이터", "asset": "assets/fish_species/사이아미즈 알지이터.png"},
            {"name": "세베룸", "asset": "assets/fish_species/세베룸.png"},
            {"name": "세일핀 몰리", "asset": "assets/fish_species/세일핀 몰리.png"},
            {"name": "소드테일", "asset": "assets/fish_species/소드테일.png"},
            {"name": "실버 달러", "asset": "assets/fish_species/실버 달러.png"},
            {"name": "아피스토그램마 보렐리", "asset": "assets/fish_species/아피스토그램마 보렐리.png"},
            {"name": "아피스토그램마 카카투오이데스", "asset": "assets/fish_species/아피스토그램마 카카투오이데스.png"},
            {"name": "알텀 엔젤", "asset": "assets/fish_species/알텀 엔젤.png"},
            {"name": "엔젤피쉬", "asset": "assets/fish_species/엔젤피쉬.png"},
            {"name": "옐로우 랩", "asset": "assets/fish_species/옐로우 랩.png"},
            {"name": "오셀라리스 클라운피쉬", "asset": "assets/fish_species/오셀라리스 클라운피쉬.png"},
            {"name": "오스카", "asset": "assets/fish_species/오스카.png"},
            {"name": "오토싱클루스", "asset": "assets/fish_species/오토싱클루스.png"},
            {"name": "일렉트릭 블루 아카라", "asset": "assets/fish_species/일렉트릭 블루 아카라.png"},
            {"name": "자이언트 베타", "asset": "assets/fish_species/자이언트 베타.png"},
            {"name": "잭댐프시", "asset": "assets/fish_species/잭댐프시.png"},
            {"name": "다니오", "asset": "assets/fish_species/제브라 다니오.png"},
            {"name": "로치", "asset": "assets/fish_species/로치.png"},
            {"name": "차이니즈 알지이터", "asset": "assets/fish_species/차이니즈 알지이터.png"},
            {"name": "카디날 테트라", "asset": "assets/fish_species/카디날 테트라.png"},
            {"name": "크리벤시스", "asset": "assets/fish_species/크리벤시스.png"},
            {"name": "파이어마우스", "asset": "assets/fish_species/파이어마우스.png"},
            {"name": "프론토사", "asset": "assets/fish_species/프론토사.png"},
            {"name": "플래티", "asset": "assets/fish_species/플래티.png"},
            {"name": "피콕 시클리드", "asset": "assets/fish_species/피콕 시클리드.png"},
            {"name": "해쳇피쉬", "asset": "assets/fish_species/해쳇피쉬.png"},
            {"name": "화이트 클라우드", "asset": "assets/fish_species/화이트 클라우드.png"},


          ];

          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 3.4,
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
                  const SizedBox(height: 1),
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

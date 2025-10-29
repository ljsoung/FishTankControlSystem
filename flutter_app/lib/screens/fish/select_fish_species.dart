import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 어종 선택 모달을 띄우는 함수
void showFishSelectionSheet(BuildContext context, String token) {
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
            {"name": "금붕어", "asset": "assets/fish_species/금붕어.png"},
            {"name": "네온 테트라", "asset": "assets/fish_species/네온 테트라.png"},
            {"name": "비단잉어", "asset": "assets/fish_species/비단잉어.png"},
            {"name": "플래티", "asset": "assets/fish_species/플래티.png"},
            {"name": "엔젤피쉬", "asset": "assets/fish_species/엔젤피쉬.png"},
          ];

          String query = "";

          return StatefulBuilder(
            builder: (context, setState) {
              final filteredList = fishList
                  .where((fish) => fish["name"]!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
                  .toList();

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

                      // 🔍 검색창
                      TextField(
                        decoration: InputDecoration(
                          hintText: "어종을 입력하세요.",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // 🐠 어종 리스트
                      GridView.count(
                        crossAxisCount: 1,
                        childAspectRatio: 3.4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: filteredList
                            .map((fish) => _buildFishChoiceButton(
                          context,
                          fish["name"]!,
                          fish["asset"]!,
                          token, // ✅ JWT 토큰 전달
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
    },
  );
}

// ✅ 어종 버튼 클릭 시 서버에 등록 요청
Widget _buildFishChoiceButton(
    BuildContext context, String name, String assetPath, String token) {
  return GestureDetector(
    onTap: () async {
      Navigator.pop(context);

      final url =
          "http://192.168.34.17:8080/api/fish/select?fishType=$name"; // ✅ @RequestParam

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final msg = data["message"] ?? "$name 어종 등록 완료 🎉";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          print("✅ 어종 등록 완료: $msg");
        } else {
          print("⚠️ 서버 응답 코드: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("서버 오류: 어종 등록 실패 😢"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        print("🚨 네트워크 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("네트워크 오류 😭"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
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

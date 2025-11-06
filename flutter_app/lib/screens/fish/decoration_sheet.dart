import 'package:flutter/material.dart';

class DecorationSheet extends StatefulWidget {
  final Function(String?) onDecorationSelected;
  final String? currentDecoration; // ✅ 현재 선택된 꾸미기 경로를 전달받음

  const DecorationSheet({
    super.key,
    required this.onDecorationSelected,
    this.currentDecoration,
  });

  @override
  State<DecorationSheet> createState() => _DecorationSheetState();
}

class _DecorationSheetState extends State<DecorationSheet> {
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    // ✅ 부모에서 받은 현재 선택된 꾸미기 상태 반영
    selectedItem = widget.currentDecoration;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
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
              const Text("물고기 꾸미기 🎨",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDecorationOption("assets/decoration_image/은색왕관.png", "은색 왕관 (호감도 100)"),
              _buildDecorationOption("assets/decoration_image/금색왕관.png", "금색 왕관 (호감도 200)"),
              _buildDecorationOption("assets/decoration_image/경고표시줄.png", "경고표시줄 (호감도 300)"),
              _buildDecorationOption("assets/decoration_image/악마뿔2.png", "악마뿔 (호감도 400)"),
              _buildDecorationOption("assets/decoration_image/천사링.png", "천사링 (호감도 500)"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorationOption(String imagePath, String label) {
    final isSelected = selectedItem == imagePath;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            // ✅ 선택된 이미지가 다시 클릭되면 해제
            if (selectedItem == imagePath) {
              selectedItem = null;
            } else {
              selectedItem = imagePath;
            }
          });
          widget.onDecorationSelected(selectedItem);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.amber[700] : const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
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
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gardians/screens/pairing.dart';
// 1. استيراد الموديلات والـ Utils
import '../models/child.dart';
import '../utils/shared_prefs_utils.dart';
import '../utils/constants.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);
  int selectedAge = 6;

  // 2. إضافة Controller للاسم
  final TextEditingController _nameController = TextEditingController();

  // 3. ميثود الحفظ (Logic)
  void _handleGenerateCode() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your child's name")),
      );
      return;
    }

    // إنشاء الـ Child Object (حالياً بنجهزه للانتقال، ومستقبلاً هيتبعت للـ Service)
    final newChild = Child(
      name: _nameController.text.trim(),
      email:
          "${_nameController.text.trim().replaceAll(' ', '').toLowerCase()}@safeguard.com", // إيميل افتراضي للطفل
    );

    // الانتقال لصفحة الكود
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PairingCodeScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose(); // تنظيف الـ Controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Your Child",
          style: TextStyle(color: navyBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF9ED7EB),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Face Section (نفس الـ UI بتاعك)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: skyBlue.withOpacity(0.3),
                  child: Icon(Icons.person, size: 80, color: skyBlue),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: skyBlue,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Add Photo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyBlue,
              ),
            ),
            Text(
              "Let's give them a profile face",
              style: TextStyle(color: navyBlue.withOpacity(0.5), fontSize: 14),
            ),

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Child's Name",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 4. ربط الـ TextField بالـ Controller
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter name",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: navyBlue.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Horizontal Age Picker (نفس الـ UI بتاعك)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Child's Age",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navyBlue,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 15,
                itemBuilder: (context, index) {
                  int age = index + 2;
                  bool isSelected = age == selectedAge;
                  return GestureDetector(
                    onTap: () => setState(() => selectedAge = age),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? navyBlue : skyBlue.withAlpha(100),
                          width: isSelected ? 3 : 1.5,
                        ),
                        color: isSelected
                            ? skyBlue.withAlpha(40)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "$age",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? navyBlue
                                : navyBlue.withAlpha(120),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 60),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // 5. ربط الزرار بالميثود الجديدة
                onPressed: _handleGenerateCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Generate Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

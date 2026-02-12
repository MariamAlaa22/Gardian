import 'package:flutter/material.dart';
import 'models/child.dart';
import 'utils/background_generator.dart';
import 'utils/date_utils.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. تجربة الـ Model: عمل بيانات طفل وهمية
    Child mockChild = Child(
      name: "Abdelrahman Ahmed",
      email: "child@kidsafe.com",
      parentEmail: "parent@kidsafe.com",
    );

    // 2. تجربة الـ DateUtils: تنسيق وقت حالي
    String formattedTime = DateUtilsCustom.getFormattedDate(
      DateUtilsCustom.getCurrentDateString()
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Backend Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // تجربة الـ BackgroundGenerator: عمل Avatar ملون عشوائي واختصار الاسم
            CircleAvatar(
              radius: 50,
              backgroundColor: BackgroundGenerator.getRandomColor(),
              child: Text(
                BackgroundGenerator.getFirstCharacters(mockChild.name!),
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            
            // عرض بيانات من الـ Model
            Text("Child Name: ${mockChild.name}", 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Email: ${mockChild.email}"),
            const SizedBox(height: 10),
            
            // عرض الوقت المنسق من الـ DateUtils
            Text("Last Update: $formattedTime", 
                 style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // تجربة الـ SharedPreferences: حفظ رسالة بسيطة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Backend is Working!")),
                );
              },
              child: const Text("Check System Status"),
            )
          ],
        ),
      ),
    );
  }
}
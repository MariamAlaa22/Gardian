import 'package:flutter/material.dart';
import 'package:gardians/screens/parent.dart'; // تأكدي من المسار الصح

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4; // عدد الصفحات الكلي

  final Color navyBlue = const Color(0xFF042459);
  final Color skyBlue = const Color(0xFF9ED7EB);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) => setState(() => _currentPage = value),
              children: [
                buildPageContent("assets/images/loc.png", "Tracking", "Know their place exactly at any time"),
                buildPageContent("assets/images/time.png", "Control", "Set daily limits and manage screen time"),
                buildPageContent("assets/images/onboarding3.png", "Monitor", "Protect your child from digital world threats"),
                buildPageContent("assets/images/fam.png", "Safety", "Ensuring a happy and safe family environment"),
              ],
            ),
          ),

          // Indicators (Dots)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) => buildDot(index)),
          ),

          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.only(bottom: 50, left: 30, right: 30),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              // هيفحص لو وصلنا لآخر صفحة (رقم 3)
              child: _currentPage == _totalPages - 1
                  ? _buildGetStartedButton()
                  : _buildNextCircleButton(),
            ),
          ),
        ],
      ),
    );
  }

  // زرار الـ Get Started اللي بيظهر في الآخر
  Widget _buildGetStartedButton() {
    return SizedBox(
      key: const ValueKey("getStarted"),
      width: 266,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        onPressed: () {
          // هنا بنوجهه لصفحة الاختيار (الـ Role Screen) اللي عملناها
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Parent())); 
        },
        child: const Text(
          "Get Started",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // زرار الدائرة اللي بيلف مع الـ Progress
  Widget _buildNextCircleButton() {
    return GestureDetector(
      key: const ValueKey("nextButton"),
      onTap: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 85,
            height: 85,
            child: TweenAnimationBuilder<double>(
              // الـ Progress بيبدأ من 0.25 (أول صفحة) لحد 0.75 (قبل الأخيرة)
              tween: Tween<double>(begin: 0, end: (_currentPage + 1) / _totalPages),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) => CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(navyBlue),
                backgroundColor: skyBlue.withAlpha(50),
              ),
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(shape: BoxShape.circle, color: navyBlue),
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget buildPageContent(String image, String title, String desc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 300),
        const SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: navyBlue)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(desc, textAlign: TextAlign.center, 
              style: TextStyle(color: navyBlue.withAlpha(130), fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: _currentPage == index ? navyBlue : skyBlue,
      ),
    );
  }
}
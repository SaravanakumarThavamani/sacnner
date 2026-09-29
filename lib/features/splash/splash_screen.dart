import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/services/deeplink_services.dart';
import '../../networks/data_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const primaryColor = Color(0xFF4038D8);
  final tokenDataService = Get.find<TokenDataServiceImp>();

  late AnimationController controller;
  late Animation<double> fade;
  late Animation<double> scale;
  late Animation<double> loading;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    fade = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    scale = Tween<double>(
      begin: .8,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    loading = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.forward();

    Timer(const Duration(seconds: 2), navigateToNextScreen);
  }

  void navigateToNextScreen() async {
    debugPrint("Pending Deep Link => ${DeepLinkService.pendingDeepLink}");

    if (DeepLinkService.pendingDeepLink != null) {
      debugPrint("🔥 Deep link detected, handling it");

      DeepLinkService.handlePendingDeepLink();
      return;
    }

    debugPrint("➡️ No deep link, go Login/Home");
    await checkLogin();
  }

  Future<void> checkLogin() async {
    // final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isLoggedIn = tokenDataService.isLoggedIn;

    if (!mounted) return;

    if (isLoggedIn) {
      Get.offAllNamed(RouteList.mainscreen);
    } else {
      Get.offAllNamed(RouteList.login);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget invoiceLogos() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.document_scanner_rounded,
        size: 48,
        color: primaryColor,
      ),
    );
  }

  Widget invoiceLogo() {
    return Container(
      width: Get.width * 0.22,
      height: Get.width * 0.22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          "assets/images/invoice_logo.png", // your image path
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                invoiceLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Scanwoo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan. Edit. Export.',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: loading,
                  builder: (context, child) {
                    return SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: loading.value,
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        backgroundColor: Colors.white30,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/route_binding.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/services/deeplink_services.dart';
import 'networks/data_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/scan_history_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox("localBox"); // only if you actually use this box
  await ScanHistoryService.initialize();

  Get.put<TokenDataServiceImp>(TokenDataServiceImp(), permanent: true);
  await DeepLinkService.init();

  runApp(const QuickScannerApp());
}

class QuickScannerApp extends StatelessWidget {
  const QuickScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RouteList.inital,
        getPages: Routes.routes,
        themeMode: ThemeMode.system,
      ),
    );
    //   MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: const SplashScreen(),
    //   ),
    // );
  }
}

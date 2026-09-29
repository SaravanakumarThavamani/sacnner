import 'package:flutter/material.dart';
import 'package:quick_scanner/features/history/screens/history_screen.dart';
import 'package:quick_scanner/features/home/screen/home_screen.dart';
import 'package:quick_scanner/features/profile/profile.dart';
import 'package:quick_scanner/features/scan_document/screens/exportscreen.dart';
import '../../widgets/bottomnav.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(0, _tabCount - 1);
  }

  static const int _tabCount = 4;

  void onNavTap(int value) {
    if (value == index) return; // avoid pointless rebuilds
    setState(() => index = value);
  }

  List<Widget> get _screens => [
    HomeScreen(onNavigateToTab: onNavTap),
    ScanHistoryScreen(onBack: () => onNavTap(0)),
    ExportScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: CommonBottomNav(
        selectedIndex: index,
        onItemSelected: onNavTap,
      ),
    );
  }
}

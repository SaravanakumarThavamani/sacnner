import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/logic/history_controller.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';
import 'package:quick_scanner/features/profile/logic/profile_controller.dart';
import 'package:quick_scanner/services/models/scan_record.dart';
import 'package:quick_scanner/services/scan_history_service.dart';
import 'package:quick_scanner/utils/helpers.dart';
import '../../../networks/data_service.dart';
import '../../scan_document/screens/scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final c = Get.put(HistoryController());
  final p = Get.put(ProfileController());
  // ---- Palette -----------------------------------------------------------
  static const _primary = Color(0xFF3F3DF0);
  static const _primaryDark = Color(0xFF211F8C);
  static const _accent = Color(0xFF7B79FF);
  static const _bg = Color(0xFFF4F5FA);
  static const _cardIconBg = Color(0xFFEDEDFF);
  static const _textMuted = Color(0xFF8B8D98);
  static const _textDark = Color(0xFF1A1B25);
  double _sw(double px) => Get.width * (px / 375);
  double _sh(double px) => Get.height * (px / 812);
  double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);
  void goToTab(int i) => widget.onNavigateToTab?.call(i);
  final ProfileController _profileController = Get.put(ProfileController());

  final tokenDataService = Get.find<TokenDataServiceImp>();
  // late String userName;
  // late String userEmail;

  // @override
  // void initState() {
  //   super.initState();
  //   userName = tokenDataService.userName ?? 'Guest User';
  //   userEmail = tokenDataService.email ?? '';
  // }

  void openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          child: Obx(() {
            if (_profileController.isLoading.value) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _primary,
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_topSection(), _content()],
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _topSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _accent, _primaryDark],
          stops: [0.0, 0.45, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryDark.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft decorative glow, purely cosmetic.
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _profileController.userName.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => goToTab(3),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<ScanRecord>>(
                valueListenable: ScanHistoryService.recordsNotifier,
                builder: (context, records, _) => _statsStrip(records),
              ),
              const SizedBox(height: 18),
              _scanCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsStrip(List<ScanRecord> records) {
    return Obx(() {
      final stats = p.dashboard.value?.data.stats;

      return Row(
        children: [
          Expanded(
            child: _statChip(
              Icons.receipt_long_rounded,
              stats == null ? '--' : '${stats.invoicesThisMonth}',
              'Invoices This Month',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statChip(
              Icons.calendar_month_rounded,
              stats == null ? '--' : '${stats.pending}',
              'Pending Review',
            ),
          ),
          //  Expanded(
          //   child: _statChip(
          //     Icons.calendar_month_rounded,
          //     stats == null ? '--' : '${stats.pending}',
          //     'Pending Review',
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scanCard() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: openScanner,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Invoice',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Extract data in seconds',
                      style: TextStyle(color: _textMuted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: _cardIconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _primary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: EdgeInsets.fromLTRB(_sw(18), _sh(24), _sw(18), 0),
      child: Obx(() {
        final items = c.recent;
        final loading = c.isRecentLoading.value && items.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Invoices',
                  style: TextStyle(
                    fontSize: _sp(17),
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: 0.1,
                  ),
                ),
                if (c.recentTotal.value > 4)
                  GestureDetector(
                    onTap: () => goToTab(1),
                    child: Row(
                      children: [
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: _sp(13),
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _primary,
                          size: _sw(18),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: _sh(14)),
            if (loading || _profileController.isLoading.value)
              Padding(
                padding: EdgeInsets.symmetric(vertical: _sh(32)),
                child: const Center(
                  child: CircularProgressIndicator(color: _primary),
                ),
              )
            else if (items.isEmpty)
              _emptyState()
            else
              Column(children: items.map(_recentTile).toList()),
          ],
        );
      }),
    );
  }

  Widget _recentTile(InvoiceData inv) {
    final name =
        inv.supplier.trim().isEmpty ? 'Unknown supplier' : inv.supplier;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_sw(16)),
      child: InkWell(
        onTap: () => goToTab(1),
        borderRadius: BorderRadius.circular(_sw(16)),
        child: Container(
          margin: EdgeInsets.only(bottom: _sh(10)),
          padding: EdgeInsets.symmetric(horizontal: _sw(14), vertical: _sh(13)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_sw(16)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: _sw(40),
                height: _sw(40),
                decoration: BoxDecoration(
                  color: _cardIconBg,
                  borderRadius: BorderRadius.circular(_sw(12)),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: _primary,
                  size: _sw(20),
                ),
              ),
              SizedBox(width: _sw(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _sp(13.5),
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: _sh(3)),
                    Text(
                      formatShortDate(inv.uploadedAt),
                      style: TextStyle(color: _textMuted, fontSize: _sp(11)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: _sw(8)),
              Text(
                '£${inv.gross.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: _sp(14),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              SizedBox(width: _sw(4)),
              Icon(
                Icons.chevron_right_rounded,
                color: _textMuted,
                size: _sw(20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDF4), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _cardIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: _primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No invoices yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _textDark,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan your first invoice to see it here',
            style: TextStyle(color: _textMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

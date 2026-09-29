import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/logic/history_controller.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';
import '../../../services/models/scan_record.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/exportsheet.dart';

const primary = Color(0xFF3F3DF0);
const primaryDark = Color(0xFF211F8C);
const accent = Color(0xFF7B79FF);
const background = Color(0xFFF6F7FB);
const textDark = Color(0xFF1D1E2C);
const textMuted = Color(0xFF8C8FA3);

double _sw(double px) => Get.width * (px / 375);
double _sh(double px) => Get.height * (px / 812);
double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);

class ExportScreen extends StatelessWidget {
  ExportScreen({super.key});

  final c = Get.put(HistoryController());

  Future<void> _export(BuildContext context) async {
    if (c.isExporting.value) return;
    c.isExporting.value = true;
    final all = await c.fetchAllInvoices();
    c.isExporting.value = false;

    if (all.isEmpty) {
      Get.snackbar('Nothing to export', 'No invoices were found.');
      return;
    }

    // Raw data only: one record per invoice, text = OCR raw text
    final records =
        all
            .map(
              (inv) => ScanRecord(
                text: c.rawTextOf(inv),
                imagePath: inv.images.isNotEmpty ? inv.images.first.url : '',
                createdAt: inv.uploadedAt,
              ),
            )
            .toList();

    if (context.mounted) showExportSheet(context, records);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_sh(64)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, accent, primaryDark],
              stops: [0.0, 0.45, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: _sh(64),
            title: Text(
              'Export Records',
              style: TextStyle(
                fontSize: _sp(21),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final items = c.recent;
        final total = c.recentTotal.value;
        final loading = c.isRecentLoading.value && items.isEmpty;

        return RefreshIndicator(
          color: primary,
          onRefresh: c.fetchRecent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(_sw(18), _sh(20), _sw(18), _sh(32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (total > 0) ...[
                  sectionHeader('Export Options'),
                  SizedBox(height: _sh(16)),
                  exportOption(
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF2E7D32),
                    title: 'Export Raw Data',
                    subtitle:
                        'Download raw text of $total invoices as PDF or Excel',
                    busy: c.isExporting.value,
                    onTap: () => _export(context),
                  ),
                  SizedBox(height: _sh(24)),
                ],
                sectionHeader('Recent Records'),
                SizedBox(height: _sh(16)),
                if (loading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: _sh(32)),
                    child: const Center(
                      child: CircularProgressIndicator(color: primary),
                    ),
                  )
                else if (items.isEmpty)
                  emptyState()
                else
                  ...items.map(recentTile),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: _sp(16.5),
        fontWeight: FontWeight.w800,
        color: textDark,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget exportOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool busy,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_sw(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(_sw(18)),
        onTap: busy ? null : onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: _sh(76)),
          padding: EdgeInsets.all(_sw(18)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_sw(18)),
            border: Border.all(color: const Color(0xFFEEEFF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: _sw(54),
                height: _sw(54),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.16),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_sw(15)),
                ),
                child: Icon(icon, color: color, size: _sw(26)),
              ),
              SizedBox(width: _sw(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: _sp(15.5),
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: _sh(5)),
                    Text(
                      busy ? 'Preparing your data...' : subtitle,
                      style: TextStyle(fontSize: _sp(12.5), color: textMuted),
                    ),
                  ],
                ),
              ),
              busy
                  ? SizedBox(
                    width: _sw(20),
                    height: _sw(20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primary,
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.all(_sw(8)),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(_sw(22)),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: _sw(14),
                      color: textMuted,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget recentTile(InvoiceData inv) {
    final name =
        inv.supplier.trim().isEmpty ? 'Unknown supplier' : inv.supplier;

    return Container(
      margin: EdgeInsets.only(bottom: _sh(12)),
      constraints: BoxConstraints(minHeight: _sh(72)),
      padding: EdgeInsets.symmetric(horizontal: _sw(16), vertical: _sh(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw(16)),
        border: Border.all(color: const Color(0xFFEEEFF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: _sw(44),
            height: _sw(44),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  accent.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(_sw(12)),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: primary,
              size: _sw(21),
            ),
          ),
          SizedBox(width: _sw(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _sp(14.5),
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: _sh(3)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: _sw(12),
                      color: textMuted.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: _sw(4)),
                    Text(
                      formatShortDate(inv.uploadedAt),
                      style: TextStyle(
                        fontSize: _sp(12),
                        fontWeight: FontWeight.w500,
                        color: textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
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
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: _sh(52), horizontal: _sw(28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw(20)),
        border: Border.all(color: const Color(0xFFEEEFF5)),
      ),
      child: Column(
        children: [
          Container(
            width: _sw(68),
            height: _sw(68),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primary.withValues(alpha: 0.14),
                  accent.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.document_scanner_rounded,
              size: _sw(30),
              color: primary,
            ),
          ),
          SizedBox(height: _sh(22)),
          Text(
            'No records yet',
            style: TextStyle(
              fontSize: _sp(16.5),
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          SizedBox(height: _sh(8)),
          Text(
            'Scan a document to get started.\nEverything you scan will appear here,\nready to export as PDF or Excel.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: _sp(13), color: textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

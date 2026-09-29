import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/logic/history_controller.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';
import 'package:quick_scanner/features/history/screens/sub_screen/edit_screen.dart';
import 'package:quick_scanner/features/history/screens/view_img.dart';
import 'package:quick_scanner/features/history/screens/view_invoice.dart';

const primary = Color(0xFF4038D8);
const primaryDark = Color(0xFF2C2AC0);
const primaryLight = Color(0xFF6C63FF);
const background = Color(0xFFF5F7FB);
const _textDark = Color(0xFF1A1B25);
const _textMuted = Color(0xFF8B8D98);
const _cardIconBg = Color(0xFFEDEDFF);
const _divider = Color(0xFFE7E8F2);

double _sw(double px) => Get.width * (px / 375);
double _sh(double px) => Get.height * (px / 812);
double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);

class ScanHistoryScreen extends StatelessWidget {
  final VoidCallback? onBack;
  ScanHistoryScreen({super.key, this.onBack});

  final c = Get.put(HistoryController());

  static const _filters = [
    ('All', Icons.apps_rounded),
    ('Today', Icons.today_rounded),
    ('This Week', Icons.date_range_rounded),
    ('This Month', Icons.calendar_month_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: Obx(() {
          final list = c.filtered;
          final grouped = c.grouped(list);
          final total = c.meta.value?.total ?? c.invoices.length;
          final searching = c.query.value.trim().isNotEmpty;

          return Column(
            children: [
              _header(total, list.length),
              Expanded(
                child:
                    c.isLoading.value && c.invoices.isEmpty
                        ? const Center(
                          child: CircularProgressIndicator(color: primary),
                        )
                        : RefreshIndicator(
                          color: primary,
                          onRefresh: c.fetchInvoices,
                          child: ListView(
                            controller: c.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              _sw(16),
                              _sh(12),
                              _sw(16),
                              _sh(24),
                            ),
                            children: [
                              if (list.isEmpty) _emptyState(searching),
                              for (final entry in grouped.entries) ...[
                                _sectionLabel(entry.key, entry.value.length),
                                SizedBox(height: _sh(10)),
                                for (final inv in entry.value) ...[
                                  _InvoiceCard(
                                    serial: list.indexOf(inv) + 1,
                                    invoice: inv,
                                    onView: () {
                                      Get.dialog(
                                        InvoiceViewDialog(invoice: inv),
                                      );
                                    },
                                    onImages:
                                        () => Get.dialog(
                                          InvoiceImagesDialog(invoice: inv),
                                        ),
                                    onDownload: () {
                                      c.downloadInvoicePdf(104);
                                    },
                                    onEdit:
                                        () => Get.to(
                                          () => EditRawTextScreen(
                                            invoice: inv,
                                            initialText: c.rawTextOf(inv),
                                            onSave:
                                                (text) => c.updateRawText(
                                                  inv.id,
                                                  text,
                                                ),
                                          ),
                                        ),
                                  ),

                                  SizedBox(height: _sh(10)),
                                ],
                                SizedBox(height: _sh(6)),
                              ],
                              if (c.isLoadingMore.value)
                                Padding(
                                  padding: EdgeInsets.all(_sw(12)),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header(int totalCount, int visibleCount) {
    final isFiltered =
        c.query.value.trim().isNotEmpty || c.filter.value != 'All';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryLight, primary, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_sw(30)),
          bottomRight: Radius.circular(_sw(30)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x403038D8),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(_sw(16), _sh(8), _sw(16), _sh(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invoice History',
                style: TextStyle(
                  fontSize: _sp(19),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: _sh(3)),
              Text(
                isFiltered
                    ? '$visibleCount of $totalCount invoices'
                    : '$totalCount ${totalCount == 1 ? 'invoice' : 'invoices'} saved',
                style: TextStyle(
                  fontSize: _sp(12.5),
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: _sh(20)),
              _searchBar(),
              SizedBox(height: _sh(14)),
              _filterChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_sw(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: c.searchController,
        onChanged: c.setQuery,
        style: TextStyle(
          fontSize: _sp(14),
          color: _textDark,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search anything in your invoices...',
          hintStyle: TextStyle(fontSize: _sp(13.5), color: _textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _textMuted,
            size: _sw(22),
          ),
          suffixIcon:
              c.query.value.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: _sw(19),
                      color: _textMuted,
                    ),
                    onPressed: c.clearSearch,
                  )
                  : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: _sh(14)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_sw(16)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_sw(16)),
            borderSide: const BorderSide(color: primary, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: _sh(38),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: _sw(8)),
        itemBuilder: (_, i) {
          final (label, icon) = _filters[i];
          final active = label == c.filter.value;

          return GestureDetector(
            onTap: () => c.filter.value = label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: _sw(14),
                vertical: _sh(8),
              ),
              decoration: BoxDecoration(
                color:
                    active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(_sw(11)),
                border: Border.all(
                  color: active ? Colors.white : Colors.white24,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: _sw(14),
                    color: active ? primaryDark : Colors.white,
                  ),
                  SizedBox(width: _sw(6)),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: _sp(12.5),
                      fontWeight: FontWeight.w600,
                      color: active ? primaryDark : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------ body

  Widget _sectionLabel(String label, int count) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _sp(13),
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        SizedBox(width: _sw(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: _sw(7), vertical: _sh(1)),
          decoration: BoxDecoration(
            color: _cardIconBg,
            borderRadius: BorderRadius.circular(_sw(20)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: _sp(11),
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
        SizedBox(width: _sw(10)),
        Expanded(child: Container(height: 1, color: _divider)),
      ],
    );
  }

  Widget _emptyState(bool searching) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_sw(24), _sh(56), _sw(24), _sh(24)),
      child: Column(
        children: [
          Container(
            width: _sw(88),
            height: _sw(88),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_cardIconBg, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_outlined,
              size: _sw(38),
              color: primary,
            ),
          ),
          SizedBox(height: _sh(20)),
          Text(
            searching ? 'No invoices found' : 'No invoices yet',
            style: TextStyle(
              fontSize: _sp(16.5),
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          SizedBox(height: _sh(6)),
          Text(
            searching
                ? 'Try a different keyword or clear your search.'
                : 'Your saved invoices will appear here once you scan one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: _sp(13), color: _textMuted, height: 1.4),
          ),
          if (searching) ...[
            SizedBox(height: _sh(18)),
            OutlinedButton.icon(
              onPressed: c.clearSearch,
              icon: Icon(Icons.refresh_rounded, size: _sw(16)),
              label: const Text('Clear search'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: primary, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_sw(11)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice card  (fields: SL.NO, Invoice No, Supplier, Date, Gross, Uploaded,
// OCR, Actions)
// ---------------------------------------------------------------------------

class _InvoiceCard extends StatelessWidget {
  final int serial;
  final InvoiceData invoice;
  final VoidCallback onView;
  final VoidCallback onImages;
  final VoidCallback onDownload;
  final VoidCallback onEdit;

  const _InvoiceCard({
    required this.serial,
    required this.invoice,
    required this.onView,
    required this.onImages,
    required this.onDownload,
    required this.onEdit,
  });

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _fmt(DateTime d) {
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  String _dash(String? v) => (v == null || v.trim().isEmpty) ? '—' : v;

  // Works whether ocrStatus is an enum or a String
  ({String label, Color color}) _ocr() {
    final raw = invoice.ocrStatus.toString().split('.').last.toLowerCase();
    switch (raw) {
      case 'complete':
      case 'done':
        return (label: 'Done', color: const Color(0xFF2456D6));
      case 'failed':
      case 'error':
        return (label: 'Failed', color: Colors.redAccent);
      default:
        return (label: 'Pending', color: const Color(0xFFF29D1F));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ocr = _ocr();
    final hasImages = invoice.images.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(_sw(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw(16)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- SL.NO + Supplier + Gross
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _sw(30),
                height: _sw(30),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _cardIconBg,
                  borderRadius: BorderRadius.circular(_sw(9)),
                ),
                child: Text(
                  '$serial',
                  style: TextStyle(
                    fontSize: _sp(12),
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
              SizedBox(width: _sw(10)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: _sh(2)),
                  child: Text(
                    _dash(invoice.supplier),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _sp(14),
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              SizedBox(width: _sw(8)),
              Text(
                '£${invoice.gross.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: _sp(15),
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: _sh(12)),

          // ---- Invoice No / Date / Uploaded
          Row(
            children: [
              _info('Invoice No', _dash(invoice.invoiceNo), flex: 3),
              _info('Date', _dash(invoice.date?.toString()), flex: 2),
              _info('Uploaded', _fmt(invoice.uploadedAt), flex: 3),
            ],
          ),
          SizedBox(height: _sh(12)),
          Container(height: 1, color: _divider),
          SizedBox(height: _sh(8)),

          // ---- OCR + Actions
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _sw(10),
                  vertical: _sh(3),
                ),
                decoration: BoxDecoration(
                  color: ocr.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(_sw(20)),
                ),
                child: Text(
                  ocr.label,
                  style: TextStyle(
                    fontSize: _sp(11),
                    fontWeight: FontWeight.w700,
                    color: ocr.color,
                  ),
                ),
              ),
              const Spacer(),
              _action(Icons.visibility_outlined, onView),
              SizedBox(width: _sw(4)),
              _imageAction(hasImages),
              SizedBox(width: _sw(4)),
              _action(Icons.file_download_outlined, onDownload),
              SizedBox(width: _sw(4)),
              _action(Icons.edit, onEdit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _sp(10.5),
              color: _textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _sh(2)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _sp(12.5),
              color: _textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_sw(20)),
      child: Padding(
        padding: EdgeInsets.all(_sw(6)),
        child: Icon(icon, size: _sw(20), color: _textMuted),
      ),
    );
  }

  Widget _imageAction(bool enabled) {
    final unviewed = invoice.imagesUnviewedCount;

    return InkWell(
      onTap: enabled ? onImages : null,
      borderRadius: BorderRadius.circular(_sw(20)),
      child: Padding(
        padding: EdgeInsets.all(_sw(6)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.image_outlined,
              size: _sw(20),
              color: enabled ? _textMuted : _divider,
            ),

            // if (enabled && unviewed > 0)
            //   Positioned(
            //     top: -_sw(6),
            //     right: -_sw(6),
            //     child: Container(
            //       constraints: BoxConstraints(minWidth: _sw(15)),
            //       padding: EdgeInsets.symmetric(
            //         horizontal: _sw(3),
            //         vertical: _sh(1),
            //       ),
            //       decoration: BoxDecoration(
            //         color: Colors.redAccent,
            //         borderRadius: BorderRadius.circular(_sw(10)),
            //       ),
            //       child: Text(
            //         '$unviewed',
            //         textAlign: TextAlign.center,
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: _sp(9),
            //           fontWeight: FontWeight.w700,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

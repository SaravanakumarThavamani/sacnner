import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';

const primary = Color(0xFF4038D8);
const primaryDark = Color(0xFF2C2AC0);
const primaryLight = Color(0xFF6C63FF);
const background = Color(0xFFF5F7FB);
const _textDark = Color(0xFF1A1B25);
const _textMuted = Color(0xFF8B8D98);
const _divider = Color(0xFFE7E8F2);

double _sw(double px) => Get.width * (px / 375);
double _sh(double px) => Get.height * (px / 812);
double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);

class InvoiceViewDialog extends StatelessWidget {
  final InvoiceData invoice;
  const InvoiceViewDialog({super.key, required this.invoice});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _fmt(DateTime d) {
    final l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }

  String _dash(String? v) => (v == null || v.trim().isEmpty) ? '—' : v;

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

  // Flattens Fields into label/value rows, skipping empty values
  List<MapEntry<String, String>> _scannedRows() {
    final rows = <MapEntry<String, String>>[];

    void add(String key, dynamic v) {
      if (v == null) return;
      if (v is bool) {
        rows.add(MapEntry(key, v ? 'Yes' : 'No'));
      } else if (v is Map) {
        v.forEach((k, val) => add('$key.$k', val));
      } else if (v is List) {
        if (v.isEmpty) return;
        final lines = v
            .map((e) {
              if (e is Map) {
                final qty = e['qty'] ?? '';
                final desc = e['description'] ?? '';
                final amt = e['amount'] ?? '';
                return '$qty × $desc — $amt';
              }
              return '$e';
            })
            .join('\n');
        rows.add(MapEntry(key, lines));
      } else {
        final s = v.toString().trim();
        if (s.isNotEmpty) rows.add(MapEntry(key, s));
      }
    }

    invoice.fields.toJson().forEach(add);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final ocr = _ocr();
    final rows = _scannedRows();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: _sw(16),
        vertical: _sh(40),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_sw(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Header
            Padding(
              padding: EdgeInsets.fromLTRB(_sw(18), _sh(16), _sw(8), _sh(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.id}',
                          style: TextStyle(
                            fontSize: _sp(16),
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        SizedBox(height: _sh(3)),
                        Text(
                          'Uploaded ${_fmt(invoice.uploadedAt)}',
                          style: TextStyle(
                            fontSize: _sp(12),
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: _sh(2)),
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
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      size: _sw(20),
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: _divider),

            // ---- Body
            Flexible(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    _sw(18),
                    _sh(16),
                    _sw(18),
                    _sh(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('INVOICE SUMMARY'),
                      _row('Invoice Number', _dash(invoice.invoiceNo)),
                      _row('Supplier', _dash(invoice.supplier)),
                      _row('Invoice Date', _dash(invoice.date?.toString())),
                      _row(
                        'Gross Amount',
                        '£${invoice.gross.toStringAsFixed(2)}',
                        bold: true,
                        last: true,
                      ),
                      if (rows.isNotEmpty) ...[
                        SizedBox(height: _sh(18)),
                        _sectionTitle('ALL SCANNED FIELDS'),
                        for (var i = 0; i < rows.length; i++)
                          _row(
                            rows[i].key,
                            rows[i].value,
                            last: i == rows.length - 1,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ---- Footer
            Container(height: 1, color: _divider),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _sw(18),
                vertical: _sh(12),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: Get.back,
                  style: FilledButton.styleFrom(
                    backgroundColor: background,
                    foregroundColor: _textDark,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: _sw(22),
                      vertical: _sh(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_sw(10)),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: _sp(13.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: EdgeInsets.only(bottom: _sh(6)),
      child: Text(
        t,
        style: TextStyle(
          fontSize: _sp(10.5),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: _textMuted,
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool last = false,
  }) {
    final isLong = value.length > 38 || value.contains('\n');

    final labelText = Text(
      label,
      style: TextStyle(fontSize: _sp(12.5), color: _textMuted),
    );
    final valueText = SelectableText(
      value,
      textAlign: isLong ? TextAlign.start : TextAlign.end,
      style: TextStyle(
        fontSize: _sp(13),
        height: 1.45,
        color: _textDark,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: _sh(11)),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _divider)),
      ),
      child:
          isLong
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [labelText, SizedBox(height: _sh(6)), valueText],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: labelText),
                  SizedBox(width: _sw(12)),
                  Expanded(flex: 6, child: valueText),
                ],
              ),
    );
  }
}

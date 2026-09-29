import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/models/scan_record.dart';
import '../utils/helpers.dart';

const _textDark = Color(0xFF1A1B25);
const _textMuted = Color(0xFF8B8D98);
const _cardIconBg = Color(0xFFEDEDFF);

// Same 375x812 baseline scaling used across the app's screens, kept
// private to this file so RecordCard stays a drop-in, self-contained
// widget wherever it's used.
double _sw(double px) => Get.width * (px / 375);
double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);

class RecordCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  String get _title {
    if (record.text.trim().isEmpty) return 'Untitled scan';
    return record.text.trim().split('\n').first;
  }

  String? get _preview {
    final lines = record.text.trim().split('\n');
    if (lines.length < 2) return null;
    final rest = lines.sublist(1).join(' ').trim();
    return rest.isEmpty ? null : rest;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw(16)),
        border: Border.all(color: const Color(0xFFF0F0F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_sw(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: _sw(46),
              height: _sw(46),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_cardIconBg, primaryColor.withValues(alpha: 0.16)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_sw(14)),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.description_outlined,
                color: primaryColor,
                size: _sw(22),
              ),
            ),
            SizedBox(width: _sw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: _sp(14),
                      color: _textDark,
                    ),
                  ),
                  if (_preview != null) ...[
                    SizedBox(height: _sw(3)),
                    Text(
                      _preview!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: _sp(12), color: _textMuted),
                    ),
                  ],
                  SizedBox(height: _sw(6)),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: _sw(13),
                        color: _textMuted,
                      ),
                      SizedBox(width: _sw(4)),
                      Text(
                        formatShortDate(record.createdAt),
                        style: TextStyle(
                          fontSize: _sp(11.5),
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _menuButton(context),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: _textMuted, size: _sw(20)),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_sw(14)),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 19, color: _textDark),
                  SizedBox(width: _sw(10)),
                  const Text('Edit', style: TextStyle(color: _textDark)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 19, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
    );
  }
}

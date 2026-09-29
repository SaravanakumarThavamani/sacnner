import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/screens/edit_screen.dart';
import 'package:quick_scanner/widgets/exportsheet.dart';

import '../../../services/models/scan_record.dart';
import '../../../services/scan_history_service.dart';

class _Palette {
  static const primary = Color(0xFF4F46E5);
  // static const primaryDark = Color(0xFF3730A3);
  static const primarySoft = Color(0xFFEEF0FF);
  static const accent = Color(0xFF16A34A);
  static const background = Color(0xFFF7F7FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF13122B);
  static const muted = Color(0xFF6B6A85);
  static const mutedSoft = Color(0xFF9C9BB4);
  static const line = Color(0xFFEAEAF3);
  // static const danger = Color(0xFFDC2626);
}

class _Space {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const xxl = 36.0;
}

class _Radius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

TextStyle _type({
  required double size,
  required FontWeight weight,
  Color color = _Palette.ink,
  double? height,
  double letterSpacing = -0.1,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

class ScanPreviewScreen extends StatefulWidget {
  final ScanRecord record;

  const ScanPreviewScreen({super.key, required this.record});

  @override
  State<ScanPreviewScreen> createState() => ScanPreviewScreenState();
}

class ScanPreviewScreenState extends State<ScanPreviewScreen> {
  late ScanRecord record;

  @override
  void initState() {
    super.initState();
    record = widget.record;
  }

  Future<void> openEdit() async {
    final updatedText = await Get.to<String>(
      () => EditRecordScreen(extractedText: record.text),
      transition: Transition.rightToLeft,
    );

    if (!mounted || updatedText == null || updatedText == record.text) {
      return;
    }

    final records = ScanHistoryService.recordsNotifier.value;
    final index = records.indexOf(widget.record);
    if (index == -1) return;

    final updatedRecord = ScanRecord(
      text: updatedText,
      imagePath: record.imagePath,
      createdAt: record.createdAt,
    );

    await ScanHistoryService.updateRecord(index, updatedRecord);

    if (!mounted) return;
    setState(() => record = updatedRecord);
    _toast('Record updated', success: true);
  }

  void _copyText() {
    if (record.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: record.text));
    HapticFeedback.lightImpact();
    _toast('Text copied to clipboard', success: true);
  }

  void _toast(String message, {bool success = false}) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.info_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: _Space.sm),
          Expanded(
            child: Text(
              message,
              style: _type(
                size: 14,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _Palette.ink,
      borderRadius: _Radius.md,
      margin: const EdgeInsets.all(_Space.md),
      padding: const EdgeInsets.symmetric(
        horizontal: _Space.lg,
        vertical: _Space.md,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  void _openFullImage(File file) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_Radius.lg),
              child: Hero(
                tag: 'scan-image-${record.imagePath}',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: Get.back,
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
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

  @override
  Widget build(BuildContext context) {
    final imageFile = File(record.imagePath);
    final hasImage = imageFile.existsSync();

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: _ScanAppBar(onEdit: openEdit),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          _Space.lg,
          _Space.md,
          _Space.lg,
          _Space.xxl,
        ),
        children: [
          _ImageCard(
            file: imageFile,
            hasImage: hasImage,
            onTap: () => _openFullImage(imageFile),
          ),
          const SizedBox(height: _Space.md),
          _MetaStrip(record: record),
          _TextCard(record: record, onCopy: _copyText),
          const SizedBox(height: _Space.xl),
          _ActionBar(
            onEdit: openEdit,
            onExport: () => showExportSheet(context, [record]),
          ),
        ],
      ),
    );
  }
}

class _ScanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onEdit;

  const _ScanAppBar({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _Palette.primary,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      shadowColor: _Palette.ink.withValues(alpha: 0.08),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _Palette.background,
        onPressed: Get.back,
      ),
      title: Text(
        'Scan preview',
        style: _type(
          size: 17,
          color: _Palette.background,
          weight: FontWeight.w700,
        ),
      ),
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.edit_outlined, size: 20),
      //     color: _Palette.background,
      //     tooltip: 'Edit',
      //     onPressed: onEdit,
      //   ),
      //   const SizedBox(width: 4),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StatusChip extends StatelessWidget {
  final bool empty;

  const _StatusChip({required this.empty});

  @override
  Widget build(BuildContext context) {
    final dotColor = empty ? _Palette.mutedSoft : _Palette.accent;
    final bg = empty ? _Palette.background : const Color(0xFFEAFBF1);
    final fg = empty ? _Palette.muted : const Color(0xFF15803D);
    final label = empty ? 'Empty' : 'Text detected';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_Radius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: _type(size: 12, weight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Image card
// -----------------------------------------------------------------------
class _ImageCard extends StatelessWidget {
  final File file;
  final bool hasImage;
  final VoidCallback onTap;

  const _ImageCard({
    required this.file,
    required this.hasImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(_Radius.xl),
        boxShadow: [
          BoxShadow(
            color: _Palette.primary.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_Radius.lg),
        child: hasImage ? _photo(context) : const _MissingImage(),
      ),
    );
  }

  Widget _photo(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Hero(
            tag: 'scan-image-${file.path}',
            child: Image.file(
              file,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(_Radius.pill),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_out_map_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tap to zoom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingImage extends StatelessWidget {
  const _MissingImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      color: _Palette.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: const BoxDecoration(
              color: _Palette.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 26,
              color: _Palette.primary,
            ),
          ),
          const SizedBox(height: _Space.sm),
          Text(
            'Image not available',
            style: _type(
              size: 13,
              weight: FontWeight.w500,
              color: _Palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Meta strip
// -----------------------------------------------------------------------
class _MetaStrip extends StatelessWidget {
  final ScanRecord record;

  const _MetaStrip({required this.record});

  @override
  Widget build(BuildContext context) {
    final words =
        record.text.trim().isEmpty
            ? 0
            : record.text.trim().split(RegExp(r'\s+')).length;
    final empty = record.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _StatusChip(empty: empty),
        ),
        const SizedBox(height: _Space.sm),
        Row(
          children: [
            Expanded(
              child: _MetaPill(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(record.createdAt),
              ),
            ),
            const SizedBox(width: _Space.sm),
            Expanded(
              child: _MetaPill(
                icon: Icons.schedule_rounded,
                label: _formatTime(record.createdAt),
              ),
            ),
            const SizedBox(width: _Space.sm),
            Expanded(
              child: _MetaPill(
                icon: Icons.notes_rounded,
                label: '$words words',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(_Radius.md),
        border: Border.all(color: _Palette.line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: _Palette.primary),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _type(
              size: 11.5,
              weight: FontWeight.w600,
              color: _Palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Extracted text card
// -----------------------------------------------------------------------
class _TextCard extends StatelessWidget {
  final ScanRecord record;
  final VoidCallback onCopy;

  const _TextCard({required this.record, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final empty = record.text.trim().isEmpty;
    final chars = record.text.trim().length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: _Space.lg),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(_Radius.xl),
        border: Border.all(color: _Palette.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A13122B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: _Palette.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: _Palette.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: _Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extracted text',
                      style: _type(size: 16, weight: FontWeight.w700),
                    ),
                    if (!empty)
                      Text(
                        '$chars characters',
                        style: _type(
                          size: 11.5,
                          weight: FontWeight.w500,
                          color: _Palette.mutedSoft,
                        ),
                      ),
                  ],
                ),
              ),
              if (!empty) _CopyButton(onTap: onCopy),
            ],
          ),
          const SizedBox(height: _Space.md),
          if (empty)
            const _EmptyTextState()
          else
            _FilledText(text: record.text),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CopyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.primarySoft,
      borderRadius: BorderRadius.circular(_Radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Radius.sm),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 15, color: _Palette.primary),
              SizedBox(width: 6),
              Text(
                'Copy',
                style: TextStyle(
                  fontSize: 13,
                  color: _Palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTextState extends StatelessWidget {
  const _EmptyTextState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _Space.lg),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              color: _Palette.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.text_fields_rounded,
              size: 28,
              color: _Palette.mutedSoft,
            ),
          ),
          const SizedBox(height: _Space.md),
          Text(
            'No text was found in this scan',
            textAlign: TextAlign.center,
            style: _type(size: 14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Edit the record to add text yourself.',
            textAlign: TextAlign.center,
            style: _type(
              size: 13,
              weight: FontWeight.w400,
              color: _Palette.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledText extends StatelessWidget {
  final String text;

  const _FilledText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.background,
        borderRadius: BorderRadius.circular(_Radius.md),
      ),
      child: SelectableText(
        text,
        style: _type(
          size: 14.5,
          weight: FontWeight.w400,
          color: _Palette.ink.withValues(alpha: 0.88),
          height: 1.6,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Actions
// -----------------------------------------------------------------------
class _ActionBar extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onExport;

  const _ActionBar({required this.onEdit, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _Palette.primary,
                side: const BorderSide(color: _Palette.primary, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_Radius.md),
                ),
              ),
              // icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              onPressed: () => Get.back(),
              // onPressed: onEdit,
            ),
          ),
        ),
        const SizedBox(width: _Space.md),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: _Palette.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_Radius.md),
                ),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: const Text(
                'Export',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              onPressed: onExport,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Formatting helpers
// -----------------------------------------------------------------------
const _months = [
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

String _formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

String _formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final min = date.minute.toString().padLeft(2, '0');
  return '$hour:$min ${date.hour >= 12 ? 'PM' : 'AM'}';
}

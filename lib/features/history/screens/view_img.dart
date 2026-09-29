// ---------------------------------------------------------------------------
// Invoice view dialog
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/model/history_model.dart'
    hide Image;

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

// ---------------------------------------------------------------------------
// Invoice images dialog
// ---------------------------------------------------------------------------

class InvoiceImagesDialog extends StatelessWidget {
  final InvoiceData invoice;

  InvoiceImagesDialog({super.key, required this.invoice});

  final PageController _page = PageController();
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  String _size(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final images = invoice.images;

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
                          '${images.length} ${images.length == 1 ? 'image' : 'images'}',
                          style: TextStyle(
                            fontSize: _sp(12),
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: _index,
                    builder:
                        (_, i, __) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _sw(10),
                            vertical: _sh(3),
                          ),
                          decoration: BoxDecoration(
                            color: _textMuted,
                            borderRadius: BorderRadius.circular(_sw(20)),
                          ),
                          child: Text(
                            '${i + 1} / ${images.length}',
                            style: TextStyle(
                              fontSize: _sp(11),
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
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

            // ---- Image pager
            Flexible(
              child: Container(
                color: background,
                height: Get.height * 0.5,
                child: PageView.builder(
                  controller: _page,
                  itemCount: images.length,
                  onPageChanged: (i) => _index.value = i,
                  itemBuilder: (_, i) {
                    final img = images[i];
                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: Image.network(
                          img.url,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: primary,
                                strokeWidth: 2.5,
                              ),
                            );
                          },
                          errorBuilder:
                              (_, __, ___) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: _sw(40),
                                    color: _textMuted,
                                  ),
                                  SizedBox(height: _sh(8)),
                                  Text(
                                    'Unable to load image',
                                    style: TextStyle(
                                      fontSize: _sp(12.5),
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ---- File info + thumbnails
            ValueListenableBuilder<int>(
              valueListenable: _index,
              builder: (_, i, __) {
                final img = images[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    _sw(18),
                    _sh(12),
                    _sw(18),
                    _sh(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              img.originalName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: _sp(13),
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),
                          SizedBox(width: _sw(8)),
                          if (!img.isViewed)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _sw(8),
                                vertical: _sh(2),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(_sw(20)),
                              ),
                              child: Text(
                                'New',
                                style: TextStyle(
                                  fontSize: _sp(10.5),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: _sh(2)),
                      Text(
                        _size(img.size),
                        style: TextStyle(
                          fontSize: _sp(11.5),
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (images.length > 1)
              SizedBox(
                height: _sw(56),
                child: ValueListenableBuilder<int>(
                  valueListenable: _index,
                  builder:
                      (_, current, __) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: _sw(18),
                          vertical: _sh(6),
                        ),
                        itemCount: images.length,
                        separatorBuilder: (_, __) => SizedBox(width: _sw(8)),
                        itemBuilder: (_, i) {
                          final active = i == current;
                          return GestureDetector(
                            onTap:
                                () => _page.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                ),
                            child: Container(
                              width: _sw(44),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(_sw(8)),
                                border: Border.all(
                                  color: active ? primary : _divider,
                                  width: active ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                images[i].url,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.image_outlined,
                                      size: _sw(18),
                                      color: _textMuted,
                                    ),
                              ),
                            ),
                          );
                        },
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
}

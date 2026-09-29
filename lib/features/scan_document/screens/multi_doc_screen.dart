import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/scan_document/logic/scannercontroller.dart';
import 'package:quick_scanner/features/scan_document/repositiores/historyrepository.dart';
import 'package:quick_scanner/features/scan_document/screens/preview_screen.dart';
import '../../../services/models/scan_record.dart';
import '../../../networks/data_service.dart';
import '../../../services/scan_history_service.dart';

class MultiDocumentResultScreen extends StatefulWidget {
  final List<File> images;
  final List<String> extractedTexts;
  final List<Map<String, dynamic>>? extractedDataList;

  const MultiDocumentResultScreen({
    super.key,
    required this.images,
    required this.extractedTexts,
    this.extractedDataList,
  });

  @override
  State<MultiDocumentResultScreen> createState() =>
      MultiDocumentResultScreenState();
}

class MultiDocumentResultScreenState extends State<MultiDocumentResultScreen> {
  // Mutable local copies so individual documents can be removed (cancelled)
  // before saving, without touching the original widget-level lists.
  late List<File> images;
  late List<Map<String, dynamic>> extractedDataList;
  late List<TextEditingController> controllers;

  int currentIndex = 0;
  bool saving = false;

  static const primary = Color(0xFF4038D8);
  static const primaryDark = Color(0xFF2C2AC0);
  static const background = Color(0xFFF6F7FB);
  static const textDark = Color(0xFF1D1E2C);
  static const textMuted = Color(0xFF8C8FA3);

  @override
  void initState() {
    super.initState();

    images = List<File>.from(widget.images);

    extractedDataList = List<Map<String, dynamic>>.generate(
      widget.images.length,
      (i) =>
          widget.extractedDataList != null &&
                  i < widget.extractedDataList!.length
              ? widget.extractedDataList![i]
              : <String, dynamic>{},
    );

    controllers =
        widget.extractedTexts
            .map((text) => TextEditingController(text: text))
            .toList();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> copyText() async {
    await Clipboard.setData(
      ClipboardData(text: controllers[currentIndex].text),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied'),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  /// Returns the extracted-fields map for document [i], or an empty map
  /// if extraction wasn't run / wasn't passed in for this document.
  Map<String, dynamic> _dataFor(int i) {
    if (i < 0 || i >= extractedDataList.length) {
      return const {};
    }

    return extractedDataList[i];
  }

  void removeImage(int index) {
    if (saving || images.length <= 1) {
      if (images.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('At least one document is required'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      images.removeAt(index);
      extractedDataList.removeAt(index);

      final removedController = controllers.removeAt(index);
      removedController.dispose();

      if (currentIndex >= images.length) {
        currentIndex = images.length - 1;
      } else if (currentIndex > index) {
        currentIndex--;
      }
    });
  }

  Future<void> confirmRemoveImage(int index) async {
    if (saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Remove document?',
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
            ),
            content: const Text(
              'This document will be removed from the batch and won\'t be saved.',
              style: TextStyle(color: textMuted, fontSize: 13.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Color(0xFFE0473E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      removeImage(index);
    }
  }

  Future<void> saveDocuments() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      // final token = prefs.getString('token');
      final historyRepository = HistoryRepository();
      final tokenDataService = Get.find<TokenDataServiceImp>();

      final batchImages = <File>[];
      final batchTexts = <String>[];

      for (int i = 0; i < images.length; i++) {
        final text = controllers[i].text.trim();
        if (text.isEmpty) continue;

        batchImages.add(images[i]);
        batchTexts.add(text);
      }

      debugPrint('Uploading with token: ${tokenDataService.accessToken}');
      if (batchImages.isNotEmpty) {
        try {
          await historyRepository.uploadInvoicesIndividually(
            token: tokenDataService.accessToken,
            images: batchImages,
            extractedDataList: batchTexts,
          );
        } catch (e) {
          debugPrint('Individual uploads failed: $e');
        }
      }

      // If you want the user to know the server upload failed (rather than
      // silently continuing to the local save), uncomment:
      // if (uploadResult is FailureStatus) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(uploadResult.message), backgroundColor: Colors.red),
      //   );
      // }

      final savedRecords = <ScanRecord>[];

      for (int i = 0; i < images.length; i++) {
        final text = controllers[i].text.trim();

        if (text.isEmpty) continue;

        final data = _dataFor(i);

        final record = ScanRecord(
          text: text,
          imagePath: images[i].path,
          createdAt: DateTime.now(),
          supplier: data['supplier'],
          vatNumber: data['vat_number'],
          invoiceNo: data['invoice_no'],
          branch: data['branch'],
          date: data['date'],
          net: data['net'],
          vat: data['vat'],
          gross: data['gross'],
          payment: data['payment'],
        );

        await ScanHistoryService.addRecord(
          text: text,
          imageFile: images[i],
          extractedData: data,
        );

        savedRecords.add(record);
      }

      if (!mounted) return;

      if (savedRecords.isEmpty) {
        setState(() {
          saving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No documents available to save'),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      final records = ScanHistoryService.recordsNotifier.value;

      final actualRecords = <ScanRecord>[];

      for (int i = 0; i < images.length; i++) {
        final imagePath = images[i].path;

        final matches = records.where(
          (record) => record.imagePath == imagePath,
        );

        if (matches.isNotEmpty) {
          actualRecords.add(matches.last);
        }
      }

      final firstRecord =
          actualRecords.isNotEmpty ? actualRecords.first : savedRecords.first;
      setState(() => saving = false);

      // Everything is saved, so clear the scanner's pending images
      if (Get.isRegistered<ScannerController>()) {
        Get.find<ScannerController>().images.clear();
      }

      // Remove Scanner and Result from the stack, keeping Home at the bottom
      Get.offUntil(
        GetPageRoute(page: () => ScanPreviewScreen(record: firstRecord)),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryDark,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            // saving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Extracted Documents',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Document ${currentIndex + 1} of ${images.length}',
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 16),
          //     child: Center(
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 10,
          //           vertical: 5,
          //         ),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withValues(alpha: 0.16),
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Text(
          //           '${images.length}',
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w700,
          //             fontSize: 13,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.04,
            vertical: Get.height * 0.018,
          ),
          child: Column(
            children: [
              image(),
              SizedBox(height: Get.height * 0.016),
              documents(),
              SizedBox(height: Get.height * 0.016),

              // navigation(),
              // SizedBox(height: Get.height * 0.016),
              textBox(),
              SizedBox(height: Get.height * 0.016),
              navigation(),

              // SizedBox(height: Get.height * 0.014),
              // copyButton(),
              // SizedBox(height: Get.height * 0.012),
              // saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget image() {
    return Container(
      height: Get.height * 0.23,
      width: Get.width,
      padding: const EdgeInsets.all(10),
      decoration: card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: const Color(0xFFF1F2F6),
          child: InteractiveViewer(
            child: Image.file(images[currentIndex], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget documents() {
    return Container(
      height: Get.height * 0.115,
      padding: const EdgeInsets.all(12),
      decoration: card(),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, _) => SizedBox(width: Get.width * 0.02),
        itemBuilder: (_, index) {
          final selected = index == currentIndex;
          final thumbSize = Get.width * 0.15;

          return GestureDetector(
            onTap:
                saving
                    ? null
                    : () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? primary : const Color(0xFFEEEFF5),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                            : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(images[index], fit: BoxFit.cover),
                  ),
                ),
                if (!saving)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => confirmRemoveImage(index),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0473E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget navigation() {
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == images.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) {
            final active = i == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? primary : const Color(0xFFDBDCE8),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: (saving || isFirst) ? 0.4 : 1,
                  child: OutlinedButton.icon(
                    onPressed:
                        (saving || isFirst)
                            ? null
                            : () => setState(() => currentIndex--),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textDark,
                      disabledForegroundColor: textDark,
                      side: const BorderSide(color: Color(0xFFDBDCE8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text(
                      'Previous',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed:
                      saving
                          ? null
                          : () {
                            if (isLast) {
                              // trigger save/submit here
                              saveDocuments();
                            } else {
                              setState(() => currentIndex++);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shadowColor: primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon:
                      saving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                          : Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                  label: Text(
                    saving ? 'Saving...' : (isLast ? 'Finish' : 'Next'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget textBox() {
    return Container(
      height: Get.height * 0.28,
      padding: const EdgeInsets.all(16),
      decoration: card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.text_snippet_rounded,
                  color: primary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Extracted Text',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: controllers[currentIndex],
              enabled: !saving,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 13.5,
                color: textDark,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Extracted text',
                hintStyle: const TextStyle(color: textMuted),
                filled: true,
                fillColor: const Color(0xFFF8F9FC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primary, width: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget copyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: saving ? null : copyText,
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: Color(0xFFDBDCE8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.copy_rounded, size: 18),
        label: const Text(
          'Copy Text',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: saving ? null : saveDocuments,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB8B6E8),
          elevation: 0,
          shadowColor: primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon:
            saving
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.save_rounded, size: 19),
        label: Text(
          saving ? 'Saving...' : 'Save & View Invoice',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
        ),
      ),
    );
  }

  BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEEEFF5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

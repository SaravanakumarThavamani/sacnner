import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_scanner/features/scan_document/logic/scannercontroller.dart';
import 'package:quick_scanner/features/scan_document/screens/crop_screen.dart';
import 'package:quick_scanner/features/scan_document/screens/processing_screen.dart';
import 'package:quick_scanner/services/invoice_exterst.dart';
import '../../../services/ocr_service.dart';
import 'multi_doc_screen.dart';

const _primary = Color(0xFF4038D8);
const _primaryDark = Color(0xFF2C2AC0);
const _background = Color(0xFFF5F7FB);
const _textDark = Color(0xFF1A1B25);
const _textMuted = Color(0xFF8B8D98);
const _cardIconBg = Color(0xFFEDEDFF);
const _disabled = Color(0xFFB8B6E8);

// Same 375x812 baseline scaling used across the app's other screens.
double _sw(double px) => Get.width * (px / 375);
double _sh(double px) => Get.height * (px / 812);
double _sp(double px) => _sw(px).clamp(px * 0.85, px * 1.25);

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker picker = ImagePicker();
  final OcrService ocrService = OcrService();
  final ScannerController _scannerController = Get.put(ScannerController());

  int selectedImage = 0;
  bool isProcessing = false;

  Future<void> camera() async {
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;

    final croppedImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => CropAdjustScreen(image: File(image.path)),
      ),
    );

    if (croppedImage == null || !mounted) return;

    setState(() {
      _scannerController.images.add(croppedImage);
      selectedImage = _scannerController.images.length - 1;
    });
  }

  Future<void> gallery() async {
    final files = await picker.pickMultiImage(imageQuality: 85);

    if (files.isEmpty || !mounted) return;

    for (final file in files) {
      if (!mounted) return;

      final croppedImage = await Navigator.push<File>(
        context,
        MaterialPageRoute(
          builder: (_) => CropAdjustScreen(image: File(file.path)),
        ),
      );

      if (croppedImage == null || !mounted) continue;

      setState(() {
        _scannerController.images.add(croppedImage);
        selectedImage = _scannerController.images.length - 1;
      });
    }
  }

  // Future<void> process() async {
  //   if (_scannerController.images.isEmpty || isProcessing) return;

  //   setState(() => isProcessing = true);

  //   try {
  //     final extractedDataList = <Map<String, dynamic>>[];

  //     final texts = await Navigator.push<List<String>>(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (_) => ProcessingScreen(
  //               imagePaths:
  //                   _scannerController.images.map((file) => file.path).toList(),
  //               onProcess: (paths) async {
  //                 final results = <String>[];

  //                 for (final path in paths) {
  //                   final text = await ocrService.extractText(File(path));
  //                   final data = InvoiceExtractionService.extract(text);

  //                   results.add(text);
  //                   extractedDataList.add(data);
  //                 }

  //                 return results;
  //               },
  //             ),
  //       ),
  //     );

  //     if (!mounted) return;
  //     setState(() => isProcessing = false);
  //     if (texts == null) return;

  //     await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder:
  //             (_) => MultiDocumentResultScreen(
  //               images: List<File>.from(_scannerController.images),
  //               extractedTexts: List<String>.from(texts),
  //               extractedDataList: extractedDataList,
  //             ),
  //       ),
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       _scannerController.images.clear();
  //       selectedImage = 0;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() => isProcessing = false);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to process document: $e'),
  //         backgroundColor: Colors.redAccent,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(_sw(10)),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> process() async {
    if (_scannerController.images.isEmpty || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final extractedDataList = <Map<String, dynamic>>[];

      final texts = await Get.to<List<String>>(
        () => ProcessingScreen(
          imagePaths:
              _scannerController.images.map((file) => file.path).toList(),
          onProcess: (paths) async {
            final results = <String>[];

            for (final path in paths) {
              final text = await ocrService.extractText(File(path));
              final data = InvoiceExtractionService.extract(text);

              results.add(text);
              extractedDataList.add(data);
            }

            return results;
          },
        ),
      );

      if (!mounted) return;

      setState(() => isProcessing = false);

      if (texts == null) return;

      final imagesCopy = List<File>.from(_scannerController.images);
      final textsCopy = List<String>.from(texts);
      final dataCopy = List<Map<String, dynamic>>.from(extractedDataList);

      Get.to(
        () => MultiDocumentResultScreen(
          images: imagesCopy,
          extractedTexts: textsCopy,
          extractedDataList: dataCopy,
        ),
      );

      // DELETE these two lines:
      // _scannerController.images.clear();
      // selectedImage = 0;
      // Optional: comment these lines for testing
      // If the error still occurs, move this logic to the result screen's dispose()
      // _scannerController.images.clear();
      // selectedImage = 0;
    } catch (e) {
      if (!mounted) return;

      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process document: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_sw(10)),
          ),
        ),
      );
    }
  }

  void remove(int index) {
    if (index < 0 || index >= _scannerController.images.length) return;

    setState(() {
      _scannerController.images.removeAt(index);

      if (_scannerController.images.isEmpty) {
        selectedImage = 0;
      } else if (selectedImage >= _scannerController.images.length) {
        selectedImage = _scannerController.images.length - 1;
      }
    });
  }

  void clearImages() {
    if (_scannerController.images.isEmpty) return;

    setState(() {
      _scannerController.images.clear();
      selectedImage = 0;
    });
  }

  @override
  void dispose() {
    ocrService.dispose();
    super.dispose();
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
        backgroundColor: _background,
        body: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(_sw(16), _sh(18), _sw(16), 0),
                child: Column(
                  children: [
                    _preview(),
                    if (_scannerController.images.isNotEmpty) ...[
                      SizedBox(height: _sh(14)),
                      _thumbnails(),
                    ],
                    SizedBox(height: _sh(18)),
                    Row(
                      children: [
                        _actionCard(
                          Icons.camera_alt_outlined,
                          'Camera',
                          'Take photo',
                          isProcessing ? null : camera,
                        ),
                        SizedBox(width: _sw(12)),
                        _actionCard(
                          Icons.photo_library_outlined,
                          'Gallery',
                          'Select multiple',
                          isProcessing ? null : gallery,
                        ),
                      ],
                    ),
                    SizedBox(height: _sh(18)),
                    _processButton(),
                    SizedBox(height: _sh(18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _header() {
    final count = _scannerController.images.length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x333038D8),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(_sw(12), _sh(8), _sw(16), _sh(18)),
          child: Row(
            children: [
              _circleIconButton(
                Icons.arrow_back,
                () => Navigator.maybePop(context),
              ),
              SizedBox(width: _sw(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Documents',
                      style: TextStyle(
                        fontSize: _sp(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: _sh(2)),
                    Text(
                      count == 0
                          ? 'Capture or select invoices'
                          : '$count document${count == 1 ? '' : 's'} ready',
                      style: TextStyle(
                        fontSize: _sp(12),
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                _circleIconButton(
                  Icons.delete_outline,
                  isProcessing ? () {} : clearImages,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    final size = _sw(40);

    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Icon(icon, size: _sw(19), color: Colors.white),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------

  Widget _preview() {
    final images = _scannerController.images;

    return Container(
      height: _sh(300),
      width: double.infinity,
      padding: EdgeInsets.all(_sw(8)),
      decoration: _box(),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_sw(14)),
            child: SizedBox.expand(
              child:
                  images.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(_sw(16)),
                              decoration: const BoxDecoration(
                                color: _cardIconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.document_scanner_outlined,
                                size: _sw(40),
                                color: _primary,
                              ),
                            ),
                            SizedBox(height: _sh(20)),
                            Text(
                              'No document selected',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: _sp(14),
                                color: _textDark,
                              ),
                            ),
                            SizedBox(height: _sh(6)),
                            Text(
                              'Use camera or gallery below',
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: _sp(12),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Image.file(images[selectedImage], fit: BoxFit.contain),
            ),
          ),
          if (images.length > 1)
            Positioned(
              top: _sh(10),
              right: _sw(10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _sw(10),
                  vertical: _sh(5),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(_sw(20)),
                ),
                child: Text(
                  '${selectedImage + 1} / ${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _sp(11.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumbnails() {
    final images = _scannerController.images;

    return Container(
      padding: EdgeInsets.all(_sw(12)),
      decoration: _box(),
      child: SizedBox(
        height: _sh(65),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index) {
            final selected = index == selectedImage;

            return GestureDetector(
              onTap: () => setState(() => selectedImage = index),
              child: Container(
                width: _sw(60),
                margin: EdgeInsets.only(right: _sw(8)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_sw(8)),
                  border: Border.all(
                    color: selected ? _primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(_sw(6)),
                      child: Image.file(
                        images[index],
                        width: _sw(60),
                        height: _sh(65),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: GestureDetector(
                        onTap: () => remove(index),
                        child: CircleAvatar(
                          radius: _sw(9),
                          backgroundColor: Colors.redAccent,
                          child: Icon(
                            Icons.close,
                            size: _sw(12),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_sw(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_sw(16)),
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1,
            child: Container(
              height: _sh(100),
              padding: EdgeInsets.all(_sw(14)),
              decoration: _box(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(_sw(8)),
                    decoration: BoxDecoration(
                      color: _cardIconBg,
                      borderRadius: BorderRadius.circular(_sw(10)),
                    ),
                    child: Icon(icon, color: _primary, size: _sw(20)),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: _sp(13),
                      color: _textDark,
                    ),
                  ),
                  SizedBox(height: _sh(2)),
                  Text(
                    subtitle,
                    style: TextStyle(color: _textMuted, fontSize: _sp(10.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _processButton() {
    final count = _scannerController.images.length;

    return SizedBox(
      width: double.infinity,
      height: _sh(52),
      child: ElevatedButton.icon(
        onPressed: count == 0 || isProcessing ? null : process,
        icon:
            isProcessing
                ? SizedBox(
                  width: _sw(20),
                  height: _sw(20),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.document_scanner_outlined),
        label: Text(
          isProcessing
              ? 'Processing...'
              : 'Process $count Document${count == 1 ? '' : 's'}',
          style: TextStyle(fontSize: _sp(15), fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _disabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_sw(14)),
          ),
        ),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_sw(16)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart'; // compute
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

/// args: [sourcePath, outPath, angle]
/// Runs in a background isolate so large photos don't freeze the UI.
String _rotateInIsolate(List<String> args) {
  final bytes = File(args[0]).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return args[0];

  final upright = img.bakeOrientation(decoded); // respect EXIF first
  final rotated = img.copyRotate(upright, angle: int.parse(args[2]));

  File(args[1]).writeAsBytesSync(img.encodeJpg(rotated, quality: 92));
  return args[1];
}

class CropAdjustScreen extends StatefulWidget {
  final File image;

  const CropAdjustScreen({super.key, required this.image});

  @override
  State<CropAdjustScreen> createState() => _CropAdjustScreenState();
}

class _CropAdjustScreenState extends State<CropAdjustScreen> {
  static const Color primary = Color(0xFF4038D8);
  static const Color primarySoft = Color(0xFFEDECFB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF1C1C28);
  static const Color textMuted = Color(0xFF7A7A8C);
  static const Color border = Color(0xFFE7E7EE);

  late File currentImage;
  String selectedTool = '';
  bool isProcessing = false;

  bool get isEdited => currentImage.path != widget.image.path;

  @override
  void initState() {
    super.initState();
    currentImage = widget.image;
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: textDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> openCropper() async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      selectedTool = 'Crop';
    });
    try {
      final result = await ImageCropper().cropImage(
        sourcePath: currentImage.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: primary,
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            aspectRatioLockEnabled: false,
            rotateButtonsHidden: false,
          ),
        ],
      );

      if (result != null && mounted) {
        setState(() => currentImage = File(result.path));
      }
    } catch (_) {
      showMessage('Could not crop image');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
          selectedTool = '';
        });
      }
    }
  }

  /// 90 = clockwise, 270 = counter-clockwise.
  Future<void> rotateImage({int angle = 90}) async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
      selectedTool = angle == 90 ? 'Rotate Right' : 'Rotate Left';
    });
    try {
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/rot_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final resultPath = await compute(_rotateInIsolate, [
        currentImage.path,
        outPath,
        angle.toString(),
      ]);

      if (mounted) setState(() => currentImage = File(resultPath));
    } catch (_) {
      showMessage('Could not rotate image');
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
          selectedTool = '';
        });
      }
    }
  }

  void resetImage() {
    if (isProcessing || !isEdited) return;
    setState(() {
      currentImage = widget.image;
      selectedTool = '';
    });
    showMessage('Changes reset');
  }

  void next() {
    Navigator.pop(context, currentImage);
  }

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
        body: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: buildPreview(),
              ),
            ),
            buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primary,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'Crop & Adjust',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1F),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(
                currentImage,
                key: ValueKey(currentImage.path),
                fit: BoxFit.contain,
              ),
            ),
            if (isProcessing)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tools',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          buildTools(),
          const SizedBox(height: 16),
          buildNextButton(),
        ],
      ),
    );
  }

  Widget buildTools() {
    return Container(
      padding: const EdgeInsets.all(6),
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          buildTool(
            icon: Icons.rotate_left_rounded,
            title: 'Rotate Left',
            onTap: () => rotateImage(angle: 270),
          ),
          buildTool(
            icon: Icons.rotate_right_rounded,
            title: 'Rotate Right',
            onTap: () => rotateImage(angle: 90),
          ),
          buildTool(
            icon: Icons.crop_rounded,
            title: 'Crop',
            onTap: openCropper,
          ),
          buildTool(
            icon: Icons.restart_alt_rounded,
            title: 'Reset',
            onTap: resetImage,
            enabled: isEdited,
          ),
        ],
      ),
    );
  }

  Widget buildTool({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final bool selected = selectedTool == title;
    final bool active = enabled && !isProcessing;
    final Color color =
        !active ? textMuted.withOpacity(0.4) : (selected ? primary : textMuted);

    return Expanded(
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNextButton() {
    return Center(
      child: SizedBox(
        width: Get.width * 0.5,
        height: 48,
        child: ElevatedButton(
          onPressed: isProcessing ? null : next,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primary.withOpacity(0.4),
            disabledForegroundColor: Colors.white70,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

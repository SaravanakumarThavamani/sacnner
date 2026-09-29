import 'dart:io';

import 'package:get/get.dart';

import 'package:quick_scanner/networks/data_service.dart';

import 'package:quick_scanner/features/scan_document/repositiores/scannerrepository.dart';
import 'package:quick_scanner/services/ocr_service.dart';
import '../../../services/models/scan_record.dart';

class ScannerController extends GetxController {
  final ScannerRepository _repository = ScannerRepository();
  bool isLoading = false;
  String? errorMessage;
  ScanRecord? currentRecord;
  final OcrService ocrService = OcrService();
  final tokenDataService = Get.find<TokenDataServiceImp>();
  final List<File> images = [];

  int selectedImage = 0;
  bool isProcessing = false;
  bool isUploading = false;

  final List<ScanRecord> scanRecords = [];

  Future<void> scanDocument(String imagePath) async {
    isLoading = true;
    errorMessage = null;
    currentRecord = null;
    update();

    try {
      final record = await _repository.processImage(imagePath);
      await _repository.saveScanRecord(record);
      currentRecord = record;

      // track this image + its record together for later batch upload
      images.add(File(imagePath));
      scanRecords.add(record);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearState() {
    currentRecord = null;
    errorMessage = null;
    isLoading = false;
    update();
  }
}

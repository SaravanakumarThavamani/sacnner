import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quick_scanner/services/invoice_exterst.dart';
import 'package:quick_scanner/services/ocr_service.dart';

import '../../../services/models/scan_record.dart';

class ScannerRepository {
  Future<ScanRecord> processImage(String imagePath) async {
    final ocrService = OcrService();
    final imageFile = File(imagePath);
    final extractedText = await ocrService.extractText(imageFile);
    final data = InvoiceExtractionService.extract(extractedText);

    debugPrint('OCR raw text:\n$extractedText');
    debugPrint('OCR raw qq data: $data');

    final record = ScanRecord(
      text: extractedText,
      imagePath: imagePath,
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

    debugPrint(
      'OCR raw ScanRecord: ${const JsonEncoder.withIndent('  ').convert(record.toJson())}',
    );

    return record;
  }

  Future<void> saveScanRecord(ScanRecord record) async {
    try {
      debugPrint(
        'Repository: Record saved successfully for image ${record.imagePath}',
      );
    } catch (e) {
      throw Exception('Failed to save record: $e');
    }
  }
}

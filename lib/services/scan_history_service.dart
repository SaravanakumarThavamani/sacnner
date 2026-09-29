import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/scan_record.dart';

class ScanHistoryService {
  static const String _boxName = 'scan_history_box';
  static const String _storageKey = 'scan_history';

  static final ValueNotifier<List<ScanRecord>> recordsNotifier =
      ValueNotifier<List<ScanRecord>>([]);

  static Box? _box;

  static Future<void> initialize() async {
    // If Hive.initFlutter() hasn't already been called in main(), do it here:
    // await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    await loadRecords();
  }

  static Box get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError(
        'ScanHistoryService.initialize() must be called before use.',
      );
    }
    return box;
  }

  static Future<String> saveImagePermanently(File originalImage) async {
    final directory = await getApplicationDocumentsDirectory();

    final imagesDirectory = Directory('${directory.path}/scanned_images');

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newPath = '${imagesDirectory.path}/$fileName';

    final savedImage = await originalImage.copy(newPath);

    return savedImage.path;
  }

  static Future<void> addRecord({
    required String text,
    required File imageFile,
    Map<String, dynamic>? extractedData,
  }) async {
    final savedImagePath = await saveImagePermanently(imageFile);

    final updatedRecords = List<ScanRecord>.from(recordsNotifier.value);

    final data = extractedData ?? const {};

    updatedRecords.insert(
      0,
      ScanRecord(
        text: text,
        imagePath: savedImagePath,
        createdAt: DateTime.now(),
        supplier: data['supplier'],
        vatNumber: data['vat_number'],
        invoiceNo: data['invoice_no'],
        branch: data['branch'],
        date: data['date'],
        net: (data['net'] as num?)?.toDouble(),
        vat: (data['vat'] as num?)?.toDouble(),
        gross: (data['gross'] as num?)?.toDouble(),
        payment: data['payment'],
      ),
    );

    recordsNotifier.value = updatedRecords;

    await _saveRecords();
  }

  static Future<void> updateRecord(int index, ScanRecord record) async {
    final updatedRecords = List<ScanRecord>.from(recordsNotifier.value);

    if (index < 0 || index >= updatedRecords.length) {
      return;
    }

    updatedRecords[index] = record;

    recordsNotifier.value = updatedRecords;

    await _saveRecords();
  }

  static Future<void> deleteRecord(int index) async {
    final updatedRecords = List<ScanRecord>.from(recordsNotifier.value);

    if (index < 0 || index >= updatedRecords.length) {
      return;
    }

    final record = updatedRecords[index];

    try {
      final imageFile = File(record.imagePath);

      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (_) {}

    updatedRecords.removeAt(index);

    recordsNotifier.value = updatedRecords;

    await _saveRecords();
  }

  static Future<void> clearHistory() async {
    for (final record in recordsNotifier.value) {
      try {
        final imageFile = File(record.imagePath);

        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (_) {}
    }

    recordsNotifier.value = [];

    await _requireBox.delete(_storageKey);
  }

  static Future<void> loadRecords() async {
    final dynamic data = _requireBox.get(_storageKey);

    if (data == null) {
      recordsNotifier.value = [];
      return;
    }

    try {
      final List<dynamic> jsonList = List<dynamic>.from(data as List);

      recordsNotifier.value =
          jsonList
              .map(
                (item) =>
                    ScanRecord.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList();
    } catch (_) {
      recordsNotifier.value = [];
    }
  }

  static Future<void> _saveRecords() async {
    final data =
        recordsNotifier.value.map((record) => record.toJson()).toList();

    await _requireBox.put(_storageKey, data);
  }
}

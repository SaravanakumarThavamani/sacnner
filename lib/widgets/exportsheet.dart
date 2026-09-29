import 'package:flutter/material.dart';
import 'package:quick_scanner/utils/helpers.dart';
import '../services/models/scan_record.dart';
import '../../services/excel_service.dart';
import '../../services/pdf_services.dart';

void showExportSheet(BuildContext context, List<ScanRecord> records) {
  final single = records.length == 1;
  showModalBottomSheet(
    context: context,
    builder:
        (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      single ? 'Export This Scan' : 'Export All Scans',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      single
                          ? recordTitle(records.first)
                          : '${records.length} records',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(sheet);
                  _run(
                    context,
                    () => PdfService.exportAndShareRecords(records),
                    'PDF',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(sheet);
                  _run(
                    context,
                    () => ExcelService.exportAndShareRecords(records),
                    'Excel',
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
  );
}

Future<void> _run(
  BuildContext context,
  Future<void> Function() task,
  String label,
) async {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('Creating $label...')));
  try {
    await task();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label export failed: $e')));
    }
  }
}

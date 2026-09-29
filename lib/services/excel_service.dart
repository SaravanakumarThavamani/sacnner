import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models/scan_record.dart';

class ExcelService {
  static Future<void> exportAndShareRecords(List<ScanRecord> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Scan Data'];

    if (excel.sheets.containsKey('Sheet1') && excel.sheets.length > 1) {
      excel.delete('Sheet1');
    }

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );

    final fieldStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );

    final valueStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );

    _addCell(sheet, 0, 0, 'Field', headerStyle);
    _addCell(sheet, 1, 0, 'Value', headerStyle);

    var row = 1;

    for (final record in records) {
      final fields = _extractFields(record.text);

      for (final field in fields) {
        _addCell(sheet, 0, row, field.name, fieldStyle);

        _addCell(sheet, 1, row, field.value, valueStyle);

        row++;
      }

      if (fields.isNotEmpty) {
        row++;
      }
    }

    sheet.setColumnWidth(0, 35);
    sheet.setColumnWidth(1, 70);

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/scan_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );

    final bytes = excel.encode();

    if (bytes == null) {
      throw Exception('Unable to create Excel file');
    }

    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(
        file.path,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ], text: 'Scanned bill data');
  }

  static void _addCell(
    Sheet sheet,
    int column,
    int row,
    String value, [
    CellStyle? style,
  ]) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row),
    );

    cell.value = TextCellValue(value);

    if (style != null) {
      cell.cellStyle = style;
    }
  }

  static List<_Field> _extractFields(String text) {
    final fields = <_Field>[];

    final lines =
        text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    for (final line in lines) {
      final parts =
          line
              .split('|')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList();

      if (parts.length >= 2) {
        final name = parts.first;
        final value = parts.sublist(1).join(' ');

        if (_isHeader(name, value)) {
          continue;
        }

        fields.add(_Field(name: _cleanFieldName(name), value: value));

        continue;
      }

      final colonMatch = RegExp(r'^(.+?)\s*:\s*(.+)$').firstMatch(line);

      if (colonMatch != null) {
        final name = colonMatch.group(1)!.trim();
        final value = colonMatch.group(2)!.trim();

        if (_isHeader(name, value)) {
          continue;
        }

        fields.add(_Field(name: _cleanFieldName(name), value: value));

        continue;
      }

      final dashMatch = RegExp(r'^(.+?)\s+-\s+(.+)$').firstMatch(line);

      if (dashMatch != null) {
        final name = dashMatch.group(1)!.trim();
        final value = dashMatch.group(2)!.trim();

        if (_isHeader(name, value)) {
          continue;
        }

        fields.add(_Field(name: _cleanFieldName(name), value: value));

        continue;
      }

      final amountMatch = RegExp(
        r'^(.+?)\s+((?:£|€|\$|₹)\s*[-]?[\d,]+(?:\.\d{1,2})?(?:\s*(?:CR|DR))?)$',
        caseSensitive: false,
      ).firstMatch(line);

      if (amountMatch != null) {
        fields.add(
          _Field(
            name: _cleanFieldName(amountMatch.group(1)!.trim()),
            value: amountMatch.group(2)!.trim(),
          ),
        );
      }
    }

    return fields;
  }

  static String _cleanFieldName(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[:\-]+$'), '')
        .trim();
  }

  static bool _isHeader(String name, String value) {
    final combined = '$name $value'.toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    return combined == 'field value' ||
        combined.contains(
          'charge type charge dates quantity price vat charges',
        );
  }
}

class _Field {
  final String name;
  final String value;

  const _Field({required this.name, required this.value});
}

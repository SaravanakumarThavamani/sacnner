import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);

      final recognizedText = await textRecognizer.processImage(inputImage);

      if (recognizedText.blocks.isEmpty) {
        return '';
      }

      final rows = <OcrRow>[];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          if (line.elements.isEmpty) {
            final text = line.text.trim();

            if (text.isNotEmpty) {
              _addLineToRow(
                rows,
                TextLineData(
                  text: text,
                  top: line.boundingBox.top,
                  bottom: line.boundingBox.bottom,
                  left: line.boundingBox.left,
                  right: line.boundingBox.right,
                ),
              );
            }

            continue;
          }

          final elements =
              line.elements
                  .map(
                    (element) => TextElementData(
                      text: element.text.trim(),
                      top: element.boundingBox.top,
                      bottom: element.boundingBox.bottom,
                      left: element.boundingBox.left,
                      right: element.boundingBox.right,
                    ),
                  )
                  .where((element) => element.text.isNotEmpty)
                  .toList();

          elements.sort((a, b) => a.left.compareTo(b.left));

          if (elements.isEmpty) {
            continue;
          }

          final text = _buildPositionAwareLine(elements);

          _addLineToRow(
            rows,
            TextLineData(
              text: text,
              top: line.boundingBox.top,
              bottom: line.boundingBox.bottom,
              left: line.boundingBox.left,
              right: line.boundingBox.right,
            ),
          );
        }
      }

      rows.sort((a, b) => a.centerY.compareTo(b.centerY));

      final result = StringBuffer();

      for (final row in rows) {
        row.lines.sort((a, b) => a.left.compareTo(b.left));

        for (var i = 0; i < row.lines.length; i++) {
          if (i > 0) {
            result.write(' | ');
          }

          result.write(row.lines[i].text);
        }

        result.writeln();
      }

      return result.toString().trim();
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  String _buildPositionAwareLine(List<TextElementData> elements) {
    if (elements.length == 1) {
      return elements.first.text;
    }

    final gaps = <double>[];

    for (var i = 1; i < elements.length; i++) {
      gaps.add(elements[i].left - elements[i - 1].right);
    }

    final positiveGaps = gaps.where((gap) => gap > 0).toList();

    if (positiveGaps.isEmpty) {
      return elements.map((e) => e.text).join(' ');
    }

    positiveGaps.sort();

    final medianGap = positiveGaps[positiveGaps.length ~/ 2];

    final averageHeight =
        elements.fold<double>(0, (sum, element) => sum + element.height) /
        elements.length;

    final columnGap = [
      medianGap * 2.8,
      averageHeight * 1.2,
      14.0,
    ].reduce((a, b) => a > b ? a : b);

    final result = StringBuffer();

    for (var i = 0; i < elements.length; i++) {
      if (i > 0) {
        final gap = elements[i].left - elements[i - 1].right;

        if (gap >= columnGap) {
          result.write(' | ');
        } else {
          result.write(' ');
        }
      }

      result.write(elements[i].text);
    }

    return result.toString().trim();
  }

  void _addLineToRow(List<OcrRow> rows, TextLineData line) {
    OcrRow? matchedRow;

    for (final row in rows) {
      final distance = (line.centerY - row.centerY).abs();

      final tolerance = ((line.height + row.averageHeight) / 2) * 0.65;

      if (distance <= tolerance) {
        matchedRow = row;
        break;
      }
    }

    if (matchedRow != null) {
      matchedRow.add(line);
    } else {
      rows.add(OcrRow(line));
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}

class TextElementData {
  final String text;
  final double top;
  final double bottom;
  final double left;
  final double right;

  TextElementData({
    required this.text,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  double get height => bottom - top;
}

class TextLineData {
  final String text;
  final double top;
  final double bottom;
  final double left;
  final double right;

  TextLineData({
    required this.text,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  double get height => bottom - top;

  double get centerY => (top + bottom) / 2;
}

class OcrRow {
  final List<TextLineData> lines = [];

  OcrRow(TextLineData firstLine) {
    lines.add(firstLine);
  }

  void add(TextLineData line) {
    lines.add(line);
  }

  double get centerY {
    if (lines.isEmpty) {
      return 0;
    }

    return lines.fold<double>(0, (sum, line) => sum + line.centerY) /
        lines.length;
  }

  double get averageHeight {
    if (lines.isEmpty) {
      return 10;
    }

    return lines.fold<double>(0, (sum, line) => sum + line.height) /
        lines.length;
  }
}

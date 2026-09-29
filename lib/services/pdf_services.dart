import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/scan_record.dart';

class PdfService {
  static Future<void> exportAndShareRecords(List<ScanRecord> records) async {
    if (records.isEmpty) {
      throw Exception('No documents available to export');
    }

    // Built-in fonts — no asset files required
    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    for (int i = 0; i < records.length; i++) {
      final record = records[i];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) {
            return [
              pw.Text(
                'Scanwoo',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Document ${i + 1}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Scanned Date: ${record.createdAt}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text(
                'Extracted Text',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (record.text.trim().isEmpty)
                pw.Text(
                  'No extracted text available.',
                  style: pw.TextStyle(fontSize: 11),
                )
              else
                pw.Paragraph(
                  text: record.text,
                  style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
                ),
            ];
          },
        ),
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/scan_history.pdf');
    final pdfBytes = await pdf.save();

    await file.writeAsBytes(pdfBytes, flush: true);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Scanwoo - Scan History PDF');
  }
}

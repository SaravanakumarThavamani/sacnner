// class ScanRecord {
//   final String text;
//   final String imagePath;
//   final DateTime createdAt;

//   ScanRecord({
//     required this.text,
//     required this.imagePath,
//     required this.createdAt,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'text': text,
//       'imagePath': imagePath,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }

//   factory ScanRecord.fromJson(Map<String, dynamic> json) {
//     return ScanRecord(
//       text: json['text'] ?? '',
//       imagePath: json['imagePath'] ?? '',
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }
class ScanRecord {
  final String text;
  final String imagePath;
  final DateTime createdAt;
  final String? supplier;
  final String? vatNumber;
  final String? invoiceNo;
  final String? branch;
  final String? date;
  final double? net;
  final double? vat;
  final double? gross;
  final int sr;
  final int zr;
  final int exempt;
  final String? payment;
  final String extractionMethod;
  final String ocrStatus;
  final String status;

  ScanRecord({
    required this.text,
    required this.imagePath,
    required this.createdAt,
    this.supplier,
    this.vatNumber,
    this.invoiceNo,
    this.branch,
    this.date,
    this.net,
    this.vat,
    this.gross,
    this.sr = 0,
    this.zr = 0,
    this.exempt = 0,
    this.payment,
    this.extractionMethod = 'ai',
    this.ocrStatus = 'complete',
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'supplier': supplier,
      'vat_number': vatNumber,
      'invoice_no': invoiceNo,
      'branch': branch,
      'date': date,
      'net': net,
      'vat': vat,
      'gross': gross,
      'sr': sr,
      'zr': zr,
      'exempt': exempt,
      'payment': payment,
      'extraction_method': extractionMethod,
      'ocr_status': ocrStatus,
      'status': status,
    };
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      text: json['text'] ?? '',
      imagePath: json['imagePath'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      supplier: json['supplier'],
      vatNumber: json['vat_number'],
      invoiceNo: json['invoice_no'],
      branch: json['branch'],
      date: json['date'],
      net: (json['net'] as num?)?.toDouble(),
      vat: (json['vat'] as num?)?.toDouble(),
      gross: (json['gross'] as num?)?.toDouble(),
      sr: json['sr'] ?? 0,
      zr: json['zr'] ?? 0,
      exempt: json['exempt'] ?? 0,
      payment: json['payment'],
      extractionMethod: json['extraction_method'] ?? 'ai',
      ocrStatus: json['ocr_status'] ?? 'complete',
      status: json['status'] ?? 'pending',
    );
  }
}

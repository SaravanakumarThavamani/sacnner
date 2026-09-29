double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
}

class InvoiceModel {
  final int id;
  final String supplier;
  final String vatNumber;
  final String invoiceNo;
  final String payment;
  final String status;
  final String ocrStatus;
  final String uploadedAt;
  final double net;
  final double vat;
  final double gross;
  final bool needsReview;
  final List<InvoiceItem> items;
  final List<InvoiceImage> images;

  InvoiceModel({
    required this.id,
    required this.supplier,
    required this.vatNumber,
    required this.invoiceNo,
    required this.payment,
    required this.status,
    required this.ocrStatus,
    required this.uploadedAt,
    required this.net,
    required this.vat,
    required this.gross,
    required this.needsReview,
    required this.items,
    required this.images,
  });

  String get thumbnail => images.isNotEmpty ? images.first.url : '';

  factory InvoiceModel.fromJson(Map<String, dynamic> j) {
    final fields =
        j['fields'] is Map
            ? Map<String, dynamic>.from(j['fields'])
            : <String, dynamic>{};
    return InvoiceModel(
      id: j['id'] ?? 0,
      supplier: (j['supplier'] ?? '—').toString(),
      vatNumber: (j['vat_number'] ?? '').toString(),
      invoiceNo: (j['invoice_no'] ?? '—').toString(),
      payment: (j['payment'] ?? '—').toString(),
      status: (j['status'] ?? '').toString(),
      ocrStatus: (j['ocr_status'] ?? '').toString(),
      uploadedAt: (j['uploaded_at'] ?? '').toString(),
      net: _toDouble(j['net']),
      vat: _toDouble(j['vat']),
      gross: _toDouble(j['gross']),
      needsReview: fields['needs_review'] == true,
      items:
          (fields['items'] is List)
              ? (fields['items'] as List)
                  .map(
                    (e) => InvoiceItem.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : [],
      images:
          (j['images'] is List)
              ? (j['images'] as List)
                  .map(
                    (e) => InvoiceImage.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : [],
    );
  }
}

class InvoiceItem {
  final String qty, description, amount, vat, total;
  final bool needsReview;

  InvoiceItem({
    required this.qty,
    required this.description,
    required this.amount,
    required this.vat,
    required this.total,
    required this.needsReview,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> j) => InvoiceItem(
    qty: (j['qty'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    amount: (j['amount'] ?? '').toString(),
    vat: (j['vat'] ?? '').toString(),
    total: (j['total'] ?? '').toString(),
    needsReview: j['needs_review'] == 'Yes',
  );
}

class InvoiceImage {
  final int id;
  final String url;
  final bool isViewed;

  InvoiceImage({required this.id, required this.url, required this.isViewed});

  factory InvoiceImage.fromJson(Map<String, dynamic> j) => InvoiceImage(
    id: j['id'] ?? 0,
    url: (j['url'] ?? '').toString(),
    isViewed: j['is_viewed'] == true,
  );
}

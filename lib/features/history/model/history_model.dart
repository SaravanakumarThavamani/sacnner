// To parse this JSON data, do
//
//     final invoiceList = invoiceListFromJson(jsonString);

import 'dart:convert';

InvoiceList invoiceListFromJson(String str) =>
    InvoiceList.fromJson(json.decode(str));

String invoiceListToJson(InvoiceList data) => json.encode(data.toJson());

class InvoiceList {
  bool success;
  List<InvoiceData> data;
  Meta meta;

  InvoiceList({required this.success, required this.data, required this.meta});

  factory InvoiceList.fromJson(Map<String, dynamic> json) => InvoiceList(
    success: json["success"],
    data: List<InvoiceData>.from(
      json["data"].map((x) => InvoiceData.fromJson(x)),
    ),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta.toJson(),
  };
}

class InvoiceData {
  int id;
  String supplier;
  VatNumber vatNumber;
  String invoiceNo;
  String branch;
  dynamic date;
  double net;
  int? vat;
  double gross;
  dynamic sr;
  dynamic zr;
  dynamic exempt;
  Payment payment;
  OcrStatus ocrStatus;
  Status status;
  DateTime uploadedAt;
  Fields fields;
  List<Image> images;
  int imagesUnviewedCount;

  InvoiceData({
    required this.id,
    required this.supplier,
    required this.vatNumber,
    required this.invoiceNo,
    required this.branch,
    required this.date,
    required this.net,
    required this.vat,
    required this.gross,
    required this.sr,
    required this.zr,
    required this.exempt,
    required this.payment,
    required this.ocrStatus,
    required this.status,
    required this.uploadedAt,
    required this.fields,
    required this.images,
    required this.imagesUnviewedCount,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
    id: json["id"],
    supplier: json["supplier"],
    vatNumber: vatNumberValues.map[json["vat_number"]]!,
    invoiceNo: json["invoice_no"],
    branch: json["branch"],
    date: json["date"],
    net: json["net"]?.toDouble(),
    vat: json["vat"],
    gross: json["gross"]?.toDouble(),
    sr: json["sr"],
    zr: json["zr"],
    exempt: json["exempt"],
    payment: paymentValues.map[json["payment"]]!,
    ocrStatus: ocrStatusValues.map[json["ocr_status"]]!,
    status: statusValues.map[json["status"]]!,
    uploadedAt: DateTime.parse(json["uploaded_at"]),
    fields: Fields.fromJson(json["fields"]),
    images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
    imagesUnviewedCount: json["images_unviewed_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "supplier": supplier,
    "vat_number": vatNumberValues.reverse[vatNumber],
    "invoice_no": invoiceNo,
    "branch": branch,
    "date": date,
    "net": net,
    "vat": vat,
    "gross": gross,
    "sr": sr,
    "zr": zr,
    "exempt": exempt,
    "payment": paymentValues.reverse[payment],
    "ocr_status": ocrStatusValues.reverse[ocrStatus],
    "status": statusValues.reverse[status],
    "uploaded_at":
        "${uploadedAt.year.toString().padLeft(4, '0')}-${uploadedAt.month.toString().padLeft(2, '0')}-${uploadedAt.day.toString().padLeft(2, '0')}",
    "fields": fields.toJson(),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "images_unviewed_count": imagesUnviewedCount,
  };
}

class Fields {
  String? rawText;
  ParsedHeader? parsedHeader;
  List<Item>? items;
  bool? needsReview;
  String? paymentDetails;
  String? accountName;
  String? accountNumber;
  String? ifscCode;
  String? branch;
  String? paymentTerms;
  String? subtotal;
  String? billTo;
  String? shipToIfDifferent;
  String? email;

  Fields({
    this.rawText,
    this.parsedHeader,
    this.items,
    this.needsReview,
    this.paymentDetails,
    this.accountName,
    this.accountNumber,
    this.ifscCode,
    this.branch,
    this.paymentTerms,
    this.subtotal,
    this.billTo,
    this.shipToIfDifferent,
    this.email,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
    rawText: json["raw_text"],
    parsedHeader:
        json["parsed_header"] == null
            ? null
            : ParsedHeader.fromJson(json["parsed_header"]),
    items:
        json["items"] == null
            ? []
            : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    needsReview: json["needs_review"],
    paymentDetails: json["Payment Details"],
    accountName: json["Account Name"],
    accountNumber: json["Account Number"],
    ifscCode: json["IFSC Code"],
    branch: json["Branch"],
    paymentTerms: json["Payment Terms"],
    subtotal: json["Subtotal"],
    billTo: json["Bill To"],
    shipToIfDifferent: json["Ship To (If Different)"],
    email: json["Email"],
  );

  Map<String, dynamic> toJson() => {
    "raw_text": rawText,
    "parsed_header": parsedHeader?.toJson(),
    "items":
        items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "needs_review": needsReview,
    "Payment Details": paymentDetails,
    "Account Name": accountName,
    "Account Number": accountNumber,
    "IFSC Code": ifscCode,
    "Branch": branch,
    "Payment Terms": paymentTerms,
    "Subtotal": subtotal,
    "Bill To": billTo,
    "Ship To (If Different)": shipToIfDifferent,
    "Email": email,
  };
}

class Item {
  String qty;
  String description;
  String amount;
  Vat vat;
  String total;
  String rawOcrLine;
  NeedsReview needsReview;

  Item({
    required this.qty,
    required this.description,
    required this.amount,
    required this.vat,
    required this.total,
    required this.rawOcrLine,
    required this.needsReview,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    qty: json["qty"],
    description: json["description"],
    amount: json["amount"],
    vat: vatValues.map[json["vat"]]!,
    total: json["total"],
    rawOcrLine: json["raw_ocr_line"],
    needsReview: needsReviewValues.map[json["needs_review"]]!,
  );

  Map<String, dynamic> toJson() => {
    "qty": qty,
    "description": description,
    "amount": amount,
    "vat": vatValues.reverse[vat],
    "total": total,
    "raw_ocr_line": rawOcrLine,
    "needs_review": needsReviewValues.reverse[needsReview],
  };
}

enum NeedsReview { NO, YES }

final needsReviewValues = EnumValues({
  "No": NeedsReview.NO,
  "Yes": NeedsReview.YES,
});

enum Vat { EMPTY, THE_799 }

final vatValues = EnumValues({"": Vat.EMPTY, "7.99": Vat.THE_799});

class ParsedHeader {
  String companyName;
  String? totalVat;
  Payment? paymentTerms;
  VatNumber? vatNumber;
  String? invoiceNo;
  String? invoiceDate;
  String? accountNo;
  String? subTotal;
  String? grandTotal;
  String? previousBalance;

  ParsedHeader({
    required this.companyName,
    this.totalVat,
    this.paymentTerms,
    this.vatNumber,
    this.invoiceNo,
    this.invoiceDate,
    this.accountNo,
    this.subTotal,
    this.grandTotal,
    this.previousBalance,
  });

  factory ParsedHeader.fromJson(Map<String, dynamic> json) => ParsedHeader(
    companyName: json["company_name"],
    totalVat: json["total_vat"],
    paymentTerms: paymentValues.map[json["payment_terms"]],
    vatNumber: vatNumberValues.map[json["vat_number"]],
    invoiceNo: json["invoice_no"],
    invoiceDate: json["invoice_date"],
    accountNo: json["account_no"],
    subTotal: json["sub_total"],
    grandTotal: json["grand_total"],
    previousBalance: json["previous_balance"],
  );

  Map<String, dynamic> toJson() => {
    "company_name": companyName,
    "total_vat": totalVat,
    "payment_terms": paymentValues.reverse[paymentTerms],
    "vat_number": vatNumberValues.reverse[vatNumber],
    "invoice_no": invoiceNo,
    "invoice_date": invoiceDate,
    "account_no": accountNo,
    "sub_total": subTotal,
    "grand_total": grandTotal,
    "previous_balance": previousBalance,
  };
}

enum Payment { CARD, CASH, EMPTY }

final paymentValues = EnumValues({
  "Card": Payment.CARD,
  "Cash": Payment.CASH,
  "—": Payment.EMPTY,
});

enum VatNumber { EMPTY, THE_94_SZ017 }

final vatNumberValues = EnumValues({
  "": VatNumber.EMPTY,
  "94SZ017": VatNumber.THE_94_SZ017,
});

class Image {
  int id;
  String filePath;
  String url;
  String originalName;
  MimeType mimeType;
  ExtractedData extractedData;
  OcrStatus ocrStatus;
  int size;
  int sortOrder;
  bool isViewed;
  dynamic viewedAt;

  Image({
    required this.id,
    required this.filePath,
    required this.url,
    required this.originalName,
    required this.mimeType,
    required this.extractedData,
    required this.ocrStatus,
    required this.size,
    required this.sortOrder,
    required this.isViewed,
    required this.viewedAt,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    id: json["id"],
    filePath: json["file_path"],
    url: json["url"],
    originalName: json["original_name"],
    mimeType: mimeTypeValues.map[json["mime_type"]]!,
    extractedData: ExtractedData.fromJson(json["extracted_data"]),
    ocrStatus: ocrStatusValues.map[json["ocr_status"]]!,
    size: json["size"],
    sortOrder: json["sort_order"],
    isViewed: json["is_viewed"],
    viewedAt: json["viewed_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file_path": filePath,
    "url": url,
    "original_name": originalName,
    "mime_type": mimeTypeValues.reverse[mimeType],
    "extracted_data": extractedData.toJson(),
    "ocr_status": ocrStatusValues.reverse[ocrStatus],
    "size": size,
    "sort_order": sortOrder,
    "is_viewed": isViewed,
    "viewed_at": viewedAt,
  };
}

class ExtractedData {
  String rawText;

  ExtractedData({required this.rawText});

  factory ExtractedData.fromJson(Map<String, dynamic> json) =>
      ExtractedData(rawText: json["raw_text"]);

  Map<String, dynamic> toJson() => {"raw_text": rawText};
}

enum MimeType { APPLICATION_OCTET_STREAM }

final mimeTypeValues = EnumValues({
  "application/octet-stream": MimeType.APPLICATION_OCTET_STREAM,
});

enum OcrStatus { COMPLETE }

final ocrStatusValues = EnumValues({"complete": OcrStatus.COMPLETE});

enum Status { PENDING }

final statusValues = EnumValues({"pending": Status.PENDING});

class Meta {
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  Meta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

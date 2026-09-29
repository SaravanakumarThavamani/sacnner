// To parse this JSON data, do
//
//     final dashboard = dashboardFromJson(jsonString);

import 'dart:convert';

Dashboard dashboardFromJson(String str) => Dashboard.fromJson(json.decode(str));

String dashboardToJson(Dashboard data) => json.encode(data.toJson());

class Dashboard {
  bool success;
  Data data;

  Dashboard({required this.success, required this.data});

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      Dashboard(success: json["success"], data: Data.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
}

class Data {
  Client client;
  Stats stats;
  VatSummary vatSummary;

  Data({required this.client, required this.stats, required this.vatSummary});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    client: Client.fromJson(json["client"]),
    stats: Stats.fromJson(json["stats"]),
    vatSummary: VatSummary.fromJson(json["vat_summary"]),
  );

  Map<String, dynamic> toJson() => {
    "client": client.toJson(),
    "stats": stats.toJson(),
    "vat_summary": vatSummary.toJson(),
  };
}

class Client {
  int id;
  String name;
  String email;

  Client({required this.id, required this.name, required this.email});

  factory Client.fromJson(Map<String, dynamic> json) =>
      Client(id: json["id"], name: json["name"], email: json["email"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}

class Stats {
  int invoicesThisMonth;
  int pending;
  int vatThisQuarter;
  int invoicesChange;

  Stats({
    required this.invoicesThisMonth,
    required this.pending,
    required this.vatThisQuarter,
    required this.invoicesChange,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    invoicesThisMonth: json["invoices_this_month"],
    pending: json["pending"],
    vatThisQuarter: json["vat_this_quarter"],
    invoicesChange: json["invoices_change"],
  );

  Map<String, dynamic> toJson() => {
    "invoices_this_month": invoicesThisMonth,
    "pending": pending,
    "vat_this_quarter": vatThisQuarter,
    "invoices_change": invoicesChange,
  };
}

class VatSummary {
  int box4;
  int box7;
  String period;

  VatSummary({required this.box4, required this.box7, required this.period});

  factory VatSummary.fromJson(Map<String, dynamic> json) => VatSummary(
    box4: json["box4"],
    box7: json["box7"],
    period: json["period"],
  );

  Map<String, dynamic> toJson() => {
    "box4": box4,
    "box7": box7,
    "period": period,
  };
}

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quick_scanner/features/history/data/history_resp_imp.dart';
import 'package:quick_scanner/features/history/data/history_respostires.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';
import 'package:quick_scanner/networks/api_status.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:quick_scanner/networks/data_service.dart';
import 'package:quick_scanner/utils/common_color.dart';
import 'package:quick_scanner/utils/const.dart';

class HistoryController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final invoices = <InvoiceData>[].obs;
  final meta = Rxn<Meta>();
  final tokenDataService = Get.find<TokenDataServiceImp>();

  final query = ''.obs;
  final filter = 'All'.obs;

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final HistoryRespostires _repo = HistoryRespostiresImp();

  bool get hasMore =>
      (meta.value?.currentPage ?? 1) < (meta.value?.lastPage ?? 1);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      final p = scrollController.position;
      if (p.pixels >= p.maxScrollExtent - 200) loadMore();
    });
    fetchInvoices();
    fetchRecent();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  final isExporting = false.obs;

  // Prefer the invoice-level raw_text, fall back to the per-image OCR text
  String rawTextOf(InvoiceData inv) {
    final top = inv.fields.rawText?.trim() ?? '';
    if (top.isNotEmpty) return top;
    return inv.images
        .map((i) => i.extractedData.rawText.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');
  }

  // Loops through every page so the export contains all invoices, not just one page
  Future<List<InvoiceData>> fetchAllInvoices() async {
    final all = <InvoiceData>[];
    var page = 1;
    var last = 1;
    try {
      do {
        final result = await _repo.invoiceList();
        if (result is! SuccessStatus) break;
        final list = invoiceListFromJson(result.responseStr);
        all.addAll(list.data);
        last = list.meta.lastPage;
        page++;
      } while (page <= last);
    } catch (e, s) {
      log('Export fetch error: $e\n$s');
    }
    return all;
  }

  Future<void> downloadInvoicePdf(int invoiceId) async {
    final url = Uri.parse('${APICalls.baseUrl}/invoices/$invoiceId/download');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${tokenDataService.accessToken}',
          'Accept': 'application/pdf, text/csv, */*',
        },
      );

      if (response.statusCode != 200) {
        print('Download failed: ${response.statusCode} ${response.body}');
        return;
      }

      final bytes = response.bodyBytes;
      final contentType = response.headers['content-type'] ?? '';

      // A real PDF always starts with "%PDF"
      final isPdf =
          bytes.length > 4 && String.fromCharCodes(bytes.take(4)) == '%PDF';

      final ext = isPdf ? 'pdf' : 'csv';

      print('Content-Type: $contentType');
      print('Size: ${bytes.length} bytes');
      print('Detected: $ext');

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice-$invoiceId.$ext');
      await file.writeAsBytes(bytes);

      final result = await OpenFilex.open(file.path);
      print('Open result: ${result.type} ${result.message}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchInvoices() async {
    isLoading.value = true;
    try {
      final result = await _repo.invoiceList();
      if (result is SuccessStatus) {
        final list = invoiceListFromJson(result.responseStr);
        invoices.assignAll(list.data);
        meta.value = list.meta;
      }
    } catch (e, s) {
      log('Invoice parse error: $e\n$s');
    } finally {
      isLoading.value = false;
    }
  }

  final recent = <InvoiceData>[].obs;
  final recentTotal = 0.obs;
  final isRecentLoading = false.obs;

  Future<void> fetchRecent() async {
    isRecentLoading.value = true;
    try {
      final result = await _repo.invoiceList();
      if (result is SuccessStatus) {
        final list = invoiceListFromJson(result.responseStr);
        recent.assignAll(list.data.take(4));
        recentTotal.value = list.meta.total;
      }
    } catch (e, s) {
      log('Recent invoices error: $e\n$s');
    } finally {
      isRecentLoading.value = false;
    }
  }

  Future<void> updateRawText(int id, String text) async {
    final res = await http.patch(
      Uri.parse('https://scanwoo.com/api/invoices/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${tokenDataService.accessToken}',
      },
      body: jsonEncode({'extracted_data': text}),
    );

    debugPrint('Update ${res.statusCode}: ${res.body}');
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: const Text("Invoice updated successfully."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // ScaffoldMessenger.of(Get.context!).showSnackBar(
      //   SnackBar(
      //     content: Center(
      //       child: Text(
      //         "Invoice updated successfully.",
      //         style: TextStyle(fontSize: 10),
      //       ),
      //     ),
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.only(bottom: 10, left: 100, right: 100),
      //     duration: Duration(seconds: 2),
      //     backgroundColor: ColorConstants.black,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10),
      //     ),
      //   ),
      // );
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    }

    await Future.wait([fetchInvoices(), fetchRecent()]);
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    try {
      final next = (meta.value?.currentPage ?? 1) + 1;
      final result = await _repo.invoiceList();
      if (result is SuccessStatus) {
        final list = invoiceListFromJson(result.responseStr);
        invoices.addAll(list.data);
        meta.value = list.meta;
      }
    } catch (e, s) {
      log('Load more error: $e\n$s');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void setQuery(String v) => query.value = v;

  void clearSearch() {
    searchController.clear();
    query.value = '';
  }

  void deleteInvoice(int id) {
    invoices.removeWhere((e) => e.id == id);
  }

  List<InvoiceData> get filtered {
    final now = DateTime.now();
    final search = query.value.trim().toLowerCase();

    return invoices.where((inv) {
      if (search.isNotEmpty) {
        final hay =
            '${inv.supplier} ${inv.invoiceNo} ${inv.branch} '
                    '${inv.fields.rawText ?? ''}'
                .toLowerCase();
        if (!hay.contains(search)) return false;
      }
      final days = now.difference(inv.uploadedAt).inDays;
      switch (filter.value) {
        case 'Today':
          return days == 0;
        case 'This Week':
          return days >= 0 && days <= 7;
        case 'This Month':
          return days >= 0 && days <= 30;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, List<InvoiceData>> grouped(List<InvoiceData> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(const Duration(days: 7));

    final groups = <String, List<InvoiceData>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final inv in list) {
      final d = inv.uploadedAt.toLocal();
      final day = DateTime(d.year, d.month, d.day);
      if (day == today) {
        groups['Today']!.add(inv);
      } else if (day == yesterday) {
        groups['Yesterday']!.add(inv);
      } else if (day.isAfter(weekStart)) {
        groups['This Week']!.add(inv);
      } else {
        groups['Earlier']!.add(inv);
      }
    }
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }
}

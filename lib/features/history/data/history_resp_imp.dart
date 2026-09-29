import 'package:quick_scanner/features/history/data/history_respostires.dart';
import 'package:quick_scanner/networks/api_services.dart';
import 'package:quick_scanner/utils/const.dart';

// class HistoryRespostiresImp extends HistoryRespostires {
//   final ApiServices _apiServices = ApiServices();

//   @override
//   Future<dynamic> invoiceList() async {
//     final url = "${APICalls.baseUrl}/invoices-list";
//     final response = await _apiServices.getService(url);
//     return response;
//   }
// }
class HistoryRespostiresImp extends HistoryRespostires {
  final ApiServices _apiServices = ApiServices();

  @override
  Future<dynamic> invoiceList({int page = 1}) async {
    final url = "${APICalls.baseUrl}/invoices-list?page=$page";
    final response = await _apiServices.getService(url);
    return response;
  }

  @override
  Future<dynamic> editinvoice() async {
    final url = "${APICalls.baseUrl}/?page";
    final response = await _apiServices.getService(url);
    return response;
  }
}

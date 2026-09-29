// import 'package:flutter/material.dart';
// import '../models/scan_record.dart';

// class HistoryController extends ChangeNotifier {
//   final bool _isLoading = false;
//   String? _errorMessage;
//   List<ScanRecord> _records = [];
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   List<ScanRecord> get records => _records;
//   bool get isEmpty => !_isLoading && _records.isEmpty;
//   // Future<void> loadHistory(String token) async {
//   //   _isLoading = true;
//   //   _errorMessage = null;
//   //   notifyListeners();

//   //   try {
//   //     _records = await _repository.getHistory(token);
//   //   } catch (e) {
//   //     _errorMessage = e.toString().replaceAll('Exception: ', '');
//   //   } finally {
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }
//   // Future<void> deleteRecord(String token, String recordId) async {
//   //   try {
//   //     _records.removeWhere((r) => r.imagePath == recordId);
//   //     notifyListeners();

//   //     await _repository.deleteRecord(token, recordId);
//   //   } catch (e) {
//   //     _errorMessage = e.toString().replaceAll('Exception: ', '');
//   //     notifyListeners();
//   //   }
//   // }
//   void search(String query) {
//     if (query.isEmpty) {
//       notifyListeners();
//       return;
//     }
//     _records =
//         _records
//             .where((r) => r.text.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//     notifyListeners();
//   }
// }

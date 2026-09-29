import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:quick_scanner/networks/api_status.dart';
import 'package:quick_scanner/utils/common_color.dart';
import 'package:quick_scanner/utils/const.dart';

class HistoryRepository {
  Future<dynamic> uploadInvoiceWithImage({
    required String? token,
    required File imageFile,
    required String extractedData,
  }) async {
    try {
      final uri = Uri.parse(
        "${APICalls.baseUrl}/invoices",
      ); // now https, no redirect expected
      print("Uploading with token 33: $uri");
      final request =
          http.MultipartRequest('POST', uri)
            ..fields['extracted_data'] = extractedData
            ..headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      print("Uploading with token 33: $request");

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      request.files.add(
        http.MultipartFile('images[]', stream, length, filename: fileName),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseBody = await streamedResponse.stream.bytesToString();

      // Clipboard.setData(ClipboardData(text: responseBody.toString()));
      print("Uploading with token 33: ${streamedResponse.statusCode}");

      if (streamedResponse.statusCode == 201) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "Invoice uploaded successfully",
                style: TextStyle(fontSize: 10),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 10, left: 100, right: 100),
            duration: Duration(seconds: 2),
            backgroundColor: ColorConstants.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return SuccessStatus(statusCode: 201, responseStr: responseBody);
      } else {
        return FailureStatus(
          statusCode: streamedResponse.statusCode,
          message: 'Upload failed: $responseBody',
        );
      }
    } catch (e) {
      return FailureStatus(
        statusCode: 100,
        message: 'Network error or timeout: ${e.toString()}',
      );
    }
  }

  Future<List<dynamic>> uploadInvoicesIndividually({
    required String? token,
    required List<File> images,
    required List<String> extractedDataList, // one per image, same order
  }) async {
    assert(images.length == extractedDataList.length);

    final results = <dynamic>[];

    for (int i = 0; i < images.length; i++) {
      final result = await uploadInvoiceWithImage(
        token: token,
        imageFile: images[i],
        extractedData: extractedDataList[i],
      );
      results.add(result);
    }

    return results;
  }
}

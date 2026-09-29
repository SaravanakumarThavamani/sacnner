import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/forget_password/data/repositories/forget_password_resp_imp.dart';
import 'package:quick_scanner/features/forget_password/data/repositories/forgot_password_resp.dart';
import 'package:quick_scanner/networks/api_status.dart';
import 'package:quick_scanner/utils/common_dialog.dart';

import '../../../networks/data_service.dart';

class ForgetPasswordViewModel extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> newpasswordController = TextEditingController().obs;
  RxBool isLoading = false.obs;
  final tokenDataService = Get.find<TokenDataServiceImp>();
  final ForgotPasswordResp _forgetPasswordRespImp = ForgetPasswordRespImp();

  final RxBool hidePassword = true.obs;
  final RxBool hideConfirmPassword = true.obs;
  RxString email = ''.obs;
  RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    email.value = args?["email"] ?? "";
    token.value = args?["token"] ?? "";

    debugPrint("EMAIL => ${email.value}");
    debugPrint("TOKEN => ${token.value}");
  }

  // final RxBool isLoading = false.obs;
  Future<void> clientForgetPassword() async {
    try {
      isLoading.value = true;
      final body = {"email": emailController.value.text};

      final result = await _forgetPasswordRespImp.forgetPassword(body);
      if (result is SuccessStatus) {
        final data = jsonDecode(result.responseStr);
        final message = data['message'];
        await Get.dialog(
          RegisterResultDialog(
            message: message,
            isSuccess: true,
            buttonName: "Ok",
            // redirectRoute: RouteList.login,
          ),
          barrierDismissible: false,
        );
        // await Get.offAllNamed(RouteList.mainscreen);
      } else if (result is FailureStatus) {
        final data = jsonDecode(result.message);
        final message = data['message'];
        await Get.dialog(
          RegisterResultDialog(
            message: message,
            isSuccess: false,
            buttonName: "Ok",
            // redirectRoute: RouteList.login,
          ),
          barrierDismissible: false,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resentPassword() async {
    try {
      isLoading.value = true;

      final body = {
        "email": email.value,
        "password": passwordController.value.text,
        "password_confirmation": newpasswordController.value.text,
        "token": token.value,
      };

      debugPrint("REQUEST BODY => $body");

      final result = await _forgetPasswordRespImp.resetPassword(body);
      debugPrint("REQUEST result => $result");

      if (result is SuccessStatus) {
        final data = jsonDecode(result.responseStr);

        await Get.dialog(
          RegisterResultDialog(
            message: data["message"] ?? "Password reset successful",
            isSuccess: true,
            buttonName: "OK",
          ),
          barrierDismissible: false,
        );
      } else if (result is FailureStatus) {
        debugPrint("REQUEST result => ${result.message}");

        final data = jsonDecode(result.message);
        final message = data['message'];
        await Get.dialog(
          RegisterResultDialog(
            message: message,
            isSuccess: false,
            buttonName: "Ok",
            // redirectRoute: RouteList.login,
          ),
          barrierDismissible: false,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

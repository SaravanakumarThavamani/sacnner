import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/login_screen/repositories/login_repositories.dart';
import 'package:quick_scanner/features/login_screen/repositories/login_repositories_imp.dart';
import 'package:quick_scanner/networks/api_status.dart';
import 'package:quick_scanner/networks/data_service.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/utils/common_dialog.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  final tokenDataService = Get.find<TokenDataServiceImp>();
  RxBool hidePassword = true.obs;
  RxBool rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();

    rememberMe.value = tokenDataService.rememberMe ?? false;

    if (rememberMe.value) {
      emailController.value.text = tokenDataService.savedEmail ?? '';
      passwordController.value.text = tokenDataService.savedPassword ?? '';
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  final LoginRepositories _loginRepositories = LoginRepositoriesImp();
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  void togglePasswordVisibility() {
    hidePassword.toggle();
  }

  Future<void> clientLogin() async {
    try {
      isLoading.value = true;
      final body = {
        "email": emailController.value.text,
        "password": passwordController.value.text,
      };

      final result = await _loginRepositories.clientLogin(body);
      if (result is SuccessStatus) {
        if (rememberMe.value) {
          await tokenDataService.saveRememberMeState(
            remember: rememberMe.value,
            email: emailController.value.text.trim(),
            password: passwordController.value.text,
          );
        } else {
          await tokenDataService.saveRememberMeState(
            remember: false,
            email: '',
            password: '',
          );
        }

        final data = jsonDecode(result.responseStr);
        tokenDataService.accessToken = data["token"];
        tokenDataService.activeUserType = data["user"]["role"];
        tokenDataService.userName = data["user"]["name"];
        tokenDataService.email = data["user"]["email"];

        await Get.offAllNamed(RouteList.mainscreen);
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
}

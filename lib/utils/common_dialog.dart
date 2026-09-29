import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/utils/common_color.dart';
import 'package:quick_scanner/utils/common_text.dart';

class RegisterResultDialog extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final String? buttonName;
  final String? redirectRoute;
  final Map<String, dynamic>? redirectArguments;

  const RegisterResultDialog({
    super.key,
    required this.message,
    required this.isSuccess,
    this.buttonName,
    this.redirectRoute,
    this.redirectArguments,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isSuccess ? const Color(0xFF1D8234) : Colors.red;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * 0.06,
            vertical: Get.height * 0.03,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Get.width * 0.18,
                height: Get.width * 0.18,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  color: statusColor,
                  size: Get.width * 0.09,
                ),
              ),

              SizedBox(height: Get.height * 0.025),

              CommonTextWidgets().textInter(
                text: isSuccess ? "Success" : "Error",
                size: Get.height * 0.022,
                fontWeight: FontWeight.w700,
                color: statusColor,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Get.height * 0.012),

              CommonTextWidgets().textInter(
                text: message,
                size: Get.height * 0.018,
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Get.height * 0.03),

              SizedBox(
                width: double.infinity,
                height: Get.height * 0.055,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSuccess) {
                      if (redirectRoute != null && redirectRoute!.isNotEmpty) {
                        Get.offAllNamed(
                          redirectRoute!,
                          arguments: redirectArguments,
                        );
                      } else {
                        Get.offAllNamed(RouteList.login);
                      }
                      return;
                    }

                    if (redirectRoute != null && redirectRoute!.isNotEmpty) {
                      Get.offAllNamed(
                        redirectRoute!,
                        arguments: redirectArguments,
                      );
                    } else {
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: CommonTextWidgets().textInter(
                    text:
                        buttonName?.isNotEmpty == true
                            ? buttonName!
                            : (isSuccess ? "Back to Login" : "Go Back"),
                    size: Get.height * 0.017,
                    color: ColorConstants.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

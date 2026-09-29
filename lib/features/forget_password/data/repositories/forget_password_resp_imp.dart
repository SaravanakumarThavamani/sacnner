import 'package:quick_scanner/features/forget_password/data/repositories/forgot_password_resp.dart';
import 'package:quick_scanner/networks/api_services.dart';
import 'package:quick_scanner/utils/const.dart';

class ForgetPasswordRespImp extends ForgotPasswordResp {
  final ApiServices _apiServices = ApiServices();
  @override
  Future<dynamic> forgetPassword(Map body) async {
    final url = "${APICalls.clientUrl}/forgot-password";
    final response = await _apiServices.postService(url, body);
    return response;
  }

  @override
  Future<dynamic> resetPassword(Map<dynamic, dynamic> body) async {
    final url = "${APICalls.clientUrl}/reset-password";
    print("Url $url");
    final response = await _apiServices.postService(url, body);
    return response;
  }
}

import 'package:quick_scanner/features/profile/data/profile_resp.dart';
import 'package:quick_scanner/networks/api_services.dart';
import 'package:quick_scanner/utils/const.dart';

class ProfileRepImp extends ProfileResp {
  final ApiServices _apiServices = ApiServices();
  @override
  Future<dynamic> changePassword(Map body) async {
    final url = "${APICalls.clientUrl}/change-password";
    final response = await _apiServices.postService(url, body);
    return response;
  }

  @override
  Future<dynamic> deleteAccount(Map body) async {
    final url = "${APICalls.clientUrl}/account";
    final response = await _apiServices.deleteServices(url, body);
    return response;
  }

  @override
  Future<dynamic> upadteProfile(Map body) async {
    final url = "${APICalls.clientUrl}/profile";
    final response = await _apiServices.putService(url, body);
    return response;
  }

  @override
  Future<dynamic> dashborad() async {
    final url = "${APICalls.clientUrl}/dashboard";
    final response = await _apiServices.getService(url);
    return response;
  }
}

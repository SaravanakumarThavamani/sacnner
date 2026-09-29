import 'package:quick_scanner/features/login_screen/repositories/login_repositories.dart';
import 'package:quick_scanner/networks/api_services.dart';

import '../../../utils/const.dart';

class LoginRepositoriesImp extends LoginRepositories {
  final ApiServices _apiServices = ApiServices();

  @override
  clientLogin(Map body) async {
    final url = "${APICalls.clientUrl}/login";
    final resposne = await _apiServices.postService(url, body);
    return resposne;
  }
}

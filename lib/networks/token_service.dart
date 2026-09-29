import 'package:get/get.dart';

class TokenService extends GetxController {
  RxString accessToken = "".obs;

  Future getAccesstoken() async {
    accessToken.value =  "";
    return accessToken.value;
  }

  
}

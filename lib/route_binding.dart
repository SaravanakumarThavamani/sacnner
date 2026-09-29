import 'package:get/get.dart';
import 'package:quick_scanner/features/forget_password/logic/forget_password_view_model.dart';
import 'package:quick_scanner/features/forget_password/screen/forget_password_screen.dart';
import 'package:quick_scanner/features/forget_password/screen/reset_password_screen.dart';
import 'package:quick_scanner/features/login_screen/screen/login_screen.dart';
import 'package:quick_scanner/features/profile/change_password.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/features/home/mainscreen.dart';
import 'package:quick_scanner/features/splash/splash_screen.dart';

class Routes {
  static final routes = [
    GetPage(
      name: RouteList.inital,
      page: () => SplashScreen(),
      // binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: RouteList.forgetpassword,
      page: () => ForgetPasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgetPasswordViewModel()),
      ),
    ),
    GetPage(
      name: RouteList.resetPassword,
      page: () => ResetPasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgetPasswordViewModel()),
      ),
    ),
    GetPage(
      name: RouteList.changepassword,
      page: () => ProfileChangePasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgetPasswordViewModel()),
      ),
    ),
    //home
    GetPage(
      name: RouteList.login,
      page: () => LoginScreen(),
      // binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: RouteList.mainscreen,
      page: () => MainScreen(),
      // binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
  ];
}

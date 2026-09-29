import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/login_screen/logic/login_controller.dart';
import 'package:quick_scanner/routes_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());

  final GlobalKey<FormState> _loginkey = GlobalKey<FormState>();

  static const primary = Color(0xFF5146F5);
  static const primaryDark = Color(0xFF3E35D6);
  static const primaryLight = Color(0xFF7A70FF);
  static const textColor = Color(0xFF25254A);
  static const hintColor = Color(0xFF9696A8);
  static const borderColor = Color(0xFFE2E2EA);
  static const bgColor = Color(0xFFF6F6FC);
  static const fieldFill = Color(0xFFF8F9FD);

  // void message(String text) {
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(
  //       SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  //     );
  // }

  InputDecoration decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintColor, fontSize: 13.5),
      prefixIcon: Icon(icon, size: 19, color: hintColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Soft decorative gradient blobs for depth, consistent with the
          // rest of the auth flow.
          Positioned(
            top: -70,
            right: -60,
            child: _blob(220, primaryLight.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: -110,
            left: -70,
            child: _blob(240, primary.withValues(alpha: 0.08)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _loginkey,
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 28),
                      // Logo mark
                      Center(
                        child: SizedBox(
                          width: Get.width * 0.22,
                          height: Get.width * 0.22,
                          child: Padding(
                            padding: EdgeInsets.all(Get.width * 0.01),
                            child: Image.asset(
                              "assets/images/invoice_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 4),
                      const Text(
                        'Scanwoo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scan. Extract. Organize.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: hintColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Card container for the form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.07),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sign in to continue',
                              style: TextStyle(fontSize: 13, color: hintColor),
                            ),
                            const SizedBox(height: 26),

                            const Text(
                              'EMAIL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: hintColor,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller:
                                  _loginController.emailController.value,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              decoration: decoration(
                                'you@example.com',
                                Icons.mail_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 18),

                            const Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: hintColor,
                              ),
                            ),
                            const SizedBox(height: 7),
                            TextFormField(
                              controller:
                                  _loginController.passwordController.value,
                              obscureText: _loginController.hidePassword.value,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Include at least one uppercase letter';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Include at least one lowercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Include at least one number';
                                }
                                if (!RegExp(
                                  r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]/;~`]',
                                ).hasMatch(value)) {
                                  return 'Include at least one special character';
                                }
                                return null;
                              },
                              decoration: decoration(
                                'Enter your password',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  icon: Icon(
                                    _loginController.hidePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: hintColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _loginController.hidePassword.toggle();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Checkbox(
                                    value: _loginController.rememberMe.value,
                                    activeColor: primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    onChanged:
                                        _loginController.toggleRememberMe,
                                  ),
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Get.toNamed(RouteList.forgetpassword);
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: LinearGradient(
                                    colors:
                                        _loginController.isLoading.value
                                            ? [
                                              primary.withValues(alpha: 0.6),
                                              primaryDark.withValues(
                                                alpha: 0.6,
                                              ),
                                            ]
                                            : const [primary, primaryDark],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow:
                                      _loginController.isLoading.value
                                          ? null
                                          : [
                                            BoxShadow(
                                              color: primary.withValues(
                                                alpha: 0.32,
                                              ),
                                              blurRadius: 18,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (_loginkey.currentState!.validate()) {
                                      _loginController.clientLogin();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child:
                                      _loginController.isLoading.value
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // const SizedBox(height: 28),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Text(
                      //       "Don't have an account? ",
                      //       style: TextStyle(color: hintColor, fontSize: 13),
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (_) => const RegisterScreen(),
                      //           ),
                      //         );
                      //       },
                      //       child: const Text(
                      //         'Sign Up',
                      //         style: TextStyle(
                      //           color: primary,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 13,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

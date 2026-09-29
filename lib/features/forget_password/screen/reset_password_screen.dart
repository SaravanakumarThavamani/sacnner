import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/forget_password/logic/forget_password_view_model.dart';
import 'package:quick_scanner/routes_list.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ForgetPasswordViewModel _passwordViewModel = Get.put(
    ForgetPasswordViewModel(),
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ---- Design tokens (matches ForgetPasswordScreen / LoginScreen) ------
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryDark = Color(0xFF4338CA); // indigo-700
  static const Color primaryLight = Color(0xFF7C74F0); // lighter accent
  static const Color textPrimary = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color fieldFill = Color(0xFFF9FAFB); // gray-50
  static const Color scaffoldBg = Color(0xFFF3F4F6); // gray-100

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String email = args["email"] ?? "";
    final String token = args["token"] ?? '';

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Soft decorative gradient blobs, consistent with the rest of
          // the auth flow.
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          // Single Obx around the whole card is enough — nesting a
                          // second Obx inside it (as the previous version did)
                          // left the outer one with nothing reactive to track,
                          // which is what triggered the "improper use of GetX"
                          // error.
                          child: Obx(() => _buildCard(email)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String email) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: 22),
          _buildHeader(email),
          const SizedBox(height: 32),
          _buildPasswordField(),
          const SizedBox(height: 18),
          _buildConfirmPasswordField(),
          const SizedBox(height: 26),
          _buildSubmitButton(),
          const SizedBox(height: 16),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: .14),
              primaryLight.withValues(alpha: .06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_reset_rounded, color: primary, size: 34),
      ),
    );
  }

  Widget _buildHeader(String email) {
    return Column(
      children: [
        const Text(
          "Reset password",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text.rich(
            TextSpan(
              text: "Setting a new password for ",
              style: const TextStyle(
                fontSize: 13.5,
                color: textSecondary,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool obscured,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: textSecondary,
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: textSecondary,
        ),
      ),
      filled: true,
      fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NEW PASSWORD",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordViewModel.passwordController.value,
          obscureText: _passwordViewModel.hidePassword.value,
          style: const TextStyle(
            fontSize: 14.5,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter a password";
            }
            if (value.length < 8) {
              return "Must be at least 8 characters";
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return "Include at least one uppercase letter";
            }
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return "Include at least one lowercase letter";
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return "Include at least one digit";
            }
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return "Include at least one special character";
            }
            return null;
          },
          decoration: _fieldDecoration(
            hint: "Enter new password",
            obscured: _passwordViewModel.hidePassword.value,
            onToggle: () => _passwordViewModel.hidePassword.toggle(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CONFIRM PASSWORD",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordViewModel.newpasswordController.value,
          obscureText: _passwordViewModel.hideConfirmPassword.value,
          style: const TextStyle(
            fontSize: 14.5,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please confirm your password";
            }
            if (value != _passwordViewModel.passwordController.value.text) {
              return "Passwords do not match";
            }
            return null;
          },
          decoration: _fieldDecoration(
            hint: "Re-enter new password",
            obscured: _passwordViewModel.hideConfirmPassword.value,
            onToggle: () => _passwordViewModel.hideConfirmPassword.toggle(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isLoading = _passwordViewModel.isLoading.value;

    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors:
                isLoading
                    ? [
                      primary.withValues(alpha: 0.6),
                      primaryDark.withValues(alpha: 0.6),
                    ]
                    : const [primary, primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow:
              isLoading
                  ? null
                  : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
        ),
        child: ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_formKey.currentState!.validate()) {
                      // Call reset password API here, e.g.:
                      _passwordViewModel.resentPassword();
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.pressed)
                      ? Colors.white.withValues(alpha: 0.1)
                      : null,
            ),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Reset password",
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // SizedBox(width: 8),
                      // Icon(Icons.check_rounded, size: 18),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Get.offAllNamed(RouteList.login),
        style: TextButton.styleFrom(foregroundColor: primary),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
        label: const Text(
          "Back to login",
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
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

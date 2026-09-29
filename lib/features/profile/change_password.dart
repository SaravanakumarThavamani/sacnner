import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/profile/logic/profile_controller.dart';

/// Change password for a logged-in user (from Profile).
/// Styled to match the ForgetPassword / Reset password screens.
class ProfileChangePasswordScreen extends StatefulWidget {
  const ProfileChangePasswordScreen({super.key});

  @override
  State<ProfileChangePasswordScreen> createState() =>
      _ProfileChangePasswordScreenState();
}

class _ProfileChangePasswordScreenState
    extends State<ProfileChangePasswordScreen> {
  final ProfileController _c = Get.put(ProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ---- Design tokens (matches ForgetPasswordScreen / LoginScreen) ------
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF7C74F0);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color fieldFill = Color(0xFFF9FAFB);
  static const Color scaffoldBg = Color(0xFFF3F4F6);

  @override
  void dispose() {
    // Disposes the text controllers via onClose.
    Get.delete<ProfileController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
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
                          child: Obx(() => _buildCard()),
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

  Widget _buildCard() {
    final isLoading = _c.isLoading.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          const Text(
            "Change password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            "Enter your current password and choose a new one",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          _labeledField(
            label: "CURRENT PASSWORD",
            controller: _c.currentController,
            hint: "Enter current password",
            obscured: _c.hideCurrent.value,
            onToggle: () => _c.hideCurrent.toggle(),
            onChanged: (_) => _c.currentPasswordError.value = null,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Please enter your current password";
              }
              return _c.currentPasswordError.value;
            },
          ),
          const SizedBox(height: 18),
          _labeledField(
            label: "NEW PASSWORD",
            controller: _c.newController,
            hint: "Enter new password",
            obscured: _c.hideNew.value,
            onToggle: () => _c.hideNew.toggle(),
            onChanged: (_) => _c.newPasswordError.value = null,
            validator: _validateNewPassword,
          ),
          const SizedBox(height: 18),
          _labeledField(
            label: "CONFIRM PASSWORD",
            controller: _c.confirmController,
            hint: "Re-enter new password",
            obscured: _c.hideConfirm.value,
            onToggle: () => _c.hideConfirm.toggle(),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Please confirm your password";
              }
              if (v != _c.newController.text) return "Passwords do not match";
              return null;
            },
          ),
          const SizedBox(height: 26),
          _buildSubmitButton(isLoading),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: primary),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
              label: const Text(
                "Back to profile",
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return "Please enter a password";
    if (value.length < 8) return "Must be at least 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Include at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Include at least one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Include at least one digit";
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Include at least one special character";
    }
    if (value == _c.currentController.text) {
      return "The new password and current password must be different.";
    }
    // Server-side validation message (e.g. "must be different").
    return _c.newPasswordError.value;
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

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscured,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscured,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14.5,
            color: textPrimary,
            fontWeight: FontWeight.w500,
          ),
          validator: validator,
          decoration: _fieldDecoration(
            hint: hint,
            obscured: obscured,
            onToggle: onToggle,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required bool obscured,
    required VoidCallback onToggle,
  }) {
    OutlineInputBorder border(Color? color, [double width = 1.2]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              color == null
                  ? BorderSide.none
                  : BorderSide(color: color, width: width),
        );

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
      errorMaxLines: 3,
      border: border(null),
      enabledBorder: border(null),
      focusedBorder: border(primary, 1.6),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
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
                    if (_formKey.currentState!.validate()) {
                      _c.changePassword();
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
                  : const Text(
                    "Update password",
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/login_screen/screen/login_screen.dart';
import 'package:quick_scanner/features/profile/delete_screen.dart';
import 'package:quick_scanner/features/profile/logic/profile_controller.dart';
import 'package:quick_scanner/routes_list.dart';
import 'package:quick_scanner/services/models/scan_record.dart';
import 'package:quick_scanner/networks/data_service.dart';

const primary = Color(0xFF4038D8);
const primaryDark = Color(0xFF211F8C);
const accent = Color(0xFF7B79FF);
const background = Color(0xFFF5F7FB);
const _ink = Color(0xFF1A1A1A);
const _muted = Color(0xFF9A9A9A);
const _danger = Color(0xFFE5484D);
const _tint = Color(0xFFF3F2FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final tokenDataService = Get.find<TokenDataServiceImp>();
  final ProfileController _profileController = Get.put(ProfileController());

  String get initials {
    final parts = _profileController.userName.value.trim().split(
      RegExp(r'\s+'),
    );
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Obx(() => header(context)),
            // Pull the content up so the first card overlaps the header.
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).padding.bottom,
                ),
                child: Obx(() {
                  if (_profileController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: CircularProgressIndicator(color: primary),
                      ),
                    );
                  }
                  return content(context);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Content ─────────────────────────

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        detailsCard(),
        // sectionLabel('Security'),
        SizedBox(height: Get.height * 0.02),
        menuCard([
          menuTile(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => Get.toNamed(RouteList.changepassword),
          ),
        ]),
        SizedBox(height: Get.height * 0.02),

        // sectionLabel('Session'),
        menuCard([
          menuTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            onTap: () => confirmLogout(context),
          ),
        ]),
        SizedBox(height: Get.height * 0.02),
        // sectionLabel('Danger zone', color: _danger),
        menuCard([
          menuTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account',
            color: _danger,
            onTap: () => onDeleteTap(context),
          ),
        ], borderColor: _danger.withValues(alpha: 0.18)),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> onDeleteTap(BuildContext context) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAccountPasswordDialog(),
    );

    if (deleted == true && context.mounted) {
      // Account is gone: clear local session and leave the screen.
      // e.g. Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  // ───────────────────────── Header ─────────────────────────

  Widget header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 72,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, accent, primaryDark],
          stops: [0.0, 0.45, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Decorative circles
          Positioned(top: -50, left: -50, child: _circle(150, 0.06)),
          Positioned(bottom: -60, right: -40, child: _circle(170, 0.05)),
          Positioned(top: 40, right: 30, child: _circle(46, 0.07)),
          Column(
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 22),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: ShaderMask(
                        shaderCallback:
                            (b) => const LinearGradient(
                              colors: [primary, accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(b),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: GestureDetector(
                      onTap: editName,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _profileController.userName.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _profileController.userEmail.value.isEmpty
                            ? 'No email'
                            : _profileController.userEmail.value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );

  // ───────────────────────── Cards ─────────────────────────

  BoxDecoration _cardDecoration({Color? borderColor}) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: borderColor == null ? null : Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.07),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
    ],
  );

  Widget sectionLabel(String text, {Color color = _muted}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 24, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: color,
        ),
      ),
    );
  }

  Widget detailsCard() {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          infoTile(
            icon: Icons.badge_outlined,
            label: 'Full Name',
            value: _profileController.userName.value,
            onEdit: editName,
          ),
          const Divider(height: 1, indent: 74, endIndent: 18),
          // Email is read-only.
          infoTile(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value:
                _profileController.userEmail.value.isEmpty
                    ? 'No email'
                    : _profileController.userEmail.value,
            trailing: const Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onEdit,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Material(
              color: _tint,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.edit_outlined, size: 18, color: primary),
                ),
              ),
            )
          else if (trailing != null)
            trailing,
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.13),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 21, color: color),
    );
  }

  Widget menuCard(List<Widget> children, {Color? borderColor}) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(borderColor: borderColor),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  /// Row-style tile used for Change Password, Logout and Delete Account.
  Widget menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = primary,
  }) {
    final isDanger = color == _danger;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha: 0.08),
        highlightColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              _iconBox(icon, color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDanger ? _danger : _ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Actions ─────────────────────────

  Future<void> editName() async {
    _profileController.nameController.text = _profileController.userName.value;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EditNameDialog(),
    );
  }

  void confirmLogout(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'Logout',
      message:
          'Are you sure you want to logout?\nAll saved data will be removed.',
      confirmLabel: 'Logout',
      onConfirm: () async {
        await tokenDataService.logout();
      },
    );
  }

  /// Returns null on success, or an error message to show in the dialog.
  Future<String?> deleteAccount(String password) async {
    try {
      // final result = await accountRepository.deleteAccount({"password": password});
      // if (!result.success) return result.message ?? 'Incorrect password';
      return null;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return 'Something went wrong. Please try again.';
    }
  }

  // ───────────────────────── Statistics (optional) ─────────────────────────

  Widget statisticsCard([List<ScanRecord> records = const []]) {
    final now = DateTime.now();
    final totalScans = records.length;
    final thisMonthScans =
        records
            .where(
              (r) =>
                  r.createdAt.year == now.year &&
                  r.createdAt.month == now.month,
            )
            .length;
    final todayScans =
        records
            .where(
              (r) =>
                  r.createdAt.year == now.year &&
                  r.createdAt.month == now.month &&
                  r.createdAt.day == now.day,
            )
            .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primary, accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.insights_rounded,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Scanner Statistics',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              statTile(
                icon: Icons.document_scanner_outlined,
                value: '$totalScans',
                label: 'Total Scans',
                color: primary,
              ),
              statDivider(),
              statTile(
                icon: Icons.calendar_month_outlined,
                value: '$thisMonthScans',
                label: 'This Month',
                color: const Color(0xFF00A389),
              ),
              statDivider(),
              statTile(
                icon: Icons.today_outlined,
                value: '$todayScans',
                label: 'Today',
                color: const Color(0xFFE08A00),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statDivider() => Container(
    width: 1,
    height: 54,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: const Color(0xFFF0F0F0),
  );

  Widget statTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: _ink,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Confirm dialog ─────────────────────────

  /// Confirmation dialog. Runs [onConfirm]; on success goes to the login screen.
  void showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
  }) {
    final isDelete = confirmLabel == 'Delete';
    final tone = isDelete ? _danger : primary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDelete
                          ? Icons.delete_forever_rounded
                          : Icons.logout_rounded,
                      color: tone,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: _ink,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tone,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(dialogContext);

                          try {
                            await onConfirm();
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                            return;
                          }

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────── Edit name dialog ─────────────────────────

class EditNameDialog extends StatefulWidget {
  const EditNameDialog({super.key});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  final formKey = GlobalKey<FormState>();
  final c = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_rounded, size: 20, color: primary),
          ),
          const SizedBox(width: 12),
          const Text(
            'Edit Name',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
        ],
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: c.nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.badge_outlined, color: primary),
            filled: true,
            fillColor: background,
            floatingLabelStyle: const TextStyle(color: primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _danger, width: 1.5),
            ),
          ),
          validator:
              (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Name cannot be empty'
                      : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            minimumSize: const Size(90, 46),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(110, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed:
                c.isLoading.value
                    ? null
                    : () async {
                      if (!formKey.currentState!.validate()) return;
                      if (context.mounted) {
                        await c.updateName();
                        Get.back();
                      }
                    },
            child:
                c.isLoading.value
                    ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
          ),
        ),
      ],
    );
  }
}

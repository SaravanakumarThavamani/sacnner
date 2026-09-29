// import 'package:flutter/material.dart';
// import '../login_screen/screen/login_screen.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => RegisterScreenState();
// }

// class RegisterScreenState extends State<RegisterScreen> {
//   final name = TextEditingController();
//   final email = TextEditingController();
//   final mobile = TextEditingController();
//   final password = TextEditingController();
//   final confirm = TextEditingController();

//   bool hidePassword = true;
//   bool hideConfirm = true;
//   bool loading = false;

//   static const primary = Color(0xFF5146F5);
//   static const text = Color(0xFF25254A);
//   static const hint = Color(0xFF9696A8);

//   @override
//   void dispose() {
//     name.dispose();
//     email.dispose();
//     mobile.dispose();
//     password.dispose();
//     confirm.dispose();
//     super.dispose();
//   }

//   Future<void> register() async {
//     FocusScope.of(context).unfocus();

//     final n = name.text.trim();
//     final e = email.text.trim().toLowerCase();
//     final m = mobile.text.trim();
//     final p = password.text;
//     final c = confirm.text;

//     if ([n, e, m, p, c].any((x) => x.isEmpty)) {
//       message('Please fill all fields');
//       return;
//     }

//     if (!e.contains('@') || !e.contains('.')) {
//       message('Please enter a valid email address');
//       return;
//     }

//     if (m.length < 10) {
//       message('Please enter a valid mobile number');
//       return;
//     }

//     if (p.length < 4) {
//       message('Password must contain at least 4 characters');
//       return;
//     }

//     if (p != c) {
//       message('Passwords do not match');
//       return;
//     }

//     setState(() => loading = true);

//     try {
//       final prefs = await SharedPreferences.getInstance();

//       await prefs.setString('userName', n);
//       await prefs.setString('userEmail', e);
//       await prefs.setString('userMobile', m);
//       await prefs.setString('userPassword', p);
//       await prefs.setBool('isLoggedIn', false);

//       if (!mounted) return;

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (_) => false,
//       );
//     } catch (_) {
//       if (mounted) {
//         message('Registration failed. Please try again.');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => loading = false);
//       }
//     }
//   }

//   void message(String value) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(value),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//   }

//   InputDecoration decoration(String text, IconData icon, {Widget? suffix}) {
//     return InputDecoration(
//       hintText: text,
//       hintStyle: const TextStyle(color: hint, fontSize: 12),
//       prefixIcon: Icon(icon, color: const Color(0xFF9B9BAB), size: 17),
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Color(0xFFE2E2EA)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: primary, width: 1.3),
//       ),
//     );
//   }

//   Widget label(String value) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         value,
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w500,
//           color: text,
//         ),
//       ),
//     );
//   }

//   Widget field(
//     TextEditingController controller,
//     String labelText,
//     String hintText,
//     IconData icon, {
//     bool obscure = false,
//     VoidCallback? toggle,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         label(labelText),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           obscureText: obscure,
//           style: const TextStyle(fontSize: 14, color: text),
//           decoration: decoration(
//             hintText,
//             icon,
//             suffix:
//                 toggle == null
//                     ? null
//                     : IconButton(
//                       onPressed: toggle,
//                       icon: Icon(
//                         obscure
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         size: 17,
//                         color: const Color(0xFF9999A8),
//                       ),
//                     ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDFDFF),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           padding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 45),

//               const Text(
//                 'Create Account',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: text,
//                 ),
//               ),

//               const SizedBox(height: 5),

//               const Text(
//                 'Join InvoiceScan and get started',
//                 style: TextStyle(fontSize: 12, color: hint),
//               ),

//               const SizedBox(height: 24),

//               field(
//                 name,
//                 'Full Name',
//                 'Enter your full name',
//                 Icons.person_outline_rounded,
//               ),

//               const SizedBox(height: 13),

//               field(
//                 email,
//                 'Email Address',
//                 'Enter your email',
//                 Icons.email_outlined,
//               ),

//               const SizedBox(height: 13),

//               field(
//                 mobile,
//                 'Mobile Number',
//                 '+91 8975425786',
//                 Icons.phone_outlined,
//               ),

//               const SizedBox(height: 13),

//               field(
//                 password,
//                 'Password',
//                 'Create a strong password',
//                 Icons.lock_outline_rounded,
//                 obscure: hidePassword,
//                 toggle: () {
//                   setState(() {
//                     hidePassword = !hidePassword;
//                   });
//                 },
//               ),

//               const SizedBox(height: 13),

//               field(
//                 confirm,
//                 'Confirm Password',
//                 'Confirm your password',
//                 Icons.lock_outline_rounded,
//                 obscure: hideConfirm,
//                 toggle: () {
//                   setState(() {
//                     hideConfirm = !hideConfirm;
//                   });
//                 },
//               ),

//               const SizedBox(height: 22),

//               SizedBox(
//                 width: double.infinity,
//                 height: 43,
//                 child: ElevatedButton(
//                   onPressed: loading ? null : register,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primary,
//                     disabledBackgroundColor: primary.withValues(alpha: .6),
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child:
//                       loading
//                           ? const SizedBox(
//                             width: 19,
//                             height: 19,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                           : const Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                 ),
//               ),

//               const SizedBox(height: 17),

//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account? ',
//                       style: TextStyle(fontSize: 12, color: hint),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         FocusScope.of(context).unfocus();

//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const LoginScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Login',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: primary,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 25),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

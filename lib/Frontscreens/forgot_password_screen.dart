// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mealcircle/widgets/logo.dart';
// import 'package:mealcircle/widgets/auth_service.dart';

// // Modern color scheme (consistent with recipients.dart)
// const Color _kPrimaryGreen = Color(0xFF00B562);
// const Color _kAccentOrange = Color(0xFFFF6B35);
// const Color _kBackgroundCream = Color(0xFFFFFBF7);
// const Color _kCardWhite = Color(0xFFFFFFFF);
// const Color _kTextDark = Color(0xFF1C1C1C);
// const Color _kTextLight = Color(0xFF6B7280);
// const Color _kBorderLight = Color(0xFFE5E7EB);

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _codeController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _authService = AuthService();

//   bool _isLoading = false;
//   bool _codeSent = false;
//   bool _codeVerified = false;
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   String? _resetCode;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _codeController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendResetCode() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final result = await _authService.sendPasswordResetCode(_emailController.text.trim());

//     if (mounted) {
//       setState(() => _isLoading = false);

//       if (result['success']) {
//         setState(() {
//           _codeSent = true;
//           _resetCode = result['code'];
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.mail_outline_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Reset code sent to your email',
//                     style: GoogleFonts.inter(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: _kPrimaryGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//             duration: const Duration(seconds: 10),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.error_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     result['message'],
//                     style: GoogleFonts.inter(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _verifyCode() async {
//     if (_codeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please enter the reset code',
//             style: GoogleFonts.inter(color: Colors.white),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final result = await _authService.verifyResetCode(
//       _emailController.text.trim(),
//       _codeController.text.trim(),
//     );

//     if (mounted) {
//       setState(() => _isLoading = false);

//       if (result['success']) {
//         setState(() => _codeVerified = true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Code verified! Enter new password',
//                   style: GoogleFonts.inter(color: Colors.white),
//                 ),
//               ],
//             ),
//             backgroundColor: _kPrimaryGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.error_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     result['message'],
//                     style: GoogleFonts.inter(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final result = await _authService.resetPassword(
//       _emailController.text.trim(),
//       _newPasswordController.text,
//     );

//     if (mounted) {
//       setState(() => _isLoading = false);

//       if (result['success']) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Password reset successful!',
//                   style: GoogleFonts.inter(color: Colors.white),
//                 ),
//               ],
//             ),
//             backgroundColor: _kPrimaryGreen,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.error_rounded, color: Colors.white, size: 20),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     result['message'],
//                     style: GoogleFonts.inter(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       backgroundColor: _kBackgroundCream,
//       appBar: _buildAppBar(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal: isMobile ? 16 : 24,
//             vertical: isMobile ? 12 : 20,
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 TweenAnimationBuilder(
//                   duration: const Duration(milliseconds: 600),
//                   tween: Tween<double>(begin: 0, end: 1),
//                   builder: (context, double value, child) {
//                     return Transform.scale(
//                       scale: value,
//                       child: Opacity(opacity: value, child: child),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           _kPrimaryGreen.withOpacity(0.1),
//                           _kPrimaryGreen.withOpacity(0.05),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const MealCircleLogo(size: 100),
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 TweenAnimationBuilder(
//                   duration: const Duration(milliseconds: 600),
//                   tween: Tween<double>(begin: 0, end: 1),
//                   builder: (context, double value, child) {
//                     return Transform.translate(
//                       offset: Offset(0, 20 * (1 - value)),
//                       child: Opacity(opacity: value, child: child),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       Text(
//                         'Reset Password',
//                         style: GoogleFonts.poppins(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w700,
//                           color: _kTextDark,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _codeSent
//                             ? _codeVerified
//                                 ? "Set your new password"
//                                 : "Enter the code sent to your email"
//                             : "Enter your email to receive a reset code",
//                         style: GoogleFonts.inter(
//                           fontSize: 13,
//                           color: _kTextLight,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 TweenAnimationBuilder(
//                   duration: const Duration(milliseconds: 600),
//                   tween: Tween<double>(begin: 0, end: 1),
//                   builder: (context, double value, child) {
//                     return Transform.translate(
//                       offset: Offset(0, 30 * (1 - value)),
//                       child: Opacity(opacity: value, child: child),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       if (!_codeSent) ...[
//                         _buildTextFormField(
//                           label: 'Email Address',
//                           hint: 'your@email.com',
//                           icon: Icons.email_rounded,
//                           controller: _emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                 .hasMatch(value)) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _sendResetCode,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _kPrimaryGreen,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: _isLoading
//                                 ? SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : Text(
//                                     'Send Reset Code',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                       letterSpacing: -0.2,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ] else if (!_codeVerified) ...[
//                         _buildTextFormField(
//                           label: 'Reset Code',
//                           hint: 'Enter the code from your email',
//                           icon: Icons.verification_rounded,
//                           controller: _codeController,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter the reset code';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _verifyCode,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _kPrimaryGreen,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: _isLoading
//                                 ? SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : Text(
//                                     'Verify Code',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                       letterSpacing: -0.2,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ] else ...[
//                         _buildTextFormField(
//                           label: 'New Password',
//                           hint: 'At least 6 characters',
//                           icon: Icons.lock_rounded,
//                           controller: _newPasswordController,
//                           obscureText: _obscureNewPassword,
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscureNewPassword
//                                   ? Icons.visibility_off_rounded
//                                   : Icons.visibility_rounded,
//                               color: _kTextLight,
//                               size: 20,
//                             ),
//                             onPressed: () => setState(
//                               () => _obscureNewPassword = !_obscureNewPassword,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter a password';
//                             }
//                             if (value.length < 6) {
//                               return 'Password must be at least 6 characters';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 14),
//                         _buildTextFormField(
//                           label: 'Confirm Password',
//                           hint: 'Re-enter your password',
//                           icon: Icons.lock_rounded,
//                           controller: _confirmPasswordController,
//                           obscureText: _obscureConfirmPassword,
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscureConfirmPassword
//                                   ? Icons.visibility_off_rounded
//                                   : Icons.visibility_rounded,
//                               color: _kTextLight,
//                               size: 20,
//                             ),
//                             onPressed: () => setState(
//                               () =>
//                                   _obscureConfirmPassword = !_obscureConfirmPassword,
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please confirm your password';
//                             }
//                             if (value != _newPasswordController.text) {
//                               return 'Passwords do not match';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 24),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _resetPassword,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _kPrimaryGreen,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                             child: _isLoading
//                                 ? SizedBox(
//                                     height: 20,
//                                     width: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : Text(
//                                     'Reset Password',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                       letterSpacing: -0.2,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TweenAnimationBuilder(
//                   duration: const Duration(milliseconds: 700),
//                   tween: Tween<double>(begin: 0, end: 1),
//                   builder: (context, double value, child) {
//                     return Transform.translate(
//                       offset: Offset(0, 30 * (1 - value)),
//                       child: Opacity(opacity: value, child: child),
//                     );
//                   },
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Text(
//                       'Back to Login',
//                       style: GoogleFonts.inter(
//                         fontSize: 13,
//                         color: _kPrimaryGreen,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: const Size.fromHeight(100),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.85)],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back_ios_new,
//                       color: Colors.white, size: 20),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 Expanded(
//                   child: Text(
//                     'Reset Password',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextFormField({
//     required String label,
//     required String hint,
//     required IconData icon,
//     required TextEditingController controller,
//     TextInputType keyboardType = TextInputType.text,
//     bool obscureText = false,
//     Widget? suffixIcon,
//     required String? Function(String?) validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.inter(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: _kTextLight,
//             letterSpacing: 0.3,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           style: GoogleFonts.inter(fontSize: 13, color: _kTextDark),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: GoogleFonts.inter(fontSize: 13, color: _kTextLight),
//             prefixIcon: Icon(icon, size: 18, color: _kTextLight),
//             suffixIcon: suffixIcon,
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: _kBorderLight),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: _kPrimaryGreen, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: Colors.red, width: 1),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }
// }
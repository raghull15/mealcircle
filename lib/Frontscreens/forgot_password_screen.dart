// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mealcircle/widgets/logo.dart';
// import 'package:mealcircle/widgets/auth_service.dart';

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
//             content: Text('Reset code: ${result['code']}'),
//             duration: const Duration(seconds: 10),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _verifyCode() async {
//     if (_codeController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the reset code'),
//           backgroundColor: Colors.red,
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
//           const SnackBar(
//             content: Text('Code verified! Enter your new password'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             backgroundColor: Colors.red,
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
//           const SnackBar(
//             content: Text('Password reset successful!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message']),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF2AC962),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 28),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const MealCircleLogo(size: 200),
//                   const SizedBox(height: 20),
//                   Text(
//                     "Reset Password",
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: 29,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     _codeSent
//                         ? _codeVerified
//                             ? "Enter your new password"
//                             : "Enter the code sent to your email"
//                         : "Enter your email to receive a reset code",
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: 15,
//                       color: Colors.white.withOpacity(0.9),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 28),
                  
//                   if (!_codeSent) ...[
//                     _buildInputField(
//                       hint: "Email",
//                       controller: _emailController,
//                       obscure: false,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD1EBD0),
//                           foregroundColor: Colors.black87,
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         onPressed: _isLoading ? null : _sendResetCode,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : Text(
//                                 "Send Reset Code",
//                                 style: GoogleFonts.playfairDisplay(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ] else if (!_codeVerified) ...[
//                     _buildInputField(
//                       hint: "Enter Reset Code",
//                       controller: _codeController,
//                       obscure: false,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter the reset code';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD1EBD0),
//                           foregroundColor: Colors.black87,
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         onPressed: _isLoading ? null : _verifyCode,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : Text(
//                                 "Verify Code",
//                                 style: GoogleFonts.playfairDisplay(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ] else ...[
//                     _buildInputField(
//                       hint: "New Password",
//                       controller: _newPasswordController,
//                       obscure: _obscureNewPassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter a password';
//                         }
//                         if (value.length < 6) {
//                           return 'Password must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                       suffix: IconButton(
//                         icon: Icon(
//                           _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
//                           color: Colors.black87,
//                         ),
//                         onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildInputField(
//                       hint: "Confirm Password",
//                       controller: _confirmPasswordController,
//                       obscure: _obscureConfirmPassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please confirm your password';
//                         }
//                         if (value != _newPasswordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                       suffix: IconButton(
//                         icon: Icon(
//                           _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                           color: Colors.black87,
//                         ),
//                         onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFD1EBD0),
//                           foregroundColor: Colors.black87,
//                           elevation: 3,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                         ),
//                         onPressed: _isLoading ? null : _resetPassword,
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : Text(
//                                 "Reset Password",
//                                 style: GoogleFonts.playfairDisplay(
//                                   fontSize: 17,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
                  
//                   const SizedBox(height: 26),
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Text(
//                       "Back to Login",
//                       style: GoogleFonts.playfairDisplay(
//                         fontSize: 15,
//                         color: Colors.blue.shade900,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required String hint,
//     required TextEditingController controller,
//     required bool obscure,
//     required String? Function(String?) validator,
//     Widget? suffix,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFEDE8E5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscure,
//         style: GoogleFonts.playfairDisplay(fontSize: 16),
//         validator: validator,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: GoogleFonts.playfairDisplay(fontSize: 16, color: Colors.black87),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//           border: InputBorder.none,
//           suffixIcon: suffix,
//           errorStyle: GoogleFonts.playfairDisplay(fontSize: 12),
//         ),
//       ),
//     );
//   }
// }
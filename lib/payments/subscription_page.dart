// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mealcircle/Donater/Donate_screen.dart';
// import 'package:mealcircle/widgets/logo.dart';
// import 'payment_details_screen.dart';

// class SubscriptionScreen extends StatefulWidget {
//   const SubscriptionScreen({super.key});

//   @override
//   State<SubscriptionScreen> createState() => _SubscriptionScreenState();
// }

// class _SubscriptionScreenState extends State<SubscriptionScreen> {
//   int _selectedPlan = 1; 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF2AC962),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 const MealCircleLogo(size: 20,),
//                 const SizedBox(height: 24),
//                 Text(
//                   "Choose Your Plan",
//                   style: GoogleFonts.playfairDisplay(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Unlock premium features and support our mission",
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.playfairDisplay(
//                     fontSize: 16,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 _buildPlanCard(
//                   index: 0,
//                   title: "Basic",
//                   price: "Free",
//                   period: "",
//                   features: [
//                     "Donate & Find Food",
//                     "Basic Support",
//                     "Community Access",
//                   ],
//                   isPopular: false,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPlanCard(
//                   index: 1,
//                   title: "Premium",
//                   price: "₹99",
//                   period: "/month",
//                   features: [
//                     "All Basic Features",
//                     "Priority Notifications",
//                     "Advanced Food Tracking",
//                     "24/7 Premium Support",
//                     "No Ads",
//                   ],
//                   isPopular: true,
//                 ),
//                 const SizedBox(height: 16),
//                 _buildPlanCard(
//                   index: 2,
//                   title: "Pro",
//                   price: "₹999",
//                   period: "/year",
//                   features: [
//                     "All Premium Features",
//                     "Analytics Dashboard",
//                     "Custom Donation Campaigns",
//                     "API Access",
//                     "Dedicated Support",
//                     "Save 17%",
//                   ],
//                   isPopular: false,
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFD1EBD0),
//                       foregroundColor: Colors.black87,
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     onPressed: () {
//                       if (_selectedPlan == 0) {
                       
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const DonateScreen(),
//                           ),
//                         );
//                       } else {
                      
//                         final plans = [
//                           {'name': 'Basic', 'price': 'Free', 'period': ''},
//                           {'name': 'Premium', 'price': '₹99', 'period': 'monthly'},
//                           {'name': 'Pro', 'price': '₹999', 'period': 'yearly'},
//                         ];
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => PaymentDetailsScreen(
//                               planName: plans[_selectedPlan]['name']!,
//                               planPrice: plans[_selectedPlan]['price']!,
//                               planPeriod: plans[_selectedPlan]['period']!,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     child: Text(
//                       _selectedPlan == 0 ? "Continue with Basic" : "Subscribe Now",
//                       style: GoogleFonts.playfairDisplay(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DonateScreen(),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "Skip for now",
//                     style: GoogleFonts.playfairDisplay(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPlanCard({
//     required int index,
//     required String title,
//     required String price,
//     required String period,
//     required List<String> features,
//     required bool isPopular,
//   }) {
//     final isSelected = _selectedPlan == index;

//     return GestureDetector(
//       onTap: () => setState(() => _selectedPlan = index),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.white : const Color(0xFFEDE8E5),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: isSelected ? const Color(0xFFD1EBD0) : Colors.transparent,
//                 width: 3,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(isSelected ? 0.15 : 0.08),
//                   blurRadius: isSelected ? 12 : 6,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: GoogleFonts.playfairDisplay(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           children: [
//                             Text(
//                               price,
//                               style: GoogleFonts.playfairDisplay(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF2AC962),
//                               ),
//                             ),
//                             if (period.isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 4),
//                                 child: Text(
//                                   period,
//                                   style: GoogleFonts.playfairDisplay(
//                                     fontSize: 16,
//                                     color: Colors.black54,
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? const Color(0xFF2AC962)
//                             : Colors.grey.shade300,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         isSelected ? Icons.check : Icons.circle_outlined,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 ...features.map((feature) => Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.check_circle,
//                             color: Color(0xFF2AC962),
//                             size: 20,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               feature,
//                               style: GoogleFonts.playfairDisplay(
//                                 fontSize: 15,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//               ],
//             ),
//           ),
//           if (isPopular)
//             Positioned(
//               top: -12,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD1EBD0),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   "POPULAR",
//                   style: GoogleFonts.playfairDisplay(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
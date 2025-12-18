// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:mealcircle/Donater/cart_confirmation.dart';
// import 'package:mealcircle/Donater/cart_manager.dart';
// import 'package:mealcircle/Donater/recepients.dart';
// import 'package:mealcircle/widgets/user_profile_page.dart';
// import 'package:mealcircle/Donater/past_donation_manager.dart';
// import 'package:mealcircle/Donater/past_donation_page.dart';

// class DonationStatusPage extends StatefulWidget {
//   final List<DonationItem> donations;

//   const DonationStatusPage({
//     super.key,
//     required this.donations,
//   });

//   @override
//   State<DonationStatusPage> createState() => _DonationStatusPageState();
// }

// class _DonationStatusPageState extends State<DonationStatusPage> {
//   @override
//   void initState() {
//     super.initState();
//     _saveToPastDonations();
//   }

//   void _saveToPastDonations() {
//     final manager = PastDonationManager();
    
//     for (var donation in widget.donations) {
//       DateTime donationDateTime;
//       try {
//         final DateFormat formatter = DateFormat("MMM d, yyyy 'at' h:mm a");
//         donationDateTime = formatter.parse(donation.dateTime);
//       } catch (e) {
//         donationDateTime = DateTime.now();
//       }

//       final pastDonation = PastDonation(
//         shelterItem: donation.shelterItem,
//         foodType: donation.foodType,
//         quantity: donation.quantity,
//         donationDate: donationDateTime,
//         status: donation.isCancelled ? "Cancelled" : "Delivered",
//         recipientName: donation.recipientName,
//         recipientAddress: donation.recipientAddress,
//         recipientPhone: donation.recipientPhone,
//         deliveryByDonor: donation.deliveryByDonor,
//         cancellationReason: donation.isCancelled ? donation.cancellationReason : null,
//       );

//       manager.addDonation(pastDonation);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color successGreen = Color(0xFF2AC962);
//     const Color primaryTextBlack = Color(0xFF1E1E1E);
//     const Color buttonOrange = Color(0xFFF7931E);
//     const Color buttonBlue = Color(0xFF4C9BEB);

//     final confirmedDonations = widget.donations.where((d) => !d.isCancelled).toList();
//     final cancelledDonations = widget.donations.where((d) => d.isCancelled).toList();
//     final bool allConfirmed = confirmedDonations.isNotEmpty;

//     return Scaffold(
//       backgroundColor: const Color(0xFFEDE8E5),
//       appBar: _buildTopBar(context),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: allConfirmed ? successGreen : Colors.red,
//                         width: 8,
//                       ),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         allConfirmed ? Icons.check : Icons.close,
//                         color: allConfirmed ? successGreen : Colors.red,
//                         size: 60,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     allConfirmed
//                         ? "DONATION PROCESSED!"
//                         : "ALL DONATIONS CANCELLED",
//                     style: GoogleFonts.playfairDisplay(
//                       color: allConfirmed ? successGreen : Colors.red,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Thank you for your generous contribution!",
//                     style: GoogleFonts.poppins(
//                       color: successGreen,
//                       fontSize: 14,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildStatColumn(
//                     "${widget.donations.length}",
//                     "Total",
//                     Colors.blue.shade700,
//                   ),
//                   _buildStatColumn(
//                     "${confirmedDonations.length}",
//                     "Confirmed",
//                     Colors.green.shade700,
//                   ),
//                   _buildStatColumn(
//                     "${cancelledDonations.length}",
//                     "Cancelled",
//                     Colors.red.shade700,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (confirmedDonations.isNotEmpty) ...[
//               Text(
//                 "✅ Confirmed Donations",
//                 style: GoogleFonts.playfairDisplay(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green.shade700,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...confirmedDonations.map((donation) {
//                 return _buildDonationStatusCard(
//                   donation,
//                   true,
//                   primaryTextBlack,
//                 );
//               }).toList(),
//               const SizedBox(height: 20),
//             ],
//             if (cancelledDonations.isNotEmpty) ...[
//               Text(
//                 "❎ Cancelled Donations",
//                 style: GoogleFonts.playfairDisplay(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red.shade700,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...cancelledDonations.map((donation) {
//                 return _buildDonationStatusCard(
//                   donation,
//                   false,
//                   primaryTextBlack,
//                 );
//               }).toList(),
//               const SizedBox(height: 20),
//             ],
//             const SizedBox(height: 25),
//             Row(
//               children: [
//                 Expanded(
                  
                    
//                     child: Text(
//                       "View Details",
//                       style: GoogleFonts.playfairDisplay(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: buttonBlue,
//                       minimumSize: const Size.fromHeight(48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onPressed: () {
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Share",
//                           style: GoogleFonts.playfairDisplay(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         const Icon(Icons.share,
//                             color: Colors.white, size: 18),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatColumn(String value, String label, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: GoogleFonts.playfairDisplay(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 12,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDonationStatusCard(
//     DonationItem donation,
//     bool isConfirmed,
//     Color primaryTextBlack,
//   ) {
//     final shelter = donation.shelterItem;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: isConfirmed ? Colors.green.shade50 : Colors.red.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: isConfirmed ? Colors.green.shade300 : Colors.red.shade300,
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Image.network(
//                   shelter["image"] ?? "https://via.placeholder.com/40",
//                   height: 40,
//                   width: 40,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       shelter["name"] ?? "Shelter",
//                       style: GoogleFonts.playfairDisplay(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: primaryTextBlack,
//                       ),
//                     ),
//                     Text(
//                       "${donation.foodType} - ${donation.quantity} servings",
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 isConfirmed ? Icons.check_circle : Icons.cancel,
//                 color: isConfirmed ? Colors.green.shade700 : Colors.red.shade700,
//                 size: 24,
//               ),
//             ],
//           ),
//           if (!isConfirmed) ...[
//             const SizedBox(height: 12),
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade100,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(color: Colors.red.shade300),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Cancellation Reason:",
//                       style: GoogleFonts.playfairDisplay(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       donation.cancellationReason.isEmpty
//                           ? "No reason provided"
//                           : donation.cancellationReason,
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.playfairDisplay(
//                         fontSize: 12,
//                         color: Colors.red.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ]
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildTopBar(BuildContext context) {
//     const successGreen = Color(0xFF2AC962);
//     const double customHeight = 74.0;

//     return PreferredSize(
//       preferredSize: const Size.fromHeight(customHeight),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: successGreen,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black,
//               blurRadius: 4,
//               offset: Offset(0, .2),
//             ),
//           ],
//         ),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           toolbarHeight: customHeight,
//           automaticallyImplyLeading: false,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
//             onPressed: () {
//               CartManager().clearCart();
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (_) => const RecipientsScreen()),
//                 (route) => false,
//               );
//             },
//           ),
//           title: Text(
//             "Donation Status",
//             style: GoogleFonts.imFellGreatPrimerSc(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.person_outline,
//                   color: Colors.white, size: 26),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const UserProfilePage(),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }
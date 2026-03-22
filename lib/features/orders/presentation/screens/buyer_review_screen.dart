import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/order_timeline_constants.dart';

/// Post-delivery rating entry point (timeline deep link).
class BuyerReviewScreen extends StatelessWidget {
  final String orderId;

  const BuyerReviewScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          OrderTimelineConstants.reviewScreenTitle,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 17),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            OrderTimelineConstants.deliveredThanks,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF666666)),
          ),
        ),
      ),
    );
  }
}

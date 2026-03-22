import 'package:flutter/material.dart';

import '../../../../core/widgets/simple_screen.dart';

class BidStatusScreen extends StatelessWidget {
  final String orderId;

  const BidStatusScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return SimpleScreen(title: 'Bid status', body: Center(child: Text('orderId=$orderId')));
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

VoidCallback repairScreenChatTap(
  BuildContext context,
  String orderId,
  VoidCallback? onOpenChat,
) =>
    onOpenChat ?? () => context.go('/order/$orderId?tab=chat');

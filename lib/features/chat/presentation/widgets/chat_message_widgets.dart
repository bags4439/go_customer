import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import 'vehicle_option_chat_card.dart';

/// Status for sent messages: pending (clock), sent (done), read (done_all blue).
String _messageStatusKey(ChatMessage msg) {
  if (msg.status == 'pending') return 'pending';
  if (msg.isRead) return 'read';
  return 'sent';
}

Widget _statusIcon(String statusKey, bool isMe) {
  if (!isMe) return const SizedBox.shrink();
  IconData icon;
  Color color;
  if (statusKey == 'pending') {
    icon = Icons.access_time;
    color = Colors.white.withOpacity(0.6);
  } else if (statusKey == 'sent') {
    icon = Icons.done;
    color = Colors.white.withOpacity(0.7);
  } else {
    icon = Icons.done_all;
    color = const Color(0xFF53BDEB);
  }
  return Icon(icon, size: 12, color: color);
}

/// Bottom row for my messages: timestamp + status icon inside bubble.
Widget _timestampAndStatusRow(DateTime sentAt, String statusKey, bool isMe) {
  final time = DateFormat.Hm().format(sentAt);
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        time,
        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
      ),
      const SizedBox(width: 3),
      _statusIcon(statusKey, isMe),
    ],
  );
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage? message;
  final bool isMe;
  final List<String> reactions;
  final String? replyToBody;
  final PendingMessage? pending;
  final VoidCallback? onVideoTap;
  final String orderId;

  const ChatMessageBubble({
    super.key,
    this.message,
    required this.isMe,
    required this.orderId,
    this.reactions = const [],
    this.replyToBody,
    this.pending,
    this.onVideoTap,
  }) : assert(message != null || pending != null);

  factory ChatMessageBubble.pending({
    required PendingMessage pending,
    required bool isMe,
    required String orderId,
    VoidCallback? onVideoTap,
  }) {
    return ChatMessageBubble(
      isMe: isMe,
      orderId: orderId,
      pending: pending,
      onVideoTap: onVideoTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pending != null) {
      return _PendingBubble(
        pending: pending!,
        isMe: isMe,
        onVideoTap: onVideoTap,
      );
    }
    final msg = message!;
    final statusKey = _messageStatusKey(msg);
    final Widget child;
    switch (msg.messageType) {
      case 'voice_note':
        child = _VoiceNoteBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
        );
        break;
      case 'image':
        child = _ImageBubble(message: msg, isMe: isMe, statusKey: statusKey);
        break;
      case 'video':
        child = _VideoBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
          onTap: onVideoTap,
        );
        break;
      case 'file':
        child = _FileBubble(message: msg, isMe: isMe, statusKey: statusKey);
        break;
      case 'vehicle_card':
        child = _VehicleCard(message: msg, orderId: orderId);
        break;
      case 'payment_request':
        child = _PaymentRequestCard(message: msg, orderId: orderId);
        break;
      case 'payment_confirmed':
        child = _PaymentConfirmedCard(message: msg);
        break;
      case 'bid_won':
        child = _BidWonCard(message: msg);
        break;
      case 'bid_lost':
        child = _BidLostCard(message: msg);
        break;
      case 'shipping_update':
        child = _ShippingUpdateCard(message: msg);
        break;
      case 'stage_update':
        child = _SystemPill(text: msg.body ?? '');
        break;
      default:
        child = _TextBubble(
          message: msg,
          isMe: isMe,
          replyToBody: replyToBody,
          statusKey: statusKey,
        );
    }
    if (reactions.isEmpty) return child;
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 2,
          children: reactions
              .map(
                (e) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PendingBubble extends StatelessWidget {
  final PendingMessage pending;
  final bool isMe;
  final VoidCallback? onVideoTap;

  const _PendingBubble({
    required this.pending,
    required this.isMe,
    this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (pending.messageType == 'image' && pending.localPath != null) {
      child = _ImageBubble(
        message: null,
        isMe: isMe,
        localPath: pending.localPath,
        uploadProgress: pending.progress < 1 ? pending.progress : null,
        statusKey: 'pending',
      );
    } else if (pending.messageType == 'video' && pending.localPath != null) {
      child = _VideoBubble(
        message: null,
        isMe: isMe,
        localPath: pending.localPath,
        uploadProgress: pending.progress < 1 ? pending.progress : null,
        statusKey: 'pending',
        onTap: onVideoTap,
      );
    } else {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const Padding(
          padding: EdgeInsets.only(top: 2, right: 4),
          child: Icon(Icons.access_time, size: 12, color: Colors.white),
        ),
      ],
    );
  }
}

class _TextBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String? replyToBody;
  final String statusKey;

  const _TextBubble({
    required this.message,
    required this.isMe,
    this.replyToBody,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFF378ADD) : Colors.white;
    final fg = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: isMe
                ? null
                : Border.all(color: Colors.grey.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: align,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyToBody != null && replyToBody!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: fg.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      replyToBody!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
              Text(message.body ?? '', style: TextStyle(color: fg)),
              if (isMe) ...[
                const SizedBox(height: 4),
                _timestampAndStatusRow(message.sentAt, statusKey, isMe),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceNoteBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String statusKey;

  const _VoiceNoteBubble({
    required this.message,
    required this.isMe,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFF378ADD) : Colors.white;
    final fg = isMe ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? null
            : Border.all(color: Colors.grey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow, color: fg),
              const SizedBox(width: 8),
              Row(
                children: List.generate(
                  12,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 3,
                    height: 6.0 + (index % 4) * 3,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${message.mediaDurationSecs ?? 0}s',
                style: TextStyle(color: fg),
              ),
            ],
          ),
          if (isMe) ...[
            const SizedBox(height: 4),
            _timestampAndStatusRow(message.sentAt, statusKey, isMe),
          ],
        ],
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  final ChatMessage? message;
  final bool isMe;
  final String? localPath;
  final double? uploadProgress;
  final String statusKey;

  const _ImageBubble({
    this.message,
    required this.isMe,
    this.localPath,
    this.uploadProgress,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final url = message?.mediaUrl;
    final showProgress = uploadProgress != null && uploadProgress! < 1.0;

    Widget content;
    if (localPath != null && File(localPath!).existsSync()) {
      content = Image.file(File(localPath!), fit: BoxFit.cover);
    } else if (url != null && url.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
      );
    } else {
      content = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (showProgress)
            Container(
              color: Colors.black45,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (isMe && message != null)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _timestampAndStatusRow(message!.sentAt, statusKey, isMe),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoBubble extends StatelessWidget {
  final ChatMessage? message;
  final bool isMe;
  final String? localPath;
  final double? uploadProgress;
  final String statusKey;
  final VoidCallback? onTap;

  const _VideoBubble({
    this.message,
    required this.isMe,
    this.localPath,
    this.uploadProgress,
    required this.statusKey,
    this.onTap,
  });

  static String _durationLabel(int? secs) {
    if (secs == null) return '0:00';
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final showProgress = uploadProgress != null && uploadProgress! < 1.0;
    final thumbUrl = message?.thumbnailUrl;

    Widget thumbnail;
    if (localPath != null && File(localPath!).existsSync()) {
      thumbnail = Image.file(File(localPath!), fit: BoxFit.cover);
    } else if (thumbUrl != null && thumbUrl.isNotEmpty) {
      thumbnail = CachedNetworkImage(
        imageUrl: thumbUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const ColoredBox(
          color: Colors.grey,
          child: Center(
            child: Icon(Icons.play_arrow, color: Colors.white54, size: 48),
          ),
        ),
      );
    } else if (message?.mediaUrl != null && message!.mediaUrl!.isNotEmpty) {
      thumbnail = CachedNetworkImage(
        imageUrl: message!.mediaUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const ColoredBox(
          color: Colors.grey,
          child: Center(
            child: Icon(Icons.play_arrow, color: Colors.white54, size: 48),
          ),
        ),
      );
    } else {
      thumbnail = const ColoredBox(
        color: Colors.grey,
        child: Center(
          child: Icon(Icons.play_arrow, color: Colors.white54, size: 48),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          thumbnail,
          Center(
            child: GestureDetector(
              onTap: showProgress ? null : () => onTap?.call(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF378ADD),
                  size: 32,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _durationLabel(message?.mediaDurationSecs),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (isMe && message != null) ...[
                  const SizedBox(width: 4),
                  _timestampAndStatusRow(message!.sentAt, statusKey, isMe),
                ],
              ],
            ),
          ),
          if (showProgress)
            Container(
              color: Colors.black45,
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String statusKey;

  const _FileBubble({
    required this.message,
    required this.isMe,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isMe ? Colors.white : Colors.black87;
    final bg = isMe ? const Color(0xFF378ADD) : Colors.grey.shade200;
    return InkWell(
      onTap: message.mediaUrl != null
          ? () {
              // Could use url_launcher to open file
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isMe
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insert_drive_file, color: fg, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message.mediaFileName ?? 'File',
                    style: TextStyle(color: fg, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (isMe) ...[
              const SizedBox(height: 4),
              _timestampAndStatusRow(message.sentAt, statusKey, isMe),
            ],
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final ChatMessage message;
  final String orderId;

  const _VehicleCard({required this.message, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final vehicleOptionId = message.vehicleOptionId;
    if (vehicleOptionId == null || vehicleOptionId.isEmpty) {
      return const SizedBox.shrink();
    }
    return VehicleOptionChatCard(
      orderId: orderId,
      vehicleOptionId: vehicleOptionId,
    );
  }
}

class _PaymentRequestCard extends StatelessWidget {
  final ChatMessage message;
  final String orderId;

  const _PaymentRequestCard({required this.message, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFE6F1FF),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment request',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              message.body ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: message.paymentRequestId != null
                  ? () => context.push(
                '/order/$orderId/payment-request/${message.paymentRequestId}',
              )
                  : null,
              child: const Text('Pay now →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentConfirmedCard extends StatelessWidget {
  final ChatMessage message;

  const _PaymentConfirmedCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: const Color(0xFFE5F5E8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment confirmed',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.body ?? ''),
          ],
        ),
      ),
    );
  }
}

class _BidWonCard extends StatelessWidget {
  final ChatMessage message;

  const _BidWonCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE5F5E8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎉 Bid won!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.body ?? ''),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('View next steps →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BidLostCard extends StatelessWidget {
  final ChatMessage message;

  const _BidLostCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF0F0F0),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This one got away',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.body ?? ''),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('See new options →'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShippingUpdateCard extends StatelessWidget {
  final ChatMessage message;

  const _ShippingUpdateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping update',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.body ?? ''),
            const SizedBox(height: 8),
            TextButton(onPressed: () {}, child: const Text('Track shipment →')),
          ],
        ),
      ),
    );
  }
}

class _SystemPill extends StatelessWidget {
  final String text;

  const _SystemPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F4F0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

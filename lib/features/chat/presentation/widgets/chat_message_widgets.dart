// ignore_for_file: unused_element, unused_element_parameter
// _k* constants, _BubblePainter, _ReplyBlock: infrastructure for upcoming bubble UI.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/cross_platform_image.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import 'vehicle_option_chat_card.dart';
import 'package:go_customer/core/theme/app_colors.dart';

// ─────────────────────────────────────
// Design constants — WhatsApp adapted
// to AutoImport GH brand palette
// ─────────────────────────────────────
const _kBubbleRadius = 7.5;
const _kMaxBubbleWidth = 280.0;

/// Status for sent messages: pending (clock), sent (done), read (done_all blue).
String _messageStatusKey(ChatMessage msg) {
  if (msg.status == 'pending') return 'pending';
  if (msg.isRead) return 'read';
  return 'sent';
}

/// Tick icon for sent message status.
Widget _tickIcon(String statusKey) {
  if (statusKey == 'pending') {
    return Icon(Icons.access_time_rounded, size: 11, color: AppColors.chatSentTimestamp);
  }
  if (statusKey == 'sent') {
    return Icon(Icons.done_rounded, size: 13, color: AppColors.chatSentTimestamp);
  }
  // read
  return Icon(Icons.done_all_rounded, size: 13, color: AppColors.brand);
}

/// Timestamp + tick for sent messages.
/// Replaces the old _timestampAndStatusRow.
Widget _sentMeta(DateTime sentAt, String statusKey) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        DateFormat.Hm().format(sentAt),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.chatSentTimestamp,
          height: 1,
        ),
      ),
      const SizedBox(width: 3),
      _tickIcon(statusKey),
    ],
  );
}

/// Timestamp for received messages.
Widget _receivedMeta(DateTime sentAt) {
  return Text(
    DateFormat.Hm().format(sentAt),
    style: AppTextStyles.caption.copyWith(
      color: AppColors.textMuted,
      height: 1,
    ),
  );
}

/// Used by existing bubble widgets until they adopt _sentMeta / _receivedMeta.
Widget _timestampAndStatusRow(DateTime sentAt, String statusKey, bool isMe) {
  return isMe ? _sentMeta(sentAt, statusKey) : _receivedMeta(sentAt);
}

/// Draws a WhatsApp-style bubble with
/// an optional tail on the bottom corner.
class _BubblePainter extends CustomPainter {
  final bool isMe;
  final bool hasTail;
  final Color color;
  final Color? borderColor;

  const _BubblePainter({
    required this.isMe,
    required this.hasTail,
    required this.color,
    this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = _kBubbleRadius;
    final tailW = hasTail ? 6.5 : 0.0;
    final tailH = hasTail ? 10.0 : 0.0;
    final path = Path();

    if (isMe) {
      // Sent — tail exits bottom-right
      final l = 0.0;
      final ri = size.width - tailW;

      path.moveTo(l + r, 0);
      path.lineTo(ri - r, 0);
      path.arcToPoint(
        Offset(ri, r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(ri, size.height - tailH);

      if (hasTail) {
        path.quadraticBezierTo(
          ri + tailW * 0.4,
          size.height - tailH * 0.3,
          ri + tailW,
          size.height,
        );
        path.lineTo(ri - r * 0.6, size.height);
        path.arcToPoint(
          Offset(ri - r, size.height - r * 0.4),
          radius: Radius.circular(r * 0.7),
          clockwise: false,
        );
      } else {
        path.arcToPoint(
          Offset(ri - r, size.height),
          radius: Radius.circular(r),
          clockwise: true,
        );
      }

      path.lineTo(l + r, size.height);
      path.arcToPoint(
        Offset(l, size.height - r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(l, r);
      path.arcToPoint(
        Offset(l + r, 0),
        radius: Radius.circular(r),
        clockwise: true,
      );
    } else {
      // Received — tail exits bottom-left
      final l = tailW;
      final ri = size.width;

      path.moveTo(l + r, 0);
      path.lineTo(ri - r, 0);
      path.arcToPoint(
        Offset(ri, r),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(ri, size.height - r);
      path.arcToPoint(
        Offset(ri - r, size.height),
        radius: Radius.circular(r),
        clockwise: true,
      );
      path.lineTo(l + r, size.height);

      if (hasTail) {
        path.arcToPoint(
          Offset(l, size.height - r * 0.4),
          radius: Radius.circular(r * 0.7),
          clockwise: true,
        );
        path.lineTo(l, size.height - tailH);
        path.quadraticBezierTo(
          l - tailW * 0.4,
          size.height - tailH * 0.3,
          l - tailW,
          size.height,
        );
        path.lineTo(l + r * 0.6, size.height);
      } else {
        path.arcToPoint(
          Offset(l, size.height - r),
          radius: Radius.circular(r),
          clockwise: true,
        );
      }

      path.lineTo(l, r);
      path.arcToPoint(
        Offset(l + r, 0),
        radius: Radius.circular(r),
        clockwise: true,
      );
    }

    path.close();

    // Subtle shadow for received bubbles
    if (!isMe) {
      canvas.drawShadow(path, Colors.black.withValues(alpha: 0.12), 2.0, false);
    }

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Border for received bubbles
    if (borderColor != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.isMe != isMe ||
      old.hasTail != hasTail ||
      old.color != color ||
      old.borderColor != borderColor;

  @override
  bool hitTest(Offset position) => true;
}

/// Quoted reply block shown inside a
/// bubble when replying to a message.
class _ReplyBlock extends StatelessWidget {
  final String body;
  final bool isMe;

  const _ReplyBlock({required this.body, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.brand.withValues(alpha: 0.12)
            : AppColors.hoverSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: AppColors.brand, width: 3)),
      ),
      child: Text(
        body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.cardLabel.copyWith(
          color: isMe ? AppColors.accent : AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Emoji reactions shown below a bubble.
class _ReactionsRow extends StatelessWidget {
  final List<String> reactions;
  final bool isMe;

  const _ReactionsRow({required this.reactions, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        left: isMe ? 0 : 10,
        right: isMe ? 10 : 0,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: reactions
            .map(
              (e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderSolid,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(e, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage? message;
  final bool isMe;
  final List<String> reactions;
  final String? replyToBody;
  final PendingMessage? pending;
  final VoidCallback? onVideoTap;
  final String orderId;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const ChatMessageBubble({
    super.key,
    this.message,
    required this.isMe,
    required this.orderId,
    this.reactions = const [],
    this.replyToBody,
    this.pending,
    this.onVideoTap,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  }) : assert(message != null || pending != null);

  factory ChatMessageBubble.pending({
    required PendingMessage pending,
    required bool isMe,
    required String orderId,
    VoidCallback? onVideoTap,
    bool isFirstInGroup = true,
    bool isLastInGroup = true,
  }) {
    return ChatMessageBubble(
      isMe: isMe,
      orderId: orderId,
      pending: pending,
      onVideoTap: onVideoTap,
      isFirstInGroup: isFirstInGroup,
      isLastInGroup: isLastInGroup,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pending != null) {
      return _PendingBubble(
        pending: pending!,
        isMe: isMe,
        onVideoTap: onVideoTap,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
      );
    }
    final msg = message!;

    if (msg.isDeleted) {
      final bubble = _DeletedBubble(
        isMe: isMe,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
      );
      if (reactions.isEmpty) return bubble;
      return Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubble,
          _ReactionsRow(reactions: reactions, isMe: isMe),
        ],
      );
    }

    final statusKey = _messageStatusKey(msg);
    // ignore: unused_local_variable
    final hasTail = isFirstInGroup;
    final Widget child;
    switch (msg.messageType) {
      case 'voice_note':
        child = _VoiceNoteBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        );
        break;
      case 'image':
        child = _ImageBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        );
        break;
      case 'video':
        child = _VideoBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
          onTap: onVideoTap,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        );
        break;
      case 'file':
        child = _FileBubble(
          message: msg,
          isMe: isMe,
          statusKey: statusKey,
          replyToBody: replyToBody,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
        );
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
        child = _SystemPill(text: msg.body ?? 'Bid won', icon: '🎉');
        break;
      case 'bid_lost':
        child = _SystemPill(
          text: msg.body ?? 'Bid was not successful',
          icon: '—',
        );
        break;
      case 'shipping_update':
        child = _ShippingUpdateCard(message: msg);
        break;
      case 'stage_update':
      case 'system':
        child = _SystemPill(text: msg.body ?? '');
        break;
      default:
        child = _TextBubble(
          message: msg,
          isMe: isMe,
          replyToBody: replyToBody,
          statusKey: statusKey,
          isFirstInGroup: isFirstInGroup,
          isLastInGroup: isLastInGroup,
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
        _ReactionsRow(reactions: reactions, isMe: isMe),
      ],
    );
  }
}

class _PendingBubble extends StatelessWidget {
  final PendingMessage pending;
  final bool isMe;
  final VoidCallback? onVideoTap;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _PendingBubble({
    required this.pending,
    required this.isMe,
    this.onVideoTap,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
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
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
      );
    } else if (pending.messageType == 'video' && pending.localPath != null) {
      child = _VideoBubble(
        message: null,
        isMe: isMe,
        localPath: pending.localPath,
        uploadProgress: pending.progress < 1 ? pending.progress : null,
        statusKey: 'pending',
        onTap: onVideoTap,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
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
          child: Icon(
            Icons.access_time_rounded,
            size: 11,
            color: AppColors.chatSentTimestamp,
          ),
        ),
      ],
    );
  }
}

/// Renders message body with timestamp
/// inline after the text (Wrap), matching
/// WhatsApp-style flow.
class _MessageWithInlineMeta extends StatelessWidget {
  final String body;
  final bool isMe;
  final String statusKey;
  final DateTime sentAt;

  const _MessageWithInlineMeta({
    required this.body,
    required this.isMe,
    required this.statusKey,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final meta = isMe ? _sentMeta(sentAt, statusKey) : _receivedMeta(sentAt);

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 4,
          children: [
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14.5,
                color: isMe ? AppColors.textPrimary : AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 1), child: meta),
          ],
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
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _TextBubble({
    required this.message,
    required this.isMe,
    this.replyToBody,
    required this.statusKey,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasTail = isFirstInGroup;
    final tailW = hasTail ? 6.5 : 0.0;
    final body = message.body ?? '';

    return Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 6 : 1.5,
        bottom: isLastInGroup ? 2 : 1.5,
        // Push sent messages to the right,
        // received to the left. The tail
        // eats into the bubble width so we
        // compensate with margin on the
        // opposite side.
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: CustomPaint(
        painter: _BubblePainter(
          isMe: isMe,
          hasTail: hasTail,
          color: isMe ? AppColors.chatSentBubble : AppColors.background,
          borderColor: isMe ? null : AppColors.chatSurfaceBorder,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            // Left padding: received bubbles
            // need extra room for the tail
            isMe ? 10 : 10 + tailW,
            8,
            // Right padding: sent bubbles
            // need extra room for the tail
            isMe ? 10 + tailW : 10,
            7,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxBubbleWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (replyToBody != null && replyToBody!.isNotEmpty)
                  _ReplyBlock(body: replyToBody!, isMe: isMe),
                _MessageWithInlineMeta(
                  body: body,
                  isMe: isMe,
                  statusKey: statusKey,
                  sentAt: message.sentAt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceNoteBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final String statusKey;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _VoiceNoteBubble({
    required this.message,
    required this.isMe,
    required this.statusKey,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  State<_VoiceNoteBubble> createState() => _VoiceNoteBubbleState();
}

class _VoiceNoteBubbleState extends State<_VoiceNoteBubble>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _waveCtrl;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // 30 bars with organic heights that
  // mimic a natural audio waveform
  static const _barHeights = <double>[
    8,
    14,
    20,
    12,
    22,
    10,
    18,
    24,
    9,
    15,
    21,
    13,
    19,
    11,
    23,
    8,
    16,
    22,
    10,
    14,
    20,
    12,
    18,
    9,
    22,
    15,
    11,
    19,
    8,
    16,
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _player.positionStream.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
    _player.durationStream.listen((d) {
      if (mounted && d != null) {
        setState(() => _duration = d);
      }
    });
    _player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s.playing);
      if (s.playing) {
        _waveCtrl.repeat(reverse: true);
      } else {
        _waveCtrl.stop();
      }
      if (s.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final url = widget.message.mediaUrl;
    if (url == null || url.isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_player.audioSource == null) {
        await _player.setUrl(url);
      }
      await _player.play();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.isMe;
    final hasTail = widget.isFirstInGroup;
    final tailW = hasTail ? 6.5 : 0.0;

    final totalSecs = _duration.inSeconds > 0
        ? _duration.inSeconds
        : (widget.message.mediaDurationSecs ?? 1);
    final elapsed = _position.inSeconds;
    final progress = totalSecs > 0
        ? (elapsed / totalSecs).clamp(0.0, 1.0)
        : 0.0;
    final bars = _barHeights.length;
    final filledBars = (progress * bars).round();

    final durationLabel = _isPlaying || elapsed > 0
        ? _fmt(_position)
        : _fmt(Duration(seconds: widget.message.mediaDurationSecs ?? 0));

    return Container(
      margin: EdgeInsets.only(
        top: widget.isFirstInGroup ? 6 : 1.5,
        bottom: widget.isLastInGroup ? 2 : 1.5,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: CustomPaint(
        painter: _BubblePainter(
          isMe: isMe,
          hasTail: hasTail,
          color: isMe ? AppColors.chatSentBubble : AppColors.background,
          borderColor: isMe ? null : AppColors.chatSurfaceBorder,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMe ? 10 : 10 + tailW,
            10,
            isMe ? 10 + tailW : 10,
            8,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxBubbleWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _toggle,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brand.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _waveCtrl,
                          builder: (_, __) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(bars, (i) {
                                final isFilled = i < filledBars;
                                double h = _barHeights[i];
                                if (_isPlaying && isFilled) {
                                  h += _waveCtrl.value * 3.0;
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.0,
                                  ),
                                  width: 2.5,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: isFilled
                                        ? AppColors.brand
                                        : AppColors.brand.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          durationLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: isMe
                                ? AppColors.chatSentTimestamp
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                isMe
                    ? _sentMeta(widget.message.sentAt, widget.statusKey)
                    : _receivedMeta(widget.message.sentAt),
              ],
            ),
          ),
        ),
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
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _ImageBubble({
    this.message,
    required this.isMe,
    this.localPath,
    this.uploadProgress,
    required this.statusKey,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  static void _openFullScreen(
    BuildContext context,
    String url,
    String heroTag,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) =>
            _FullScreenImageViewer(url: url, heroTag: heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = message?.mediaUrl;
    final showProgress = uploadProgress != null && uploadProgress! < 1.0;
    final heroTag = 'chat_img_${message?.id ?? localPath ?? ''}';
    final hasTail = isFirstInGroup;
    final r = _kBubbleRadius;

    Widget content;
    if (localPath != null) {
      content = buildLocalImage(
        localPath!,
        fit: BoxFit.cover,
        errorWidget: const Icon(Icons.broken_image),
      );
    } else if (url != null && url.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
      );
    } else {
      content = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? r : (hasTail ? 2.0 : r)),
      topRight: Radius.circular(isMe ? (hasTail ? 2.0 : r) : r),
      bottomLeft: Radius.circular(isMe ? r : (isLastInGroup ? r : 2.0)),
      bottomRight: Radius.circular(isMe ? (isLastInGroup ? r : 2.0) : r),
    );

    Widget img = Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 6 : 1.5,
        bottom: isLastInGroup ? 2 : 1.5,
        left: isMe ? 52 : (hasTail ? 6.5 : 0),
        right: isMe ? (hasTail ? 6.5 : 0) : 52,
      ),
      constraints: const BoxConstraints(
        maxWidth: 220,
        maxHeight: 280,
        minWidth: 120,
        minHeight: 120,
      ),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
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
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (message != null)
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isMe
                    ? _sentMeta(message!.sentAt, statusKey)
                    : _receivedMeta(message!.sentAt),
              ),
            ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty && !showProgress) {
      img = GestureDetector(
        onTap: () => _openFullScreen(context, url, heroTag),
        child: Hero(tag: heroTag, child: img),
      );
    }

    return img;
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String url;
  final String heroTag;

  const _FullScreenImageViewer({required this.url, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 6.0,
                  child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
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
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _VideoBubble({
    this.message,
    required this.isMe,
    this.localPath,
    this.uploadProgress,
    required this.statusKey,
    this.onTap,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
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
    final hasTail = isFirstInGroup;
    final r = _kBubbleRadius;

    Widget thumbnail;
    if (localPath != null) {
      thumbnail = buildLocalImage(
        localPath!,
        fit: BoxFit.cover,
        errorWidget: const ColoredBox(
          color: AppColors.textPrimary,
          child: Center(
            child: Icon(
              Icons.videocam,
              color: Colors.white54,
              size: 32,
            ),
          ),
        ),
      );
    } else if (thumbUrl != null && thumbUrl.isNotEmpty) {
      thumbnail = CachedNetworkImage(
        imageUrl: thumbUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const ColoredBox(
          color: AppColors.textPrimary,
          child: Center(
            child: Icon(Icons.videocam, color: Colors.white54, size: 32),
          ),
        ),
      );
    } else {
      thumbnail = const ColoredBox(
        color: AppColors.textPrimary,
        child: Center(
          child: Icon(Icons.videocam, color: Colors.white54, size: 32),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 6 : 1.5,
        bottom: isLastInGroup ? 2 : 1.5,
        left: isMe ? 52 : (hasTail ? 6.5 : 0),
        right: isMe ? (hasTail ? 6.5 : 0) : 52,
      ),
      constraints: const BoxConstraints(
        maxWidth: 220,
        maxHeight: 260,
        minWidth: 120,
        minHeight: 120,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMe ? r : (hasTail ? 2.0 : r)),
          topRight: Radius.circular(isMe ? (hasTail ? 2.0 : r) : r),
          bottomLeft: Radius.circular(isMe ? r : (isLastInGroup ? r : 2.0)),
          bottomRight: Radius.circular(isMe ? (isLastInGroup ? r : 2.0) : r),
        ),
        color: AppColors.textPrimary,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          thumbnail,
          if (!showProgress)
            Center(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          if (showProgress)
            Container(
              color: Colors.black54,
              child: Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: uploadProgress,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 6,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _durationLabel(message?.mediaDurationSecs),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
                if (isMe && message != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _sentMeta(message!.sentAt, statusKey),
                  ),
              ],
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
  final String? replyToBody;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _FileBubble({
    required this.message,
    required this.isMe,
    required this.statusKey,
    this.replyToBody,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasTail = isFirstInGroup;
    final tailW = hasTail ? 6.5 : 0.0;

    return Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 6 : 1.5,
        bottom: isLastInGroup ? 2 : 1.5,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: CustomPaint(
        painter: _BubblePainter(
          isMe: isMe,
          hasTail: hasTail,
          color: isMe ? AppColors.chatSentBubble : AppColors.background,
          borderColor: isMe ? null : AppColors.chatSurfaceBorder,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMe ? 10 : 10 + tailW,
            10,
            isMe ? 10 + tailW : 10,
            8,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxBubbleWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (replyToBody != null && replyToBody!.isNotEmpty)
                  _ReplyBlock(body: replyToBody!, isMe: isMe),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.insert_drive_file_rounded,
                        color: AppColors.brand,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message.mediaFileName ?? 'File',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: isMe ? AppColors.textPrimary : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: isMe
                      ? _sentMeta(message.sentAt, statusKey)
                      : _receivedMeta(message.sentAt),
                ),
              ],
            ),
          ),
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
      color: AppColors.infoBackground,
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
      color: AppColors.successMutedBackgroundAlt,
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

class _DeletedBubble extends StatelessWidget {
  final bool isMe;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const _DeletedBubble({
    required this.isMe,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasTail = isFirstInGroup;
    final tailW = hasTail ? 6.5 : 0.0;

    return Container(
      margin: EdgeInsets.only(
        top: isFirstInGroup ? 6 : 1.5,
        bottom: isLastInGroup ? 2 : 1.5,
        left: isMe ? 52 : 0,
        right: isMe ? 0 : 52,
      ),
      child: CustomPaint(
        painter: _BubblePainter(
          isMe: isMe,
          hasTail: hasTail,
          color: isMe ? AppColors.hoverSurface : AppColors.composerBackground,
          borderColor: AppColors.borderSolid,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMe ? 12 : 12 + tailW,
            8,
            isMe ? 12 + tailW : 12,
            8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'This message was deleted',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13.5,
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemPill extends StatelessWidget {
  final String text;
  final String? icon;

  const _SystemPill({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderSolid, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            icon != null && icon!.isNotEmpty ? '$icon  $text' : text,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPlaceholder,
              letterSpacing: 0.1,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

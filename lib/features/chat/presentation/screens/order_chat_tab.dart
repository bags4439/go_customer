import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_message_widgets.dart';

/// Date divider label for a given date (Today, Yesterday, or formatted date).
String _dateDividerLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Today';
  if (d == yesterday) return 'Yesterday';
  return '${date.day}/${date.month}/${date.year}';
}

/// Groups messages with date dividers. Returns a list of items: either
/// _DateDivider or _MessageItem.
sealed class _ListItem {}

class _DateDivider implements _ListItem {
  final String label;
  _DateDivider(this.label);
}

class _MessageItem implements _ListItem {
  final ChatMessage message;
  _MessageItem(this.message);
}

class _PendingItem implements _ListItem {
  final PendingMessage pending;
  _PendingItem(this.pending);
}

List<_ListItem> _messagesWithDateDividersFromDisplay(
    List<Object> displayMessages, String userId) {
  final result = <_ListItem>[];
  DateTime? lastDate;
  for (final obj in displayMessages) {
    DateTime sentAt;
    if (obj is ChatMessage) {
      sentAt = obj.sentAt;
      final d = DateTime(sentAt.year, sentAt.month, sentAt.day);
      if (lastDate != d) {
        lastDate = d;
        result.add(_DateDivider(_dateDividerLabel(sentAt)));
      }
      result.add(_MessageItem(obj));
    } else {
      final p = obj as PendingMessage;
      sentAt = p.sentAt;
      final d = DateTime(sentAt.year, sentAt.month, sentAt.day);
      if (lastDate != d) {
        lastDate = d;
        result.add(_DateDivider(_dateDividerLabel(sentAt)));
      }
      result.add(_PendingItem(p));
    }
  }
  return result;
}

class OrderChatTab extends ConsumerStatefulWidget {
  final String orderId;

  const OrderChatTab({super.key, required this.orderId});

  @override
  ConsumerState<OrderChatTab> createState() => _OrderChatTabState();
}

class _OrderChatTabState extends ConsumerState<OrderChatTab> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markChatAsRead(ref, widget.orderId);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 0) {
      final pagination = ref.read(chatPaginationNotifierProvider(widget.orderId));
      if (pagination.isLoadingMore || !pagination.hasMoreMessages) return;
      final lastDoc = pagination.lastDocumentForLoadMore ??
          ref.read(chatFirstPageLastDocProvider(widget.orderId));
      if (lastDoc != null) {
        ref.read(chatPaginationNotifierProvider(widget.orderId).notifier).loadMore(lastDoc);
      }
    }
  }

  void _openFullScreenVideo(BuildContext context, String mediaUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _FullScreenVideoPage(mediaUrl: mediaUrl),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final orderAsync = ref.watch(orderProvider(orderId));
    final displayMessages = ref.watch(chatDisplayMessagesProvider(orderId));
    final reactionsAsync = ref.watch(messageReactionsProvider(orderId));
    final typingAsync = ref.watch(agentTypingProvider(orderId));
    final input = ref.watch(messageInputProvider);
    final replyState = ref.watch(replyStateProvider(orderId));

    ref.listen<List<Object>>(chatDisplayMessagesProvider(orderId), (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return Column(
      children: [
        orderAsync.when(
          data: (order) {
            if (order?.agentId == null) return const SizedBox.shrink();
            return _ChatAgentHeader(
              orderId: orderId,
              agentId: order!.agentId!,
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        typingAsync.when(
          data: (isTyping) {
            if (!isTyping) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              alignment: Alignment.centerLeft,
              child: Text(
                'Agent is typing…',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: displayMessages.isEmpty
              ? const Center(
                  child: Text('Start the conversation with your agent.'),
                )
              : Builder(
                  builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom());
                    final userId = ref.watch(authStateProvider).value;
                    final reactions = reactionsAsync.valueOrNull ?? {};
                    final pageResult = ref.watch(messagesProvider(orderId)).valueOrNull;
                    final streamMessages = pageResult?.messages ?? [];
                    final idToBody = {
                      for (final m in streamMessages) m.id: (m.body ?? '')
                    };
                    final pagination = ref.watch(chatPaginationNotifierProvider(orderId));
                    for (final m in pagination.olderMessages) {
                      idToBody[m.id] = m.body ?? '';
                    }
                    final items = _messagesWithDateDividersFromDisplay(
                        displayMessages, userId ?? '');

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          if (pagination.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          if (!pagination.hasMoreMessages && items.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Beginning of conversation',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final itemIndex = index - 1;
                        final item = items[itemIndex];
                        if (item is _DateDivider) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F4F0),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          );
                        }
                        if (item is _MessageItem) {
                          final msg = item.message;
                          final isMe = msg.senderId == userId;
                          final replyToBody = msg.replyToMessageId != null
                              ? idToBody[msg.replyToMessageId]
                              : null;
                          final messageReactions =
                              reactions[msg.id] ?? const [];

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () async {
                                final result =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (ctx) => _MessageActionSheet(
                                    orderId: orderId,
                                    messageId: msg.id,
                                    messageBody: msg.body,
                                  ),
                                );
                                if (result != null) {
                                  if (result == 'reply') {
                                    ref
                                        .read(replyStateProvider(orderId).notifier)
                                        .state = ReplyState(
                                            messageId: msg.id, body: msg.body);
                                  } else {
                                    await toggleReactionForMessage(
                                      ref,
                                      orderId: orderId,
                                      messageId: msg.id,
                                      emoji: result,
                                    );
                                  }
                                }
                              },
                              child: ChatMessageBubble(
                                message: msg,
                                isMe: isMe,
                                reactions: messageReactions,
                                replyToBody: replyToBody,
                                onVideoTap: msg.messageType == 'video' && msg.mediaUrl != null
                                    ? () => _openFullScreenVideo(context, msg.mediaUrl!)
                                    : null,
                              ),
                            ),
                          );
                        }
                        final pending = (item as _PendingItem).pending;
                        const isMe = true;
                        return Align(
                          alignment: Alignment.centerRight,
                          child: ChatMessageBubble.pending(
                            pending: pending,
                            isMe: isMe,
                            onVideoTap: () {},
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        if (replyState != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFFF5F4F0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to: ${replyState.body ?? '…'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    ref.read(replyStateProvider(orderId).notifier).state = null;
                  },
                ),
              ],
            ),
          ),
        _ImagePreviewStrip(orderId: orderId),
        _VideoPreviewBar(orderId: orderId),
        const Divider(height: 1),
        _InputBar(orderId: orderId, text: input),
      ],
    );
  }
}

class _ChatAgentHeader extends ConsumerWidget {
  final String orderId;
  final String agentId;

  const _ChatAgentHeader({
    required this.orderId,
    required this.agentId,
  });

  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentDetailProvider(agentId));

    return agentAsync.when(
      data: (agent) {
        if (agent == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF378ADD),
                child: Text(
                  agent.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${agent.totalOrdersCompleted} orders · ${agent.rating.toStringAsFixed(1)} ★',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (agent.phone != null && agent.phone!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => _launchCall(agent.phone),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ImagePreviewStrip extends ConsumerWidget {
  final String orderId;

  const _ImagePreviewStrip({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(pendingSelectedImagesProvider(orderId));
    if (images.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: const Color(0xFFF5F4F0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == images.length) {
            return Center(
              child: TextButton.icon(
                onPressed: () => sendSelectedImagesForOrder(ref, orderId),
                icon: const Icon(Icons.send, size: 20),
                label: const Text('Send all'),
              ),
            );
          }
          final path = images[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: path.isNotEmpty
                      ? Image.file(File(path), fit: BoxFit.cover)
                      : const Icon(Icons.image),
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: () => removePendingImage(ref, orderId, index),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xFFE24B4A),
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VideoPreviewBar extends ConsumerWidget {
  final String orderId;

  const _VideoPreviewBar({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoPath = ref.watch(pendingVideoPathProvider(orderId));
    if (videoPath == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFFF5F4F0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 60,
              child: _VideoThumbnail(path: videoPath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Video ready', style: Theme.of(context).textTheme.bodySmall)),
          TextButton(
            onPressed: () => sendVideoForOrder(ref, orderId),
            child: const Text('Send'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                ref.read(pendingVideoPathProvider(orderId).notifier).state = null,
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final String path;

  const _VideoThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(File(snapshot.data!), fit: BoxFit.cover);
        }
        return const ColoredBox(
          color: Colors.black26,
          child: Center(child: Icon(Icons.videocam)),
        );
      },
    );
  }

  Future<String?> _getThumbnail() async {
    try {
      final file = await VideoCompress.getFileThumbnail(path);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

class _InputBar extends ConsumerStatefulWidget {
  final String orderId;
  final String text;

  const _InputBar({required this.orderId, required this.text});

  @override
  ConsumerState<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends ConsumerState<_InputBar> {
  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _recordingStopwatch = Stopwatch();
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(_InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text.isEmpty && oldWidget.text.isNotEmpty) {
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final isRecording = ref.read(isRecordingProvider);
    if (isRecording) {
      ref.read(isRecordingProvider.notifier).state = false;
      try {
        final path = await _recorder.stop();
        if (path != null) {
          final durationSecs =
              _recordingStopwatch.elapsed.inSeconds.clamp(1, 999);
          _recordingStopwatch.stop();
          _recordingStopwatch.reset();
          final file = File(path);
          if (file.existsSync()) {
            await sendVoiceNoteForOrder(
              ref,
              widget.orderId,
              file: file,
              durationSecs: durationSecs,
            );
          }
        }
      } catch (_) {}
      return;
    }

    final dir = Directory.systemTemp;
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
      }
      return;
    }
    try {
      await _recorder.start(
        const RecordConfig(bitRate: 64000),
        path: path,
      );
      _recordingStopwatch.start();
      ref.read(isRecordingProvider.notifier).state = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording failed: $e')),
        );
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final xFiles = await picker.pickMultiImage(limit: 5);
    if (xFiles.isEmpty) return;
    final paths = xFiles
        .map((x) => x.path)
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .toList();
    if (paths.isEmpty) return;
    addPendingImagePaths(ref, widget.orderId, paths);
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 10),
    );
    if (video != null && video.path.isNotEmpty) {
      ref.read(pendingVideoPathProvider(widget.orderId).notifier).state =
          video.path;
    }
  }

  void _showAttachMenu() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Photos (up to 5)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record video (up to 10s)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(ctx);
                  sendFileForOrder(ref, widget.orderId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = ref.watch(isRecordingProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAttachMenu,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Message your agent…',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: (value) =>
                    ref.read(messageInputProvider.notifier).state = value,
              ),
            ),
            IconButton(
              icon: Icon(
                isRecording ? Icons.stop : Icons.mic,
                color: isRecording ? Colors.red : const Color(0xFF378ADD),
              ),
              onPressed: _toggleRecording,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: const Color(0xFF378ADD),
              onPressed: () => sendTextMessageForOrder(ref, widget.orderId),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: Reply + reaction emojis. Pops with 'reply' or the emoji string.
class _MessageActionSheet extends StatelessWidget {
  final String orderId;
  final String messageId;
  final String? messageBody;

  const _MessageActionSheet({
    required this.orderId,
    required this.messageId,
    this.messageBody,
  });

  static const List<String> _emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () => Navigator.of(context).pop('reply'),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _emojis
                    .map(
                      (e) => IconButton(
                        onPressed: () => Navigator.of(context).pop(e),
                        icon: Text(
                          e,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenVideoPage extends StatefulWidget {
  final String mediaUrl;

  const _FullScreenVideoPage({required this.mediaUrl});

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    _videoController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF378ADD),
            handleColor: const Color(0xFF378ADD),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_chewieController != null)
            Center(child: Chewie(controller: _chewieController!)),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

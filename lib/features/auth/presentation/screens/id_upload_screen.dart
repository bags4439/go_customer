import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../providers/auth_providers.dart';

class IdUploadScreen extends ConsumerStatefulWidget {
  const IdUploadScreen({super.key});

  @override
  ConsumerState<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends ConsumerState<IdUploadScreen> {
  bool _uploading = false;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;
    ref.read(selectedIdFileProvider.notifier).state = result.files.first;
  }

  Future<void> _continue() async {
    final authState = ref.read(authStateProvider).value;
    if (authState == null) return;

    final file = ref.read(selectedIdFileProvider);
    if (file != null && file.path != null) {
      setState(() => _uploading = true);
      try {
        final ext = file.extension ?? 'jpg';
        await ref.read(uploadIdDocumentUseCaseProvider).call(
              userId: authState,
              localFilePath: file.path!,
              extension: ext,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
          setState(() => _uploading = false);
          return;
        }
      }
      if (mounted) setState(() => _uploading = false);
    }
    if (mounted) {
      context.goNamed(RouteConstants.accountCreated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedIdFileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your identity')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'We need a copy of your Ghana card or passport to process your import documents.',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pick,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    selected == null
                        ? 'Upload Ghana card or passport'
                        : selected.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('JPG, PNG or PDF - Max 5MB'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Your ID is only used for customs and port clearance documents. '
                'It is never shared with third parties.',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploading ? null : _continue,
              child: Text(_uploading ? 'Uploading...' : 'Continue'),
            ),
            TextButton(
              onPressed: () => context.goNamed(RouteConstants.accountCreated),
              child: const Text("I'll do this later"),
            ),
          ],
        ),
      ),
    );
  }
}


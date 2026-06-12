import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/dashboard_layout.dart';
import '../../../../core/widgets/standalone_mobile_screen_scaffold.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import '../widgets/id_verification/id_verification_form.dart';

/// Full-screen ID verification (mobile and deep links).
class IdVerificationScreen extends ConsumerWidget {
  const IdVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarDocLabel =
        ref.watch(currentUserProfileProvider).valueOrNull?.idDocumentLabel ??
            ProfileConstants.idVerificationTitle;

    return StandaloneMobileScreenScaffold(
      title: appBarDocLabel,
      onBack: () => context.pop(),
      body: IdVerificationForm(
        padding: DashboardLayout.bodyScrollPadding(
          context,
          top: 24,
          bottom: 40,
        ),
        onSuccess: () {
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}

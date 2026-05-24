import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
          style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        ),
        title: Text(
          appBarDocLabel,
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.borderSolid),
        ),
      ),
      body: IdVerificationForm(
        onSuccess: () {
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}

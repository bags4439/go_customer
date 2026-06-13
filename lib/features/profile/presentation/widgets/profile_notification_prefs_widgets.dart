import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/styled_snackbar.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../core/constants/profile_constants.dart';
import '../providers/profile_providers.dart';
import 'profile_section_shell.dart';
import 'package:go_customer/core/theme/app_colors.dart';

class ProfileNotificationsSection extends ConsumerWidget {
  const ProfileNotificationsSection({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = user.notificationPreferences;
    return Column(
      children: [
        ProfileNotificationToggleRow(
          label: ProfileConstants.notifAgentMessages,
          subtitle: ProfileConstants.notifAgentMessagesSubtitle,
          value: prefs['agentMessages'] ?? true,
          prefKey: 'agentMessages',
          userId: user.id,
        ),
        const ProfileSectionDivider(),
        ProfileNotificationToggleRow(
          label: ProfileConstants.notifOrderUpdates,
          subtitle: ProfileConstants.notifOrderUpdatesSubtitle,
          value: prefs['orderUpdates'] ?? true,
          prefKey: 'orderUpdates',
          userId: user.id,
        ),
        const ProfileSectionDivider(),
        ProfileNotificationToggleRow(
          label: ProfileConstants.notifPaymentRequests,
          subtitle: ProfileConstants.notifPaymentRequestsSubtitle,
          value: prefs['paymentRequests'] ?? true,
          prefKey: 'paymentRequests',
          userId: user.id,
        ),
        const ProfileSectionDivider(),
        ProfileNotificationToggleRow(
          label: ProfileConstants.notifPromotions,
          subtitle: ProfileConstants.notifPromotionsSubtitle,
          value: prefs['promotionsAndNews'] ?? false,
          prefKey: 'promotionsAndNews',
          userId: user.id,
        ),
      ],
    );
  }
}

class ProfileNotificationToggleRow extends ConsumerStatefulWidget {
  const ProfileNotificationToggleRow({
    super.key,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.prefKey,
    required this.userId,
  });

  final String label;
  final String subtitle;
  final bool value;
  final String prefKey;
  final String userId;

  @override
  ConsumerState<ProfileNotificationToggleRow> createState() =>
      _ProfileNotificationToggleRowState();
}

class _ProfileNotificationToggleRowState
    extends ConsumerState<ProfileNotificationToggleRow> {
  bool _saving = false;
  late bool _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(ProfileNotificationToggleRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_saving) _localValue = widget.value;
  }

  Future<void> _onToggle(bool v) async {
    setState(() {
      _saving = true;
      _localValue = v;
    });
    final result = await ref
        .read(profileRepositoryProvider)
        .updateNotificationPreference(widget.userId, widget.prefKey, v);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold((_) {
      setState(() => _localValue = widget.value);
      showErrorSnackBar(
        context,
        ProfileConstants.errorUpdatePreference,
        actionLabel: ProfileConstants.retry,
        onAction: () => _onToggle(v),
      );
    }, (_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.cardLabel.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brand,
                  ),
                ),
              ),
            )
          else
            CupertinoSwitch(
              value: _localValue,
              onChanged: _onToggle,
              activeTrackColor: AppColors.brand,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_customer/core/theme/app_text_styles.dart';
import 'package:go_customer/core/widgets/styled_snackbar.dart';

import '../../core/constants/profile_constants.dart';
import '../../domain/entities/user_session_entity.dart';
import '../providers/profile_providers.dart';
import 'profile_section_shell.dart';
import 'package:go_customer/core/theme/app_colors.dart';

/// Active sessions and “stay logged in” controls on the profile screen.
class ProfileSessionSection extends ConsumerWidget {
  const ProfileSessionSection({super.key, required this.sessions});

  final List<UserSessionEntity> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstSession = sessions.isNotEmpty ? sessions.first : null;
    return Column(
      children: [
        ProfileStayLoggedInRow(
          sessionId: firstSession?.id,
          expiresAt: firstSession?.expiresAt,
        ),
        const ProfileSectionDivider(),
        ProfileActiveSessionsRow(
          count: sessions.length,
          sessions: sessions,
          onSignOutSession: (id) async {
            await ref.read(profileRepositoryProvider).deleteSession(id);
          },
        ),
      ],
    );
  }
}

class ProfileStayLoggedInRow extends ConsumerStatefulWidget {
  const ProfileStayLoggedInRow({super.key, this.sessionId, this.expiresAt});

  final String? sessionId;
  final DateTime? expiresAt;

  @override
  ConsumerState<ProfileStayLoggedInRow> createState() =>
      _ProfileStayLoggedInRowState();
}

class _ProfileStayLoggedInRowState
    extends ConsumerState<ProfileStayLoggedInRow> {
  bool _saving = false;
  bool _localValue = true;

  @override
  void initState() {
    super.initState();
    if (widget.expiresAt != null) {
      final now = DateTime.now();
      _localValue = widget.expiresAt!.difference(now).inHours > 24;
    }
  }

  @override
  void didUpdateWidget(ProfileStayLoggedInRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_saving && widget.expiresAt != null) {
      final now = DateTime.now();
      _localValue = widget.expiresAt!.difference(now).inHours > 24;
    }
  }

  Future<void> _onToggle(bool v) async {
    if (widget.sessionId == null) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final expiresAt = v
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(hours: 24));
    final result = await ref
        .read(profileRepositoryProvider)
        .updateSessionExpiry(widget.sessionId!, expiresAt);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _localValue = v;
    });
    result.fold(
      (_) => showErrorSnackBar(context, ProfileConstants.errorUpdatePreference),
      (_) => ref.invalidate(sessionListProvider),
    );
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
                  ProfileConstants.stayLoggedIn,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  ProfileConstants.stayLoggedInSubtitle,
                  style: AppTextStyles.cardLabel.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brand,
              ),
            )
          else
            CupertinoSwitch(
              value: _localValue,
              onChanged: widget.sessionId != null ? _onToggle : null,
              activeTrackColor: AppColors.brand,
            ),
        ],
      ),
    );
  }
}

class ProfileActiveSessionsRow extends StatelessWidget {
  const ProfileActiveSessionsRow({
    super.key,
    required this.count,
    required this.sessions,
    required this.onSignOutSession,
  });

  final int count;
  final List<UserSessionEntity> sessions;
  final void Function(String) onSignOutSession;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => ProfileSessionsBottomSheet(
              sessions: sessions,
              onSignOut: onSignOutSession,
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ProfileConstants.activeSessions,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                '$count ${ProfileConstants.devicesCount}',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSessionsBottomSheet extends StatelessWidget {
  const ProfileSessionsBottomSheet({
    super.key,
    required this.sessions,
    required this.onSignOut,
  });

  final List<UserSessionEntity> sessions;
  final void Function(String) onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ProfileConstants.activeSessions,
            style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...sessions.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final date = s.lastUsedAt != null
                ? '${s.lastUsedAt!.day}/${s.lastUsedAt!.month}/${s.lastUsedAt!.year}'
                : '—';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_android,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device ${i + 1}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          date,
                          style: AppTextStyles.cardLabel.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onSignOut(s.id);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Sign out of this session',
                      style: AppTextStyles.cardLabel.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

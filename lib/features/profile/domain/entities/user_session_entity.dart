class UserSessionEntity {
  final String id;
  final String userId;
  final String? deviceToken;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;

  const UserSessionEntity({
    required this.id,
    required this.userId,
    this.deviceToken,
    this.lastUsedAt,
    this.expiresAt,
  });

  bool get isLongLived {
    if (expiresAt == null) return false;
    final now = DateTime.now();
    return expiresAt!.difference(now).inHours > 24;
  }
}

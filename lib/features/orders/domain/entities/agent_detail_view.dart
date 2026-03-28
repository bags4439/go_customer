/// Presentation-ready agent entity.
class AgentDetailView {
  final String agentId;
  final String userId;
  final String fullName;
  final String? phone;
  final String? photoUrl; // null → show initials
  final double successRate;
  final double rating;
  final int totalOrdersCompleted;
  final String introMessage;

  const AgentDetailView({
    required this.agentId,
    required this.userId,
    required this.fullName,
    this.phone,
    this.photoUrl,
    required this.successRate,
    required this.rating,
    required this.totalOrdersCompleted,
    required this.introMessage,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'AG';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

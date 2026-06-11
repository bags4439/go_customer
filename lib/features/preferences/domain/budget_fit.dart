/// Qualitative budget-vs-estimate fit for the review step (no figures shown).
enum BudgetFitTier {
  comfortableRoom,
  goodFit,
  tightFit,
  stretch,
}

class BudgetFitAssessment {
  final BudgetFitTier tier;
  final String title;
  final String subtitle;
  final String footer;

  /// 0 = stretch (left), 1 = comfortable room (right).
  final double pinPosition;

  const BudgetFitAssessment({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.pinPosition,
  });
}

const _footer =
    'Final pricing is confirmed with your agent — no payment until then.';

/// Maps buyer budget to a supportive qualitative fit (estimate used internally only).
BudgetFitAssessment? resolveBudgetFit({
  required int budgetUsd,
  required double estimateLandedUsd,
  required bool isYearRange,
}) {
  if (budgetUsd <= 0 || estimateLandedUsd <= 0) return null;

  final ratio = budgetUsd / estimateLandedUsd;
  final pin = ((ratio - 0.45) / 1.15).clamp(0.08, 0.92);

  final yearNote = isYearRange
      ? ' Flexible year range may shift what is available.'
      : '';

  final BudgetFitTier tier;
  final String title;
  final String subtitle;

  if (ratio >= 1.15) {
    tier = BudgetFitTier.comfortableRoom;
    title = 'Comfortable room';
    subtitle =
        'Plenty of room in your budget for this type of car. '
        'Your agent can prioritise condition and spec.$yearNote';
  } else if (ratio >= 0.90) {
    tier = BudgetFitTier.goodFit;
    title = 'Good fit';
    subtitle =
        'Your budget aligns well with what buyers usually pay for this spec.$yearNote';
  } else if (ratio >= 0.75) {
    tier = BudgetFitTier.tightFit;
    title = 'Tight fit';
    subtitle =
        'Your agent may need to search carefully to stay within budget.$yearNote';
  } else {
    tier = BudgetFitTier.stretch;
    title = 'Worth discussing';
    subtitle =
        'Your agent may suggest small changes to year or condition — '
        'chat first before any decisions.$yearNote';
  }

  return BudgetFitAssessment(
    tier: tier,
    title: title,
    subtitle: subtitle,
    footer: _footer,
    pinPosition: pin,
  );
}

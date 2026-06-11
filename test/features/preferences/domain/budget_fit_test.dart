import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/preferences/domain/budget_fit.dart';

void main() {
  group('resolveBudgetFit', () {
    test('returns comfortable room when budget exceeds estimate by 15%+', () {
      final fit = resolveBudgetFit(
        budgetUsd: 12000,
        estimateLandedUsd: 10000,
        isYearRange: false,
      );
      expect(fit, isNotNull);
      expect(fit!.tier, BudgetFitTier.comfortableRoom);
      expect(fit.title, 'Comfortable room');
      expect(fit.pinPosition, greaterThan(0.5));
    });

    test('returns good fit when budget is within 90-115% of estimate', () {
      final fit = resolveBudgetFit(
        budgetUsd: 9500,
        estimateLandedUsd: 10000,
        isYearRange: false,
      );
      expect(fit!.tier, BudgetFitTier.goodFit);
    });

    test('returns tight fit when budget is 75-90% of estimate', () {
      final fit = resolveBudgetFit(
        budgetUsd: 8000,
        estimateLandedUsd: 10000,
        isYearRange: false,
      );
      expect(fit!.tier, BudgetFitTier.tightFit);
    });

    test('returns stretch tier when budget is well below estimate', () {
      final fit = resolveBudgetFit(
        budgetUsd: 5000,
        estimateLandedUsd: 10000,
        isYearRange: false,
      );
      expect(fit!.tier, BudgetFitTier.stretch);
      expect(fit.title, 'Worth discussing');
      expect(fit.pinPosition, lessThan(0.5));
    });

    test('appends year range note when flexible years', () {
      final fit = resolveBudgetFit(
        budgetUsd: 9500,
        estimateLandedUsd: 10000,
        isYearRange: true,
      );
      expect(
        fit!.subtitle,
        contains('Flexible year range may shift what is available.'),
      );
    });

    test('returns null for invalid inputs', () {
      expect(
        resolveBudgetFit(
          budgetUsd: 0,
          estimateLandedUsd: 10000,
          isYearRange: false,
        ),
        isNull,
      );
    });
  });
}

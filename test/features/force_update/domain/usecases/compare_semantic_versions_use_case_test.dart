import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/force_update/domain/usecases/compare_semantic_versions_use_case.dart';

void main() {
  late CompareSemanticVersionsUseCase useCase;

  setUp(() {
    useCase = CompareSemanticVersionsUseCase();
  });

  group('CompareSemanticVersionsUseCase', () {
    test('returns true when installed patch is lower', () {
      expect(useCase.isUpdateRequired('1.0.0', '1.0.1'), isTrue);
    });

    test('returns true when installed minor is lower', () {
      expect(useCase.isUpdateRequired('1.9.0', '1.10.0'), isTrue);
    });

    test('returns false when versions are equal', () {
      expect(useCase.isUpdateRequired('2.3.4', '2.3.4'), isFalse);
    });

    test('returns false when installed version is newer', () {
      expect(useCase.isUpdateRequired('2.0.0', '1.9.9'), isFalse);
    });

    test('ignores build suffix after plus sign', () {
      expect(useCase.isUpdateRequired('1.0.0+42', '1.0.1'), isTrue);
      expect(useCase.isUpdateRequired('1.0.1+1', '1.0.1+99'), isFalse);
    });

    test('pads missing segments with zero', () {
      expect(useCase.isUpdateRequired('1.0', '1.0.1'), isTrue);
      expect(useCase.isUpdateRequired('1', '1.0.0'), isFalse);
    });

    test('fails open on invalid versions', () {
      expect(useCase.isUpdateRequired('abc', '1.0.0'), isFalse);
      expect(useCase.isUpdateRequired('1.0.0', ''), isFalse);
    });
  });
}

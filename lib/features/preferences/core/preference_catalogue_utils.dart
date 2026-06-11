import '../../../../core/constants/app_constants.dart';
import '../../catalogue/domain/entities/car_make.dart';
import '../domain/china_import_mode.dart';

/// Whether [make] is selectable for the current import mode.
bool isMakeAllowedForImportMode(CarMake make, ChinaImportMode mode) {
  final mt = make.marketType;
  return switch (mode) {
    ChinaImportMode.none =>
      mt == 'us_auction' || mt == 'both',
    ChinaImportMode.newFromChina || ChinaImportMode.usedFromChina =>
      mt == 'china' || mt == 'both',
  };
}

/// Resolves Firestore [purchaseOrigin] from import selections.
String resolvePurchaseOrigin({
  required ChinaImportMode chinaImportMode,
  required String advancedPurchaseOrigin,
}) {
  return switch (chinaImportMode) {
    ChinaImportMode.newFromChina || ChinaImportMode.usedFromChina =>
      AppConstants.purchaseOriginChina,
    ChinaImportMode.none => advancedPurchaseOrigin,
  };
}

part of '../screens/home_screen.dart';

// ─────────────────────────────────────────────
// COLOUR CONSTANTS
// ─────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF378ADD);
  static const success = Color(0xFF1D9E75);
  static const danger = Color(0xFFE24B4A);
  static const warning = Color(0xFFBA7517);
  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgSecondary = Color(0xFFF5F4F0);
  static const border = Color(0xFFE0DFD8);
  static const textPrimary = Color(0xFF1A1A18);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFFAAAAAA);
  static const infoBg = Color(0xFFE6F1FB);
  static const infoText = Color(0xFF185FA5);
  static const successBg = Color(0xFFEAF3DE);
  static const dangerBg = Color(0xFFFCEBEB);
  static const warningBg = Color(0xFFFAEEDA);
  static const pillSoftBlue = Color(0xFFEBF4FD);
  static const amberText = Color(0xFF633806);
  static const successMutedForeground = Color(0xFF27500A);
}

// ─────────────────────────────────────────────
// TEXT STYLE HELPERS
// ─────────────────────────────────────────────
TextStyle _ts({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color color = _C.textPrimary,
  double height = 1.4,
}) =>
    AppTextStyles.bodySmall.copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.directions_car_filled,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AutoImport',
          style: AppTextStyles.appBarTitle.copyWith(color: _C.textPrimary),
        ),
        Text(
          ' GH',
          style: AppTextStyles.appBarTitle.copyWith(color: _C.primary),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.pillSoftBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _C.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: _C.infoText),
          ),
        ],
      ),
    );
  }
}

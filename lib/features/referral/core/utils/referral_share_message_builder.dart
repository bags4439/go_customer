import '../../../../core/constants/app_constants.dart';
import '../constants/referral_ui_constants.dart';
import '../../domain/entities/referral_share_settings.dart';

class ReferralShareMessageBuilder {
  ReferralShareMessageBuilder._();

  static String build({
    required ReferralShareSettings settings,
    required String referralCode,
  }) {
    final buf = StringBuffer();
    buf.writeln(AppConstants.appName);
    buf.writeln();
    if (referralCode.trim().isNotEmpty) {
      buf.writeln('My referral code: ${referralCode.trim()}');
      buf.writeln();
    }
    buf.writeln(
      'Download the app and use my code when you sign up if prompted.',
    );
    buf.writeln();
    final lines = <String>[];
    if (_nonEmpty(settings.appStoreUrl)) {
      lines.add('iOS (App Store): ${settings.appStoreUrl!.trim()}');
    }
    if (_nonEmpty(settings.playstoreUrl)) {
      lines.add('Android (Google Play): ${settings.playstoreUrl!.trim()}');
    }
    if (_nonEmpty(settings.websiteUrl)) {
      lines.add('Web: ${settings.websiteUrl!.trim()}');
    }
    if (lines.isNotEmpty) {
      buf.writeln('Get the app:');
      buf.writeln(lines.join('\n'));
    }
    buf.write(ReferralUiConstants.shareMessageFooter(AppConstants.appName));
    return buf.toString();
  }

  static bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;
}

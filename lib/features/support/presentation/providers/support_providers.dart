import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/system_settings_provider.dart';

class SupportContact {
  const SupportContact({this.callNumber, this.whatsappNumber});

  final String? callNumber;
  final String? whatsappNumber;

  bool get hasCall => callNumber != null && callNumber!.trim().isNotEmpty;

  bool get hasWhatsApp =>
      whatsappNumber != null && whatsappNumber!.trim().isNotEmpty;
}

final supportContactProvider = FutureProvider<SupportContact>((ref) async {
  final settings = await ref.watch(systemSettingsProvider.future);
  return SupportContact(
    callNumber: settings.stringValue('supportCall'),
    whatsappNumber: settings.stringValue('supportWhatsApp'),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/web_order_panel_task.dart';

/// Web-only: content shown in the order-detail right panel.
final webOrderPanelTaskProvider =
    StateProvider.autoDispose<WebOrderPanelTask>(
  (ref) => const WebOrderPanelDefault(),
);

/// Resets the panel to the default overview cards.
void resetWebOrderPanelTask(WidgetRef ref) {
  ref.read(webOrderPanelTaskProvider.notifier).state =
      const WebOrderPanelDefault();
}

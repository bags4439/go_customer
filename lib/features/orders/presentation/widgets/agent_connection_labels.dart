import '../../domain/entities/order_view.dart';

/// Dynamic copy for agent-connection searching steps and next steps.
class AgentConnectionLabels {
  AgentConnectionLabels._();

  static String step3Label(OrderView order) {
    if (order.isNewVehicle) {
      return 'Agent requests dealer quotes';
    }
    return switch (order.purchaseOrigin) {
      'us_canada' => 'Agent searches US auctions',
      'dubai' => 'Agent sources from Dubai',
      'china' => 'Agent contacts China dealers',
      _ => 'Agent searches for your car',
    };
  }

  static String step4Label(OrderView order) {
    if (order.isNewVehicle) {
      return 'Quote and options sent to you';
    }
    return 'Vehicle options sent to you';
  }

  static String nextStep1Text(OrderView order) {
    if (order.isNewVehicle) {
      return 'Your agent contacts suppliers in China '
          'and requests quotes for your '
          '${order.make ?? 'vehicle'}';
    }
    return switch (order.purchaseOrigin) {
      'us_canada' =>
        'Your agent searches US/Canada auctions for your '
            '${order.make ?? 'vehicle'}',
      'dubai' =>
        'Your agent sources options from Dubai '
            'dealers for your ${order.make ?? 'vehicle'}',
      'china' =>
        'Your agent contacts Chinese dealers '
            'for your ${order.make ?? 'vehicle'}',
      _ =>
        'Your agent starts searching for your '
            '${order.make ?? 'vehicle'}',
    };
  }
}

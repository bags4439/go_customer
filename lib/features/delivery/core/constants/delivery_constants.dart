/// All copy for delivery screens.
/// No hardcoded strings in UI.
class DeliveryConstants {
  DeliveryConstants._();

  // System settings key
  static const String systemSettingsKeyDeliveryFee = 'deliveryFee';
  static const double deliveryFeeFallbackUsd = 0.0;

  // State 0 — not available
  static const String state0Heading = 'Not available yet';
  static const String state0Body =
      'Delivery will be available once '
      'your vehicle has completed the '
      'previous steps.';
  static const String state0BackButton = 'Back to order';

  // Cleared bar
  static const String clearedBarTitle = 'Vehicle ready for delivery';

  // State 1 — choice
  static const String state1Heading =
      'How would you like to '
      'receive your vehicle?';
  static const String state1Subtitle =
      'Choose how your vehicle will '
      'be delivered to you.';

  static const String optionDeliverTitle = 'Deliver to my address';
  static const String optionDeliverFeeLabel = 'Coordination fee';
  static const String optionDeliverFeeSublabel =
      'Excludes towing if required';
  static const String optionDeliverTowingNote =
      'If your vehicle requires '
      'towing, your agent will send '
      'a separate towing fee request '
      'before delivery begins.';

  static const String optionPickupTitle = 'I will pick it up myself';
  static const String optionPickupFeeLabel = 'No coordination fee';

  static const List<String> optionDeliverBullets = [
    'Agent arranges delivery to your address',
    'You set your delivery address after payment',
    'Tracked delivery with status updates',
    'Confirm receipt when vehicle arrives',
  ];

  static const List<String> optionPickupBullets = [
    'Agent shares collection point details',
    'GPS directions to collection point',
    'Confirm collection when you arrive',
  ];

  static const String confirmDeliverButton =
      'Confirm — deliver to me →';
  static const String confirmPickupButton =
      'Confirm — I will collect →';
  static const String confirmSelectOption = 'Select an option';

  // State 2 — awaiting payment
  static const String state2Heading = 'Awaiting payment clearance';
  static const String state2NoPaymentsBody =
      'Your agent is reviewing your '
      'payment status. You will be '
      'notified once all payments are '
      'confirmed and you can set your '
      'delivery address.';
  static const String state2PaymentsTitle = 'Pending payments';
  static const String state2PaymentsSubtitle =
      'Please complete the payments '
      'below. Your agent will confirm '
      'clearance once everything '
      'is settled.';
  static const String state2DeliveryFeeLabel = 'Delivery fee';
  static const String state2TowingFeeLabel = 'Towing fee';

  // State 5 — self pickup
  static const String state5Heading = 'Collection point';
  static const String state5NoDetailsBody =
      'Your agent is preparing the '
      'collection point details. '
      'You will be notified once '
      'they are ready.';
  static const String state5DirectionsButton = 'Get directions →';
  static const String state5ChatButton = 'Chat with agent';
  static const String state5ConfirmButton =
      'I have collected my vehicle ✓';
  static const String state5ConfirmDialogTitle = 'Confirm collection?';
  static const String state5ConfirmDialogBody =
      'By confirming, you acknowledge '
      'that you have collected your '
      'vehicle from the collection '
      'point.';
  static const String state5ConfirmDialogYes = 'Yes, I collected it';
  static const String state5ConfirmDialogCancel = 'Cancel';

  // Error
  static const String errorMessage =
      'Could not load delivery details.'
      ' Tap to retry.';
  static const String writeErrorMessage =
      'Something went wrong. '
      'Please try again.';
}

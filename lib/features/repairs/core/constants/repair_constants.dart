/// All copy for repair screens. No hardcoded strings in UI.
class RepairConstants {
  RepairConstants._();

  static const String systemSettingsKeyRepairFee = 'repairsServiceFee';
  static const double repairFeeFallbackUsd = 0.0;
  static const String repairFeeLabel = 'Coordination fee';

  // State 0
  static const String state0Heading = 'Not available yet';
  static const String state0Body =
      'This screen will be available once your vehicle has been cleared from Tema port.';
  static const String state0BackButton = 'Back to order';

  // Cleared bar
  static const String clearedBarTitle = 'Vehicle cleared from Tema port';
  static const String clearedBarSubtitle = 'Ready for next step';

  // State 1 – preference reminder
  static const String reminderOptedIn =
      'You selected repairs during your preferences. Your previous choice is pre-selected below. You can still change your mind.';
  static const String reminderOptedOut =
      'You opted out of repairs during your preferences. You can still change your mind below.';

  // State 1 – choice
  static const String state1Heading = 'Would you like us to arrange repairs?';
  static const String optionYesTitle = 'Yes, arrange repairs for me';
  static const String optionYesPriceLabel =
      'Coordination fee · excludes garage quote';
  static const String optionYesBullet1 = 'A garage quote is sent to you before any work starts';
  static const String optionYesBullet2 = 'You review and approve the quote — no surprises';
  static const String optionYesBullet3 = 'Car delivered to you once repairs are complete';
  static const String optionYesBullet4 = 'Before and after photos sent to you in chat';

  static const String optionNoTitle = 'No, deliver as-is';
  static const String optionNoPriceLabel = 'No coordination fee';
  static const String optionNoBullet1 =
      'Your car proceeds to delivery without repairs';
  static const String optionNoBullet2 = 'No coordination fee applies';
  static String optionNoBullet3(String agentFirstName) =>
      '$agentFirstName is still available to answer questions';

  static const String infoNote =
      'You will only be charged after you review and approve the garage quote. You can ask';
  static String infoNoteSuffix(String agentFirstName) =>
      '$agentFirstName for a second quote if you are not satisfied.';

  static const String confirmYesButton = 'Confirm - get me a quote →';
  static const String confirmNoButton = 'Confirm - deliver as-is →';
  static const String confirmButtonSelectOption = 'Select an option';
  static const String seeGaragePartners = 'See our garage partners →';

  static const String estVaries = 'Est. varies';

  // State 2
  static String state2Heading(String agentFirstName) =>
      '$agentFirstName has sent you a repair quote';
  static const String state2Subtitle =
      'Review the details below. Work only starts after you approve.';
  static const String quoteBadge = 'Awaiting your approval';
  static const String platformServiceFeeLabel = 'Platform service fee';
  static const String totalLabel = 'Total';
  static const String repairWorkLabel = 'Repair work';
  static const String acceptQuoteButton = 'Accept quote →';
  static const String declineQuoteButton = 'Decline - request another quote';
  static const String garageLabel = 'Garage';
  static const String locationLabel = 'Location';
  static const String vettedBadge = '✓ Vetted partner';
  static const String estCompletionLabel = 'Est. completion';
  static String askSecondQuote(String agentFirstName) =>
      'Not satisfied? Ask $agentFirstName for a second quote →';

  // State 2B
  static const String state2BHeading = 'Quote declined';
  static String state2BBody(String agentFirstName) =>
      '$agentFirstName has been notified and is finding an alternative garage. A new quote will appear here shortly.';
  static String askAgentButton(String agentFirstName) => 'Ask $agentFirstName';

  // State 3
  static const String state3HeroTitle = 'Repairs in progress';
  static const String state3EstCompletionPrefix = 'Est. completion:';
  static const String state3DaysLeft = 'days left';
  static const String state3FinishingUp = 'Finishing up - almost ready';
  static const String garageDetailsLabel = 'GARAGE DETAILS';
  static const String startedLabel = 'Started';
  static const String estCompletionShortLabel = 'Est. completion';
  static const String approvedQuoteLabel = 'Approved quote';
  static const String stageQuoteApproved = 'Quote approved';
  static const String stageCarDropped = 'Car dropped at garage';
  static const String stageWorkInProgress = 'Work in progress';
  static const String stageQualityCheck = 'Quality check';
  static const String stageReadyForDelivery = 'Ready for delivery';
  static const String state3PhotoNote =
      'Before and after photos will be sent to you in chat once repairs are complete.';

  // State 4
  static const String state4HeroTitle = 'Repairs complete!';
  static String state4HeroSubtitle(String makeModel) => 'Your $makeModel is ready.';
  static const String state4PhotosPlaceholder =
      'Photos will appear here once uploaded by your agent';
  static const String workCompletedLabel = 'WORK COMPLETED';
  static const String doneLabel = '✓ Done';
  static const String totalPaidLabel = 'Total paid';
  static const String readyForDeliveryLabel = 'Ready for delivery';
  static String state4DeliveryBody(String agentFirstName) =>
      'Your car is ready. Confirm your delivery address and $agentFirstName will arrange delivery.';
  static const String confirmDeliveryButton = 'Confirm delivery address →';

  // State 5
  static const String state5Heading = 'Delivering as-is';
  static const String state5Body =
      'You chose to handle repairs independently. Your car will be delivered in its current condition.';
  static String state5AgentNote(String agentFirstName) =>
      '$agentFirstName is still available if you need garage recommendations.';
  static const String state5SwitchLink =
      'Changed your mind? Arrange repairs instead →';
  static const String switchSheetTitle = 'Switch to agent-managed repairs?';
  static const String switchSheetBody =
      'A garage quote will be sent to you for approval before any work begins.';
  static const String switchSheetConfirm = 'Confirm';
  static const String switchSheetCancel = 'Cancel';

  // Before/After
  static const String beforeLabel = 'Before';
  static const String afterLabel = 'After';

  // Loading & error
  static const String errorMessage = 'Could not load repair details. Tap to retry.';
  static const String writeErrorMessage = 'Something went wrong. Please try again.';
}

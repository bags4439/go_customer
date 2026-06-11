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

  // Agent-routed — buyer waits for agent to open repair workflow
  static const String awaitingAgentTitle = 'Repairs';
  static String awaitingAgentBody(String agentFirstName) =>
      'Your vehicle has been cleared. $agentFirstName will review its condition '
      'and advise whether repairs are needed before delivery.';
  static const String awaitingAgentHint =
      'You will receive a notification when a repair quote is ready, or when '
      'your car is cleared for delivery.';

  // Legacy buyer-choice screen (deprecated — agent routes repairs)
  static const String reminderOptedIn =
      'Your agent is arranging repairs for this vehicle.';
  static const String reminderOptedOut =
      'Your agent has confirmed delivery without repairs.';

  // Legacy choice copy (agent-initiated repair jobs only)
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
  static const String platformServiceFeeSub =
      'AutoImport coordination · separate from garage costs';
  static const String garageInvoiceLabel = 'Garage invoice';
  static const String garageCostsSectionLabel = 'GARAGE COSTS';
  static const String autoImportFeeSectionLabel = 'AUTOIMPORT FEE';
  static const String invoiceSplitHint =
      'Split across two payments that make up the garage invoice';
  static const String partsDepositLabel = 'Parts deposit';
  static const String partsDepositTiming = 'Pay now · spare parts';
  static const String workmanshipBalanceLabel = 'Workmanship balance';
  static const String workmanshipTiming = 'Pay after work is complete';
  static const String totalLabel = 'Total';
  static const String totalYouPayLabel = 'Total you pay';
  static const String totalYouPaySub = 'Garage invoice + platform fee';
  static const String repairDepositDueLabel = 'Repair deposit due';
  static const String repairDepositDueSub =
      'Parts deposit + platform fee — due before work starts';
  static const String repairDepositAfterApprovalLabel =
      'Your first payment after approval';
  static const String repairDepositAfterApprovalSub =
      'Parts deposit + platform fee — sent once you approve this quote';
  static const String repairDepositPartsLine = 'Parts deposit';
  static const String repairDepositPlatformLine = 'Platform service fee';
  static const String repairDepositTotalLine = 'Deposit total';
  static const String repairWorkLabel = 'Repair work';
  static const String acceptQuoteButton = 'Accept quote →';
  static const String declineQuoteButton = 'Decline - request another quote';
  static const String garageLabel = 'Garage';
  static const String locationLabel = 'Location';
  static const String vettedBadge = '✓ Vetted partner';
  static const String estCompletionLabel = 'Est. completion';
  static String askSecondQuote(String agentFirstName) =>
      'Not satisfied? Ask $agentFirstName for a second quote →';

  // State 1.5 – awaiting quote
  static const String awaitingQuoteTitle = 'Waiting for garage quote';
  static String awaitingQuoteBody(String agentFirstName) =>
      '$agentFirstName has been notified and will send you a garage quote '
      'shortly. You will be notified when it arrives.';
  static String chatWithAgentButton(String agentFirstName) =>
      'Chat with $agentFirstName →';

  // State 2A – quote approved (deposit phase)
  static const String quoteApprovedHeroTitle = 'Quote approved';
  static const String quoteApprovedDepositPendingSub =
      'Your agent will send a repair deposit request before work begins.';
  static const String quoteApprovedDepositDueSub =
      'Pay your repair deposit from your order overview or timeline to proceed.';
  static const String quoteApprovedDepositConfirmingSub =
      'Confirming your payment — repairs will start once cleared.';
  static const String quoteApprovedDepositPaidSub =
      'Deposit paid — your agent will start repairs shortly.';
  static const String payRepairDepositButton = 'Pay repair deposit →';
  static const String payRepairBalanceButton = 'Pay repair balance →';
  static const String approvedQuoteSummaryLabel = 'Approved quote';

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
  static const String stageDepositPaid = 'Deposit paid';
  static const String stageWorkInProgress = 'Work in progress';
  static const String stageRepairsComplete = 'Repairs complete';
  static const String state3BalanceDueSub =
      'A repair balance payment is due — pay from your order overview or timeline.';
  static const String state3BalancePaidSub = 'Repair balance paid ✓';
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

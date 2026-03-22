/// All copy and keys for clearance screens. No hardcoded strings in UI.
class ClearanceConstants {
  ClearanceConstants._();

  static const String systemSettingsKeyClearanceFee = 'clearanceServiceFeeGhs';
  static const double clearanceFeeFallbackGhs = 3200.0;

  // State 0
  static const String state0Heading = 'Not available yet';
  static const String state0Body =
      'This screen will be available once your car arrives at Tema port.';
  static const String state0BackButton = 'Back to order';

  // Arrival bar
  static const String arrivalBarTitle = 'Your car arrived at Tema port';

  // State 1
  static const String state1Heading = 'How would you like to handle clearance?';
  static const String state1Subtitle =
      'Your agent is available to assist at every step regardless of what you choose.';

  static const String optionAgentTitle = 'Agent handles it for me';
  static const String optionAgentPriceLabel = 'Additional fee';
  static String optionAgentBullet1(String agentFirstName) =>
      '$agentFirstName submits all GRA documents on your behalf';
  static const String optionAgentBullet2 = 'Handles ICUMS filing and duty payment process';
  static const String optionAgentBullet3 = 'Physically manages port clearance at Tema';
  static const String optionAgentBullet4 = 'You just approve payments — nothing else needed';

  static const String optionSelfTitle = "I'll handle it myself";
  static const String optionSelfPrice = 'Free';
  static const String optionSelfPriceLabel = 'No extra charge';
  static const String optionSelfBullet1 =
      'You manage GRA / ICUMS and Tema port clearance yourself';
  static const String optionSelfBullet2 = 'You arrange your own clearing agent at Tema port';
  static const String optionSelfBullet3Suffix = 'remains available to answer questions in chat';

  static const String notSureHeading = 'Not sure which to choose?';
  static String askAgentLink(String firstName) => 'Ask $firstName for advice →';
  static const String confirmAgentButton = 'Confirm — agent handles clearance →';
  static const String confirmSelfButton = "Confirm — I'll handle it myself →";
  static const String confirmButtonSelectOption = 'Select an option';

  // State 2
  static const String stage2Arrived = 'Arrived at Tema';
  static const String stage2Assessed = 'Assessed by GRA';
  static const String stage2DutyPaid = 'Duty paid';
  static const String stage2Cleared = 'Port cleared';
  static const String detailsCardIcumsLabel = 'ICUMS ref';
  static const String detailsCardClearingAgentLabel = 'Clearing agent';
  static const String detailsCardTotalDutyLabel = 'Total duty';
  static const String detailsCardAgentNoteLabel = 'Agent note';
  static const String detailsCardPending = 'Pending';
  static const String state2AssessedNote =
      'Your agent has received the duty assessment. A payment request will appear once your agent processes the next step.';
  static String askAgentButton(String firstName) => 'Ask $firstName';

  // State 3
  static const String state3Heading = "You're handling clearance yourself";
  static const String state3Body =
      "You've chosen to manage clearance at Tema port. Your agent is still available to answer any questions or help if you get stuck.";
  static const String state3Row1 = 'Visit icums.gov.gh to file your import declaration';
  static const String state3Row2 = 'Pay duty at a GRA-approved bank or Ghana.gov';
  static const String state3Row3 = 'Engage a licensed clearing agent at Tema port';
  static const String state3NeedHelp = 'Need help?';
  static const String state3AgentHelpBodySuffix = 'can answer questions or take over clearance at any time.';
  static String state3AskAgentButton(String firstName) => 'Ask $firstName →';
  static const String state3SwitchLink =
      'Changed your mind? Let your agent handle it instead →';
  static const String switchSheetTitle = 'Switch to agent-managed clearance?';
  static const String switchSheetBodySuffix =
      'will apply. Your agent will be notified.';
  static String switchSheetBody(String feeFormatted) =>
      'An additional fee of $feeFormatted $switchSheetBodySuffix';
  static const String switchSheetConfirm = 'Confirm';
  static const String switchSheetCancel = 'Cancel';

  // Loading & error
  static const String errorMessage = 'Could not load clearance details. Tap to retry.';
  static const String writeErrorMessage = 'Something went wrong. Please try again.';
}

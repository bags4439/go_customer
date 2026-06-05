/// Strings for the dynamic order timeline (no hardcoded copy in widgets).
class OrderTimelineConstants {
  OrderTimelineConstants._();

  static const String journeyTitle = 'Journey';
  static const String retry = 'Retry';
  static const String loadError = 'Could not load timeline';
  static const String paymentRequestLabel = 'Payment request';
  static const String awaitingPayment = 'Awaiting payment';
  static const String seeBreakdown = 'See breakdown';
  static const String hideBreakdown = 'Hide breakdown';
  static const String invoiceAttached = 'Invoice attached';
  static const String viewInvoice = 'View →';
  static const String dueToday = 'Due today';
  static const String daysLeft = '[n] days left';
  static const String atRateNote = "At today's rate: 1 USD = GHS ";
  static const String payNowButton = 'Pay [amount] →';
  static const String paidCheck = 'Paid ✓';
  static const String paidShippingArranged = 'Paid ✓ — shipping being arranged';
  static const String chatWithAgent = 'Chat with agent →';
  static const String chooseClearance = 'Choose clearance option →';
  static const String rateExperience = 'Rate your experience →';
  static const String reviewScreenTitle = 'Rate your experience';
  static const String deliveredTitle = '🎉 Your vehicle has been delivered!';
  static const String deliveredThanks = 'Thank you for choosing AutoImport GH.';

  /// Generic searching subtitle when origin is unknown or not yet wired.
  static const String searchingSub =
      "Your agent is searching for your vehicle. "
      "You'll be notified when options are found.";

  /// Searching subtitle for the chat fallback, by purchase origin and vehicle type.
  static String searchingSubForOrder({
    required String purchaseOrigin,
    required bool isNewVehicle,
  }) {
    if (isNewVehicle) {
      return 'Your agent is contacting suppliers in China '
          'for your vehicle. '
          "You'll be notified when quotes arrive.";
    }
    return switch (purchaseOrigin) {
      'us_canada' =>
        "Your agent is searching Copart & IAA for your vehicle. "
            "You'll be notified when a bid is placed.",
      'dubai' =>
        "Your agent is sourcing options from Dubai dealers. "
            "You'll be notified when options arrive.",
      'china' =>
        'Your agent is contacting dealers in China. '
            "You'll be notified when options arrive.",
      _ =>
        'Your agent is searching for your vehicle. '
            "You'll be notified when options are found.",
    };
  }

  static const String deliverySub = 'Your agent is arranging delivery.';
  static const String payDepositCta = 'Pay deposit →';
  static const String questionsChat = 'Questions? Chat with agent →';
  static const String managedByAgent = 'Managed by your agent';
  static const String viewQuoteInChat = 'View quote in chat →';
  static const String viewQuote = 'View quote →';
  static const String morePhotos = '[n] more';
  static const String trackShipment = 'Track shipment →';
  static const String paymentRequired = 'PAYMENT REQUIRED';

  static const String shippingArrangingTitle = 'Shipping being arranged';
  static const String shippingArrangingSub =
      'Your agent is booking ocean freight.';
  static const String shippingEtaPrefix = 'Est. arrival: ';
  static const String shippingProgressComplete = '[n]% complete';
  static const String shippingArrivedTitle = '✅ Arrived at Tema port';
  static const String shippingArrivedSub =
      'Your vehicle is at port. Clearance is next.';
  static const String shippingBookedTitle = 'Shipping booked';
  static const String shippingBookedSub =
      'Your agent has arranged ocean freight for your vehicle.';
  static const String shippingReleasedTitle = '✅ Released from port';
  static const String shippingReleasedSub =
      'Your vehicle has been released from Tema port. Delivery is next.';
  static const String shippingViewDetails = 'View shipping details →';
  static const String agentNoteLabel = 'AGENT NOTE';

  static const String clearanceInProgressTitle = 'Clearance in progress';
  static const String clearanceInProgressSub =
      'Your agent is preparing your clearance documents.';
  static const String clearanceSubmittedTitle =
      'Documents submitted to GRA/ICUMS';
  static const String clearanceSubmittedSub =
      'Assessment is in progress. This usually takes 1–2 days.';
  static const String clearanceAssessedTitle = 'Duty assessed';
  static const String clearanceAssessedSub =
      'Your duty has been assessed. Your agent is arranging payment.';
  static const String clearanceTotalDuty = 'Total duty payable: ';
  static const String clearancePaidTitle = 'Duty paid';
  static const String clearancePaidSub =
      'Awaiting port release. This usually takes 1–3 days.';
  static const String clearanceClearedTitle =
      '✅ Vehicle cleared from Tema port';
  static const String clearanceClearedSub =
      'Your vehicle has been released. Delivery is next.';
  static const String clearanceViewDetails = 'View clearance details →';
  static const String clearanceUpdateSubmitted =
      'Update from your agent — documents submitted to GRA/ICUMS';
  static const String clearanceUpdateAssessed =
      'Update from your agent — duty assessed';
  static const String clearanceUpdatePaid =
      'Update from your agent — duty paid';
  static const String clearanceUpdateCleared =
      'Update from your agent — vehicle cleared from port';
  static const String clearanceUpdateNote =
      'Update from your agent — see note below';
  static const String clearanceHomeUpdateLine =
      'Clearance update from your agent · tap to view';
  static const String clearanceHomeCtaTitle = 'Clearance update';
  static const String clearanceHomeCtaAction = 'View details →';

  static const String repairQuotePending = 'Quote pending';
  static const String repairQuotePendingSub =
      'Your agent is preparing a repair quote.';
  static const String repairQuoteSent = 'Repair quote sent';
  static const String repairQuoteSentSub =
      'Review the quote and approve before work starts.';
  static const String repairQuoteSentTimelineDetail =
      'Repair quote ready — tap to review and approve';
  static const String repairQuoteApproved = 'Quote approved';
  static const String repairQuoteApprovedSub =
      'Your agent is preparing the deposit payment request.';
  static const String repairDepositPaid = 'Deposit paid ✓';
  static const String repairDepositPaidSub =
      'Your agent will start repairs shortly.';
  static const String repairDepositConfirmingSub =
      'Confirming your payment — repairs will start once cleared.';
  static const String repairQuoteDeclined = 'Quote declined';
  static const String repairQuoteDeclinedSub =
      'Your agent will send an updated quote shortly.';
  static const String repairInProgressTitle = '🔧 Repairs in progress';
  static const String repairGaragePrefix = 'Garage: ';
  static const String repairEstCompletion = 'Est. completion: ';
  static const String repairCompleteTitle = '✅ Repairs complete';
  static const String repairCompleteTimelineDetail =
      'Repairs complete — delivery is next';
  static const String repairInProgressTimelineDetail =
      'Your vehicle is being repaired at the garage';
  static const String repairDepositDueTimelineDetail =
      'Repair deposit due — pay to proceed';
  static const String repairBalanceDueTimelineDetail =
      'Repair balance due — pay when ready';
  static const String repairBalancePaidSub = 'Repair balance paid ✓';
  static const String repairTimelineNoJobDetail =
      'Confirm whether you want agent-managed repairs';
  static const String repairTimelineDetailQuoteApproved =
      'Quote approved — deposit request coming next';
  static const String repairTimelineDetailQuoteDeclined =
      'Quote declined — awaiting updated quote';

  static const String repairBadgeAction = 'Action needed';
  static const String repairBadgeNoRepairs = 'No repairs';
  static const String repairBadgeAwaitingQuote = 'Awaiting quote';
  static const String repairBadgeReviewQuote = 'Review quote';
  static const String repairBadgeDeclined = 'Quote declined';
  static const String repairBadgeQuoteApproved = 'Quote approved';
  static const String repairBadgeDepositDue = 'Deposit due';
  static const String repairBadgeDepositPaid = 'Deposit paid';
  static const String repairBadgeInProgress = 'In progress';
  static const String repairBadgeBalanceDue = 'Balance due';
  static const String repairBadgeComplete = 'Complete';

  static const String repairPaymentContextDeposit =
      'Quote approved — repair deposit payment';
  static const String repairPaymentContextBalance =
      'Repairs in progress — balance payment';
  static const String repairCompletedRowSub =
      'Tap to view repair summary and photos';
  static const String repairViewSummary = 'View repair summary →';

  static const String homeRepairQuoteSent =
      'Repair quote ready — review and approve';
  static const String homeRepairQuoteApproved =
      'Quote approved — awaiting deposit request';
  static const String homeRepairDepositDue =
      'Repair deposit due — tap to pay';
  static const String homeRepairDepositPaid =
      'Repair deposit paid — work starting soon';
  static const String homeRepairInProgress = 'Repairs in progress at garage';
  static const String homeRepairBalanceDue =
      'Repair balance due — tap to pay';
  static const String homeRepairComplete =
      'Repairs complete · delivery next';

  static const String repairNoRepairsTitle = 'No repairs — delivering as-is';
  static const String repairNoRepairsSub =
      'Tap to review or arrange agent-managed repairs';
  static const String partnerGarage = 'Partner garage';
}

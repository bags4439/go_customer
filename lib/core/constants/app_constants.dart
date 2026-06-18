/// Compile-time brand identity and URL defaults.
///
/// Remote overrides for [supportEmail], [faqUrl], [termsUrl], [websiteUrl], and
/// [appUrl] are merged at runtime via [appConfigProvider].
class AppBrandingDefaults {
  AppBrandingDefaults._();

  static const String displayName = 'Whiplyn';

  /// Marketing / landing site (FAQ, terms, public website).
  static const String webBaseUrl = 'https://whiplyn.com';

  /// Flutter web app (login, orders, payments).
  static const String appWebUrl = 'https://app.whiplyn.com';

  static const String supportEmail = 'support@whiplyn.com';

  static String urlPath(String baseUrl, String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalized/$path';
  }

  static String get faqUrl => urlPath(webBaseUrl, 'faq');
  static String get termsUrl => urlPath(webBaseUrl, 'terms');
  static String get privacyUrl => urlPath(webBaseUrl, 'privacy');
  static String get websiteUrl => webBaseUrl;

  /// Must match Android intent-filter and iOS CFBundleURLSchemes.
  static const String deepLinkScheme = 'whiplyn';

  static String get paystackCallbackUrl =>
      '$deepLinkScheme://payment/callback';

  static const String launcherIconAsset = 'assets/icon/app_icon.png';
}

/// `system_settings` document `key` values for remotely configurable branding.
class SystemSettingsKeys {
  SystemSettingsKeys._();

  static const String supportEmail = 'supportEmail';
  static const String faqUrl = 'faqUrl';
  static const String termsUrl = 'termsUrl';
  static const String websiteUrl = 'websiteUrl';
  static const String appUrl = 'appUrl';
}

class AppConstants {
  static const String appName = AppBrandingDefaults.displayName;

  /// Default support email; use [appConfigProvider] for the resolved value.
  static const String supportEmail = AppBrandingDefaults.supportEmail;
  /// Set this to your OneSignal App ID.
  ///
  /// Keeping it as a constant avoids scattering the value across the codebase.
  static const String oneSignalAppId = '9a05e7b1-ca1c-4de2-b521-a175c1d66e34';

  /// Sentry DSN for web error reporting (profile/release only).
  /// Client-safe — not a server secret.
  static const String sentryDsn =
      'https://0ed742aaf110229b2a43bc1b9e3db9ca@o4511555146743808.ingest.de.sentry.io/4511555160244304';

  /// Paystack PUBLIC key — safe to include in client code.
  /// NEVER put the secret key here. Secret key lives in Firebase Secret Manager only.
  static const String paystackPublicKey =
      'pk_test_863222f7f4a7f5217eabbf1b8dc56afcb254c1c0';

  /// Deep link scheme Paystack redirects to after checkout.
  /// Must match native manifests — not overridable remotely.
  static const String paystackCallbackScheme =
      AppBrandingDefaults.deepLinkScheme;

  // Google Places keys: [GooglePlacesApiKey] (platform-specific).

  // payment_requests.type — used for conditional UI (deposit note, repair note)
  static const String paymentRequestTypeVehicleBalanceAndShipping =
      'vehicle_balance_and_shipping';
  static const String paymentRequestTypeRepairFee = 'repair_fee';

  static const String purchaseOriginAny = 'any';
  static const String purchaseOriginUsCanada = 'us_canada';
  static const String purchaseOriginDubai = 'dubai';
  static const String purchaseOriginChina = 'china';

  /// orders.status — buyer confirmed receipt; before final delivered/review.
  static const String statusDeliveryConfirmed = 'delivery_confirmed';

  /// orders.status — order complete after buyer review.
  static const String statusDelivered = 'delivered';

  static const Map<String, String> purchaseOriginLabels = {
    'any': 'No preference',
    'us_canada': 'US / Canada',
    'dubai': 'Dubai / Middle East',
    'china': 'China',
  };

  static const Map<String, String> purchaseOriginSubtitles = {
    'any': 'Your agent finds the best source',
    'us_canada': 'Used, salvage or clean title',
    'dubai': 'Typically used, low mileage',
    'china': 'New or used directly from China',
  };
}

class FirestoreCollections {
  static const String users = 'users';
  static const String agents = 'agents';
  static const String orders = 'orders';
  static const String carPreferences = 'car_preferences';
  static const String preferenceEditHistory = 'preference_edit_history';
  static const String notifications = 'notifications';
  static const String otpSessions = 'otp_sessions';
  static const String userSessions = 'user_sessions';
  static const String vehicleOptions = 'vehicle_options';
  static const String bidOutcomes = 'bid_outcomes';
  static const String shipping = 'shipping';
  static const String dutyClearance = 'duty_clearance';
  static const String repairJobs = 'repair_jobs';
  static const String stageUpdates = 'stage_updates';
  static const String inactivityReminders = 'inactivity_reminders';
  static const String agentNewOrderRequests = 'agent_new_order_requests';
  static const String messages = 'messages';
  static const String messageReactions = 'message_reactions';
  static const String maxBids = 'max_bids';
  static const String payments = 'payments';
  static const String paymentRequests = 'payment_requests';
  static const String documents = 'documents';
  static const String orderTimeline = 'order_timeline';
  static const String delivery = 'delivery';
  static const String buyerReviews = 'buyer_reviews';
  static const String garages = 'garages';
  static const String exchangeRates = 'exchange_rates';
  static const String costDefaults = 'cost_defaults';
  static const String systemSettings = 'system_settings';
  static const String referralCodes = 'referral_codes';
  static const String countries = 'countries';
  static const String currencies = 'currencies';
  static const String carMakes = 'car_makes';

  /// Subcollection under each `car_makes/{makeSlug}` document.
  static const String carMakeModels = 'models';
}

class FirestoreEnumValues {
  // users.role
  static const String roleBuyer = 'buyer';
  static const String roleAgent = 'agent';
  static const String roleAdmin = 'admin';

  // agents.status
  static const String agentStatusActive = 'active';
  static const String agentStatusInactive = 'inactive';
  static const String agentStatusSuspended = 'suspended';

  // orders.status
  static const String orderStatusOpen = 'open';
  static const String orderStatusAgentAssigned = 'agentAssigned';
  static const String orderStatusSearching = 'searching';
  static const String orderStatusBidPlaced = 'bidPlaced';
  static const String orderStatusBidWon = 'bidWon';
  static const String orderStatusBidLost = 'bidLost';
  static const String orderStatusPaymentPending = 'paymentPending';
  static const String orderStatusPaymentReceived = 'paymentReceived';
  static const String orderStatusShipping = 'shipping';
  static const String orderStatusArrived = 'arrived';
  static const String orderStatusDutyPending = 'dutyPending';
  static const String orderStatusDutyPaid = 'dutyPaid';
  static const String orderStatusClearanceInProgress = 'clearanceInProgress';
  static const String orderStatusClearanceComplete = 'clearanceComplete';
  static const String orderStatusRepairPending = 'repairPending';
  static const String orderStatusRepairInProgress = 'repairInProgress';
  static const String orderStatusRepairComplete = 'repairComplete';
  static const String orderStatusDeliveryInProgress = 'delivery_in_progress';
  static const String orderStatusDeliveryConfirmed = 'delivery_confirmed';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  static const String orderStatusDormant = 'dormant';

  static const List<String> orderStatusValues = [
    orderStatusOpen,
    orderStatusAgentAssigned,
    orderStatusSearching,
    orderStatusBidPlaced,
    orderStatusBidWon,
    orderStatusBidLost,
    orderStatusPaymentPending,
    orderStatusPaymentReceived,
    orderStatusShipping,
    orderStatusArrived,
    orderStatusDutyPending,
    orderStatusDutyPaid,
    orderStatusClearanceInProgress,
    orderStatusClearanceComplete,
    orderStatusRepairPending,
    orderStatusRepairInProgress,
    orderStatusRepairComplete,
    orderStatusDeliveryConfirmed,
    orderStatusDelivered,
    orderStatusCancelled,
    orderStatusDormant,
  ];

  // car_preferences.condition
  static const String vehicleConditionRunAndDrive = 'run_and_drive';
  static const String vehicleConditionRepairable = 'repairable';
  static const String vehicleConditionFullRebuild = 'full_rebuild';
  static const String vehicleConditionNewVehicle = 'new_vehicle';
  static const String vehicleConditionGoodCondition = 'good_condition';
  static const String vehicleConditionFairCondition = 'fair_condition';

  static const List<String> vehicleConditionValues = [
    vehicleConditionRunAndDrive,
    vehicleConditionRepairable,
    vehicleConditionFullRebuild,
    vehicleConditionNewVehicle,
    vehicleConditionGoodCondition,
    vehicleConditionFairCondition,
  ];

  // vehicle_options.source (agent-specified)
  static const String vehicleSourceCopart = 'copart';
  static const String vehicleSourceIaa = 'iaa';
  static const String vehicleSourceDealer = 'dealer';
  static const String vehicleSourceOther = 'other';
  static const List<String> vehicleSourceValues = [
    vehicleSourceCopart,
    vehicleSourceIaa,
    vehicleSourceDealer,
    vehicleSourceOther,
  ];

  // vehicle_options.status
  static const String vehicleOptionStatusDraft = 'draft';
  static const String vehicleOptionStatusSent = 'sent';
  static const String vehicleOptionStatusWithdrawn = 'withdrawn';
  static const List<String> vehicleOptionStatusValues = [
    vehicleOptionStatusDraft,
    vehicleOptionStatusSent,
    vehicleOptionStatusWithdrawn,
  ];

  // vehicle_options.buyerResponse
  static const String buyerVehicleResponsePending = 'pending';
  static const String buyerVehicleResponseInterested = 'interested';
  static const String buyerVehicleResponseDeclined = 'declined';
  static const List<String> buyerVehicleResponseValues = [
    buyerVehicleResponsePending,
    buyerVehicleResponseInterested,
    buyerVehicleResponseDeclined,
  ];

  // bid_outcomes.outcome
  static const String bidOutcomeWon = 'won';
  static const String bidOutcomeLost = 'lost';

  // shipping.status
  static const String shippingStatusPending = 'pending';
  static const String shippingStatusBooked = 'booked';
  static const String shippingStatusDeparted = 'departed';
  static const String shippingStatusInTransit = 'in_transit';
  static const String shippingStatusArrived = 'arrived';
  static const String shippingStatusReleased = 'released';

  // duty_clearance.handledBy
  static const String clearanceHandledByAgent = 'agent';
  static const String clearanceHandledByBuyer = 'buyer';

  // duty_clearance.graStatus
  static const String graStatusNotStarted = 'not_started';
  static const String graStatusSubmitted = 'submitted';
  static const String graStatusAssessed = 'assessed';
  static const String graStatusPaid = 'paid';
  static const String graStatusCleared = 'cleared';

  // repair_jobs.status
  static const String repairStatusNotStarted = 'not_started';
  static const String repairStatusQuoteSent = 'quote_sent';
  static const String repairStatusQuoteApproved = 'quote_approved';
  static const String repairStatusQuoteDeclined = 'quote_declined';
  static const String repairStatusInProgress = 'in_progress';
  static const String repairStatusCompleted = 'completed';

  // stage_updates.updatedByRole
  static const String updatedByRoleBuyer = 'buyer';
  static const String updatedByRoleAgent = 'agent';
  static const String updatedByRoleAdmin = 'admin';

  // inactivity_reminders.reminderLevel
  static const String reminderLevel1 = '1';
  static const String reminderLevel2 = '2';
  static const String reminderLevel3 = '3';
  static const String reminderLevel4 = '4';

  // inactivity_reminders.actionTaken
  static const String inactivityActionNone = 'none';
  static const String inactivityActionMessageSent = 'message_sent';
  static const String inactivityActionEscalated = 'escalated';
  static const String inactivityActionOrderDormant = 'order_dormant';

  // agent_new_order_requests.status
  static const String agentRequestStatusPending = 'pending';
  static const String agentRequestStatusAccepted = 'accepted';
  static const String agentRequestStatusDeclined = 'declined';

  // messages.senderRole
  static const String messageSenderRoleAgent = 'agent';
  static const String messageSenderRoleBuyer = 'buyer';

  // messages.messageType & notifications.type
  static const String messageTypeText = 'text';
  static const String messageTypeVoiceNote = 'voice_note';
  static const String messageTypeImage = 'image';
  static const String messageTypeFile = 'file';
  static const String messageTypeVehicleCard = 'vehicle_card';
  static const String messageTypePaymentRequest = 'payment_request';
  static const String messageTypePaymentConfirmed = 'payment_confirmed';
  static const String messageTypeBidWon = 'bid_won';
  static const String messageTypeBidLost = 'bid_lost';
  static const String messageTypeShippingUpdate = 'shipping_update';
  static const String messageTypeStageUpdate = 'stage_update';
  static const String messageTypeSystem = 'system';

  static const List<String> notificationTypeValues = [
    'payment_request',
    'payment_confirmed',
    'bid_won',
    'bid_lost',
    'stage_update',
    'message',
    'agent_assigned',
    'order_edited',
    'order_cancelled',
    'inactivity_reminder',
    'auction_deadline',
    'shipping_update',
    'arrival',
    'id_reminder',
    'system',
  ];

  // payments.type
  static const String paymentTypeDeposit = 'deposit';
  static const String paymentTypeServiceFee = 'service_fee';
  static const String paymentTypeInitialCombined = 'initial_combined';
  static const String paymentTypeVehicleBalanceAndShipping =
      'vehicle_balance_and_shipping';
  static const String paymentTypeClearanceFee = 'clearance_fee';
  static const String paymentTypeRepairFee = 'repair_fee';
  static const String paymentTypeDeliveryFee = 'delivery_fee';
  static const String paymentTypeTowingFee = 'towing_fee';

  // payments.method
  static const String paymentMethodMtnMomo = 'mtn_momo';
  static const String paymentMethodVodafoneCash = 'vodafone_cash';
  static const String paymentMethodAirteltigoMoney = 'airteltigo_money';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodBankTransfer = 'bank_transfer';

  // payments.status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusProcessing = 'processing';
  static const String paymentStatusConfirmed = 'confirmed';
  static const String paymentStatusFailed = 'failed';
  static const String paymentStatusRefunded = 'refunded';

  // payment_requests.type
  static const String paymentRequestTypeInitial = 'initial';
  static const String paymentRequestTypeVehicleBalanceAndShipping =
      'vehicle_balance_and_shipping';
  static const String paymentRequestTypeClearanceFee = 'clearance_fee';
  static const String paymentRequestTypeRepairFee = 'repair_fee';
  static const String paymentRequestTypeVehicleBalance = 'vehicle_balance';
  static const String paymentRequestTypeShippingFee = 'shipping_fee';
  static const String paymentRequestTypeRepairBalance = 'repair_balance';
  static const String paymentRequestTypeDeliveryFee = 'delivery_fee';
  static const String paymentRequestTypeTowingFee = 'towing_fee';

  /// Human-readable labels for payment_requests.type — never hardcode in UI.
  static const Map<String, String> paymentRequestTypeLabels = {
    paymentRequestTypeInitial: 'Deposit & service fee',
    'vehicle_balance': 'Vehicle balance',
    paymentRequestTypeVehicleBalanceAndShipping:
        'Vehicle balance + shipping (legacy)',
    'shipping_fee': 'Shipping fee',
    paymentRequestTypeClearanceFee: 'Port clearance fee',
    paymentRequestTypeRepairFee: 'Repair deposit',
    paymentRequestTypeRepairBalance: 'Repair balance',
    paymentRequestTypeDeliveryFee: 'Delivery fee',
    'towing_fee': 'Towing fee',
  };

  // payment_requests.status
  static const String paymentRequestStatusPending = 'pending';
  static const String paymentRequestStatusPaid = 'paid';
  static const String paymentRequestStatusExpired = 'expired';
  static const String paymentRequestStatusCancelled = 'cancelled';

  // documents.docType
  static const List<String> documentTypeValues = [
    'ghana_id',
    'vehicle_title',
    'bill_of_lading',
    'commercial_invoice',
    'packing_list',
    'payment_receipt',
    'gra_declaration',
    'duty_receipt',
    'insurance_certificate',
    'repair_quote',
    'repair_receipt',
    'delivery_note',
    'other',
  ];

  // documents.status
  static const String documentStatusNotStarted = 'not_started';
  static const String documentStatusPending = 'pending';
  static const String documentStatusVerified = 'verified';
  static const String documentStatusRejected = 'rejected';

  // order_timeline.actionType
  static const List<String> timelineActionTypeValues = [
    'payment',
    'chat',
    'tracking',
    'clearance',
    'repair',
    'none',
  ];
}

// ---------------------------------------------------------------------------
// SUMMARY: Constants added to AppConstants (required by payment/order screens)
// ---------------------------------------------------------------------------
// Added to AppConstants class:
//
//   paymentRequestTypeVehicleBalanceAndShipping = 'vehicle_balance_and_shipping'
//     → payment_confirmed_screen.dart (conditional deposit note)
//     → payment_request_view_screen.dart (conditional deposit clarity note)
//
//   paymentRequestTypeRepairFee = 'repair_fee'
//     → payment_confirmed_screen.dart (conditional repair note)
//     → payment_request_view_screen.dart (conditional garage note)
//
//   paymentRequestTypeLabels = { initial, vehicle_balance_and_shipping,
//     clearance_fee, repair_fee, delivery_fee } (map of type → label)
//     → order_detail_screen.dart (payment card type label)
//
// payment_processing_screen.dart and payment_firestore_data_source.dart
// do not reference AppConstants; no constants were added for them.

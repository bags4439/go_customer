/// All copy for documents vault. No hardcoded strings in UI.
class DocumentConstants {
  DocumentConstants._();

  static const String sectionYourDocuments = 'YOUR DOCUMENTS';
  static const String sectionVehicleAndPurchase = 'VEHICLE & PURCHASE';
  static const String sectionCustomsAndClearance = 'CUSTOMS & CLEARANCE';
  static const String sectionRepairs = 'REPAIRS';
  static const String sectionDelivery = 'DELIVERY';

  static const String progressTitle = 'Documents ready';
  static const String progressOf = 'of 7';
  static const String progressSubNote = 'documents will be added automatically as your order progresses.';
  static const String progressAllReady = 'All documents are ready.';

  static const String statusVerified = 'Verified';
  static const String statusPending = 'Pending review';
  static const String statusRejected = 'Rejected';

  static const String uploadedByYou = 'Uploaded by you';
  static const String uploadedByAgent = 'Uploaded by agent';
  static const String addedAutomatically = 'Added automatically';
  static const String uploadRequired = 'Upload required';
  static const String uploadNow = 'Upload now';
  static const String reUpload = 'Re-upload';
  static const String availableAfter = 'Available after';

  static const String afterBidWon = 'After bid is won';
  static const String afterPaymentMade = 'After payment is made';
  static const String afterShippingBooked = 'After shipping is booked';
  static const String afterArrivalTema = 'After arrival at Tema port';
  static const String afterDutyPaid = 'After duty is paid';
  static const String afterRepairArranged = 'After repair is arranged';
  static const String afterRepairsComplete = 'After repairs are complete';
  static const String beforeDelivery = 'Before delivery';
  static const String onDelivery = 'On delivery';

  static const String documentType = 'Document type';
  static const String order = 'Order';
  static const String vehicleVin = 'Vehicle VIN';
  static const String uploadedBy = 'Uploaded by';
  static const String uploadDate = 'Upload date';
  static const String verifiedBy = 'Verified by';
  static const String verifiedDate = 'Verified date';
  static const String fileType = 'File type';
  static const String fileSize = 'File size';
  static const String you = 'You';
  static const String agent = 'Agent';
  static const String system = 'System';
  static const String platformAutoCheck = 'Platform (auto-check)';
  static const String notApplicable = '—';

  static const String download = 'Download';
  static const String share = 'Share';
  static const String fileSavedToDownloads = 'File saved to Downloads';
  static const String downloadFailed = 'Download failed. Try again.';
  static const String shareFailed = 'Could not prepare file for sharing.';
  static const String retry = 'Retry';

  static const String rejectionReason = 'Rejection reason';
  static const String documentRejected = 'Document rejected';
  static const String whatToDoNext = 'What to do next';
  static const String contactAgentHelp = 'Contact your agent — they can help you re-upload the correct document.';
  static const String askAgent = 'Ask';
  static const String viewDocumentDetails = 'View document details';
  static const String contactAgentForHelp = 'Contact your agent for help →';

  static const String previewNotAvailable = 'Preview not available';
  static const String noDocumentsYet = 'No documents yet';
  static const String noDocumentsBody = 'Documents will appear here as your order progresses.';

  static const String errorLoadDocuments = 'Could not load documents. Tap to retry.';

  static const Map<String, String> docTypeLabels = {
    'ghana_id': 'Ghana ID',
    'vehicle_title': 'Vehicle title',
    'bill_of_lading': 'Bill of lading',
    'commercial_invoice': 'Commercial invoice',
    'packing_list': 'Packing list',
    'payment_receipt': 'Payment receipt',
    'gra_declaration': 'GRA declaration',
    'duty_receipt': 'Duty receipt',
    'insurance_certificate': 'Insurance certificate',
    'repair_quote': 'Repair quote',
    'repair_receipt': 'Repair receipt',
    'delivery_note': 'Delivery note',
    'other': 'Other document',
  };

  static const Map<String, String> placeholderStageLabels = {
    'vehicle_title': afterBidWon,
    'payment_receipt': afterPaymentMade,
    'bill_of_lading': afterShippingBooked,
    'commercial_invoice': afterShippingBooked,
    'packing_list': afterShippingBooked,
    'gra_declaration': afterArrivalTema,
    'duty_receipt': afterDutyPaid,
    'repair_quote': afterRepairArranged,
    'repair_receipt': afterRepairsComplete,
    'insurance_certificate': beforeDelivery,
    'delivery_note': onDelivery,
  };
}

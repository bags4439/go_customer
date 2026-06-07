import 'package:flutter/material.dart';

import '../../../../core/layout/app_breakpoints.dart';
import '../constants/guide_keys.dart';

/// Brief hint + learn-more sheet copy for a guide touchpoint.
class GuideContextEntry {
  const GuideContextEntry({
    required this.sheetTitle,
    required this.detailParagraphs,
    this.sheetSubtitle,
    this.briefTitle,
    this.briefMessage,
    this.briefMessageWeb,
    this.briefMessageMobile,
  }) : assert(
         briefMessage != null ||
             (briefMessageWeb != null && briefMessageMobile != null),
         'Provide briefMessage or platform-specific brief messages.',
       );

  final String? briefTitle;
  final String? briefMessage;
  final String? briefMessageWeb;
  final String? briefMessageMobile;
  final String sheetTitle;
  final String? sheetSubtitle;
  final List<String> detailParagraphs;

  String briefFor(BuildContext context) {
    if (briefMessage != null) return briefMessage!;
    if (AppBreakpoints.isWeb(context)) {
      return briefMessageWeb!;
    }
    return briefMessageMobile!;
  }
}

/// All contextual hint copy. Never hardcode in widgets.
class GuideContextRegistry {
  GuideContextRegistry._();

  static GuideContextEntry? entryFor(String guideKey) => _entries[guideKey];

  static const Map<String, GuideContextEntry> _entries = {
    GuideKeys.homeEmpty: GuideContextEntry(
      briefTitle: 'Get started',
      briefMessage:
          'Tap Import your first car to tell us what you want. '
          'No payment until your agent sends a request.',
      sheetTitle: 'Importing your first car',
      sheetSubtitle: 'How your first order works',
      detailParagraphs: [
        'Tell us the make, model, year and condition you want. '
            'Your preferences go to a dedicated import agent.',
        'Your agent searches US auctions, sends you options, and handles '
            'bidding, shipping, duty, clearance and delivery.',
        'You only pay when your agent sends a payment request. '
            'You approve every charge before money leaves your account.',
        'You can edit your preferences or cancel for free before '
            'your first payment.',
      ],
    ),
    GuideKeys.homeOrders: GuideContextEntry(
      briefTitle: 'Your orders',
      briefMessage:
          'Each card shows your progress. Tap one to pay, chat, '
          'or see the full journey.',
      sheetTitle: 'Managing your orders',
      sheetSubtitle: 'What each order card means',
      detailParagraphs: [
        'Active orders show the current stage, from search to delivery.',
        'A payment badge means your agent sent a request that needs your '
            'approval. Tap the card, then Pay.',
        'Use Chat inside an order to message your agent directly. '
            'They handle the work while you stay informed.',
        'Completed orders stay here with your documents and delivery history.',
      ],
    ),
    GuideKeys.orderTimeline: GuideContextEntry(
      briefTitle: 'Your journey',
      briefMessageWeb:
          'Stages are on the left. Tap Pay or any step and '
          'details open on the right.',
      briefMessageMobile:
          'Follow every stage here. Use Chat and Documents tabs '
          'for messages and papers.',
      sheetTitle: 'Your import journey',
      sheetSubtitle: 'Following each stage of your order',
      detailParagraphs: [
        'The timeline tracks every step from preferences to delivery: '
            'search, bidding, payment, shipping, clearance, repairs '
            '(if needed) and delivery.',
        'On web, the journey stays on the left while actions and '
            'payments open in the panel on the right.',
        'On mobile, open Chat to reach your agent and Documents for '
            'receipts, title papers and clearance files.',
        'Tap any active stage for more detail. Your agent updates '
            'each step as your car moves forward.',
      ],
    ),
    GuideKeys.orderPaymentRequest: GuideContextEntry(
      briefTitle: 'Agent payment request',
      briefMessageWeb:
          'Check the amount, then tap Pay. Checkout opens on the right.',
      briefMessageMobile: 'Check the amount, then tap Pay to review and approve.',
      sheetTitle: 'Paying your agent\'s request',
      sheetSubtitle: 'Review before you approve',
      detailParagraphs: [
        'Your agent creates every payment request manually. '
            'You never pay without seeing exactly what it is for.',
        'Review the description and amount. Your deposit is deducted '
            'from balance payments, not charged again.',
        'Nothing leaves your MoMo, card or bank until you confirm '
            'on the checkout screen.',
        'If anything looks wrong, open Chat and ask your agent before paying.',
      ],
    ),
    GuideKeys.stageDelivery: GuideContextEntry(
      briefTitle: 'Delivery address',
      briefMessage:
          'Enter where the car should be delivered in Ghana.',
      sheetTitle: 'Setting your delivery address',
      sheetSubtitle: 'Where your car will be dropped off',
      detailParagraphs: [
        'Add the address or area where you want the vehicle delivered '
            'once import and clearance are complete.',
        'You can search for a place, use GPS for your current location, '
            'or type the address manually.',
        'Your agent uses this to schedule final delivery to you.',
        'You can update the address before delivery is confirmed.',
      ],
    ),
    GuideKeys.stageRepair: GuideContextEntry(
      briefTitle: 'Repair quote',
      briefMessage:
          'Review the quote here. No work starts until you approve.',
      sheetTitle: 'Repair quotes',
      sheetSubtitle: 'Approving garage work on your car',
      detailParagraphs: [
        'If you opted in for repairs, your agent sends a quote from a '
            'vetted garage after clearance.',
        'Read the work description and cost carefully before approving.',
        'Declining a quote means no repair work is done on your vehicle.',
        'Approved work is tracked here with before and after updates.',
      ],
    ),
    GuideKeys.notifications: GuideContextEntry(
      briefTitle: 'Stay updated',
      briefMessage:
          'Order updates appear here. Tap one to open that part of your order.',
      sheetTitle: 'Notifications',
      sheetSubtitle: 'Alerts about your orders',
      detailParagraphs: [
        'You receive alerts when your agent sends messages, payment requests, '
            'vehicle options, shipping updates and stage changes.',
        'Tap a notification to jump straight to the relevant order or action.',
        'Unread items are highlighted. Mark all read when you are caught up.',
      ],
    ),
    GuideKeys.agentProfile: GuideContextEntry(
      briefTitle: 'Your agent',
      briefMessage:
          'This agent handles your import: search, shipping, clearance '
          'and delivery.',
      sheetTitle: 'Your dedicated agent',
      sheetSubtitle: 'Who is looking after your order',
      detailParagraphs: [
        'A specialist agent is assigned to your order after you submit preferences.',
        'They search auctions, place bids, arrange shipping, handle GRA paperwork '
            'and coordinate delivery on your behalf.',
        'Use Chat or call them whenever you need an update or have a question.',
        'You approve vehicle choices, payments and repair quotes. '
            'Your agent does the legwork.',
      ],
    ),
  };
}

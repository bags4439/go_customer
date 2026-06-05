import 'buyer_vehicle_response.dart';
import 'listing_source.dart';
import 'vehicle_option_status.dart';

/// Domain representation of an agent-shared vehicle option.
class VehicleOption {
  const VehicleOption({
    required this.id,
    required this.orderId,
    required this.agentId,
    required this.listingUrl,
    required this.listingTitle,
    this.source,
    this.agentNote,
    required this.status,
    required this.buyerResponse,
    this.sentAt,
    this.buyerRespondedAt,
    this.createdAt,
  });

  final String id;
  final String orderId;
  final String agentId;
  final String listingUrl;
  final String listingTitle;
  final ListingSource? source;
  final String? agentNote;
  final VehicleOptionStatus status;
  final BuyerVehicleResponse buyerResponse;
  final DateTime? sentAt;
  final DateTime? buyerRespondedAt;
  final DateTime? createdAt;

  bool get isVisibleToBuyer => status == VehicleOptionStatus.sent;

  bool get hasResponded => buyerResponse != BuyerVehicleResponse.pending;

  String get displayTitle {
    final title = listingTitle.trim();
    return title.isNotEmpty ? title : 'Vehicle option';
  }
}

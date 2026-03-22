/// One document per order in Firestore (document ID = orderId).
/// Read-only in customer app.
class Shipping {
  final String orderId;
  final String? vesselName;
  final String? shippingLine;
  final String? blNumber;
  final String? containerNumber;
  final String? originPort;
  final String? destinationPort;
  final String? trackingUrl;
  final DateTime? estimatedDeparture;
  final DateTime? actualDeparture;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;
  final double? journeyProgressPct;
  final String status;
  final String? agentNotes;
  final DateTime? updatedAt;

  const Shipping({
    required this.orderId,
    this.vesselName,
    this.shippingLine,
    this.blNumber,
    this.containerNumber,
    this.originPort,
    this.destinationPort,
    this.trackingUrl,
    this.estimatedDeparture,
    this.actualDeparture,
    this.estimatedArrival,
    this.actualArrival,
    this.journeyProgressPct,
    required this.status,
    this.agentNotes,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isBooked => status == 'booked';
  bool get isDeparted => status == 'departed';
  bool get isInTransit => status == 'in_transit';
  bool get isArrived => status == 'arrived';
  bool get isReleased => status == 'released';
}

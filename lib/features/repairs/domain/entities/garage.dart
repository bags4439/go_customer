/// Garage from garages collection (read for repair quote context).
class Garage {
  final String id;
  final String name;
  final String? location;
  final String? city;
  final bool isVetted;
  final double? rating;
  final int? totalJobs;

  const Garage({
    required this.id,
    required this.name,
    this.location,
    this.city,
    this.isVetted = false,
    this.rating,
    this.totalJobs,
  });
}

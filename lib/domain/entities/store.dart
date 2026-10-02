/// Silpo Supermarket entity with filialId, address, theme design and store amenities.
class SilpoStore {
  final String filialId;
  final String name;
  final String address;
  final String city;
  final String workingHours;
  final double latitude;
  final double longitude;
  final String? conceptTheme; // e.g. 'Вінтажний цирк', 'Мавка', 'Стимпанк', 'Музичний'
  final List<String> amenities; // 'Пекарня', 'Власна рибокоптильня', 'Піцерія', 'Кав’ярня Feeltrd'
  final bool hasGenerator;
  final bool isFavorite;
  final double distanceKm;

  final String? imageUrl;
  final bool hasBakery;
  final bool hasFeeltrd;
  final bool hasEvCharging;
  final bool hasPharmacy;
  final bool isOpen;
  final String? phone;

  const SilpoStore({
    required this.filialId,
    required this.name,
    required this.address,
    required this.city,
    required this.workingHours,
    required this.latitude,
    required this.longitude,
    this.conceptTheme,
    this.amenities = const [],
    this.hasGenerator = true,
    this.isFavorite = false,
    this.distanceKm = 1.2,
    this.imageUrl,
    this.hasBakery = true,
    this.hasFeeltrd = true,
    this.hasEvCharging = false,
    this.hasPharmacy = false,
    this.isOpen = true,
    this.phone,
  });

  SilpoStore copyWith({
    String? filialId,
    String? name,
    String? address,
    String? city,
    String? workingHours,
    double? latitude,
    double? longitude,
    String? conceptTheme,
    List<String>? amenities,
    bool? hasGenerator,
    bool? isFavorite,
    double? distanceKm,
    String? imageUrl,
    bool? hasBakery,
    bool? hasFeeltrd,
    bool? hasEvCharging,
    bool? hasPharmacy,
    bool? isOpen,
    String? phone,
  }) {
    return SilpoStore(
      filialId: filialId ?? this.filialId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      workingHours: workingHours ?? this.workingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      conceptTheme: conceptTheme ?? this.conceptTheme,
      amenities: amenities ?? this.amenities,
      hasGenerator: hasGenerator ?? this.hasGenerator,
      isFavorite: isFavorite ?? this.isFavorite,
      distanceKm: distanceKm ?? this.distanceKm,
      imageUrl: imageUrl ?? this.imageUrl,
      hasBakery: hasBakery ?? this.hasBakery,
      hasFeeltrd: hasFeeltrd ?? this.hasFeeltrd,
      hasEvCharging: hasEvCharging ?? this.hasEvCharging,
      hasPharmacy: hasPharmacy ?? this.hasPharmacy,
      isOpen: isOpen ?? this.isOpen,
      phone: phone ?? this.phone,
    );
  }
}

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
  final List<String> amenities; // 'Власна рибокоптильня', 'Піцерія', 'Суші-бар', 'Власна сироварня'
  final bool isFavorite;
  final double distanceKm;

  final String? imageUrl;
  final bool isOpen;
  final String? phone;

  const SilpoStore({
    required this.filialId,
    required this.name,
    required this.address,
    required this.city,
    this.workingHours = '08:00 - 23:00',
    required this.latitude,
    required this.longitude,
    this.conceptTheme,
    this.amenities = const [],
    this.isFavorite = false,
    this.distanceKm = 1.2,
    this.imageUrl,
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
    bool? isFavorite,
    double? distanceKm,
    String? imageUrl,
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
      isFavorite: isFavorite ?? this.isFavorite,
      distanceKm: distanceKm ?? this.distanceKm,
      imageUrl: imageUrl ?? this.imageUrl,
      isOpen: isOpen ?? this.isOpen,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
    'filialId': filialId,
    'name': name,
    'address': address,
    'city': city,
    'workingHours': workingHours,
    'latitude': latitude,
    'longitude': longitude,
    'conceptTheme': conceptTheme,
    'amenities': amenities,
    'isFavorite': isFavorite,
    'distanceKm': distanceKm,
    'imageUrl': imageUrl,
    'isOpen': isOpen,
    'phone': phone,
  };

  factory SilpoStore.fromJson(Map<String, dynamic> json) => SilpoStore(
    filialId: json['filialId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    address: json['address'] as String? ?? '',
    city: json['city'] as String? ?? '',
    workingHours: json['workingHours'] as String? ?? '08:00 - 23:00',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 50.45,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 30.52,
    conceptTheme: json['conceptTheme'] as String?,
    amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    isFavorite: json['isFavorite'] as bool? ?? false,
    distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.2,
    imageUrl: json['imageUrl'] as String?,
    isOpen: json['isOpen'] as bool? ?? true,
    phone: json['phone'] as String?,
  );
}

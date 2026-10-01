class Place {
  final String id;
  final String name;
  final String address;
  final List<String> categories;
  final double? latitude;
  final double? longitude;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required List<String> categories,
    required this.latitude,
    required this.longitude,
  }) : categories = List.unmodifiable(categories);

  bool get isHotel =>
      categories.any((category) => category.startsWith('accommodation'));

  Map<String, dynamic> toCacheJson() => {
    'place_id': id,
    'name': name,
    'formatted': address,
    'categories': categories,
    'lat': latitude,
    'lon': longitude,
  };

  factory Place.fromCacheJson(Map<String, dynamic> json) {
    return Place.fromGeoapifyJson(json);
  }

  factory Place.fromGeoapifyJson(Map<String, dynamic> json) {
    final name = json['name']?.toString().trim() ?? '';

    if (name.isEmpty) {
      throw const FormatException('Place is missing its name.');
    }

    final rawCategories = json['categories'];
    final categories = rawCategories is List
        ? rawCategories
        .whereType<String>()
        .map((category) => category.toLowerCase())
        .toList()
        : <String>[];

    double? toDouble(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    final latitude = toDouble(json['lat']);
    final longitude = toDouble(json['lon']);
    final id = json['place_id']?.toString() ??
        '${name.toLowerCase()}-${latitude ?? ''}-${longitude ?? ''}';

    return Place(
      id: id,
      name: name,
      address: json['formatted']?.toString() ??
          json['address_line1']?.toString() ??
          'Address unavailable',
      categories: categories,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
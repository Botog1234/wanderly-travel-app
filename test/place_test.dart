import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/models/place.dart';

void main() {
  group('Place', () {
    test('parses a Geoapify place', () {
      final place = Place.fromGeoapifyJson({
        'place_id': 'place-1',
        'name': 'Eiffel Tower',
        'formatted': 'Champ de Mars, Paris, France',
        'categories': ['Tourism.Sights', 'Tourism.Attraction'],
        'lat': 48.8584,
        'lon': 2.2945,
      });

      expect(place.id, 'place-1');
      expect(place.name, 'Eiffel Tower');
      expect(place.address, 'Champ de Mars, Paris, France');
      expect(place.categories, ['tourism.sights', 'tourism.attraction']);
      expect(place.latitude, 48.8584);
      expect(place.longitude, 2.2945);
      expect(place.isHotel, isFalse);
    });

    test('rejects a place without a name', () {
      expect(
            () => Place.fromGeoapifyJson({'categories': ['tourism.sights']}),
        throwsFormatException,
      );
    });

    test('converts to and from cached JSON', () {
      final original = Place.fromGeoapifyJson({
        'place_id': 'hotel-1',
        'name': 'Sample Hotel',
        'formatted': 'Paris, France',
        'categories': ['accommodation.hotel'],
        'lat': 48.85,
        'lon': 2.35,
      });

      final restored = Place.fromCacheJson(original.toCacheJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.address, original.address);
      expect(restored.categories, original.categories);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.isHotel, isTrue);
    });
  });
}
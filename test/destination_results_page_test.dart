import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/destination_results_page.dart';
import 'package:travel_app/models/place.dart';
import 'package:travel_app/models/places_snapshot.dart';
import 'package:travel_app/providers/destination_providers.dart';
import 'package:travel_app/world_Search.dart';

void main() {
  testWidgets('shows places and filters by category and search',
          (tester) async {
        const country = CountryInfo(
          name: 'France',
          code: 'FR',
          flag: '🇫🇷',
        );

        final places = [
          Place(
            id: 'eiffel',
            name: 'Eiffel Tower',
            address: 'Paris, France',
            categories: ['tourism.sights'],
            latitude: 48.8584,
            longitude: 2.2945,
          ),
          Place(
            id: 'hotel',
            name: 'Sample Hotel',
            address: 'Lyon, France',
            categories: ['accommodation.hotel'],
            latitude: 45.764,
            longitude: 4.8357,
          ),
        ];

        final snapshot = PlacesSnapshot(
          places: places,
          lastUpdated: DateTime(2026, 10, 1),
          isFromCache: false,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              destinationPlacesProvider(country.name).overrideWith(
                    (ref) async => snapshot,
              ),
            ],
            child: const MaterialApp(
              home: DestinationResultsPage(country: country),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Eiffel Tower'), findsOneWidget);
        expect(find.text('Sample Hotel'), findsOneWidget);

        await tester.tap(find.widgetWithText(ChoiceChip, 'Hotels'));
        await tester.pumpAndSettle();

        expect(find.text('Sample Hotel'), findsOneWidget);
        expect(find.text('Eiffel Tower'), findsNothing);

        await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'eiffel');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(find.text('Eiffel Tower'), findsOneWidget);
        expect(find.text('Sample Hotel'), findsNothing);
      });
}
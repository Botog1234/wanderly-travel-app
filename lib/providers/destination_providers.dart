import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/geoapify_data_source.dart';
import '../models/places_snapshot.dart';
import '../repositories/destination_repository.dart';

final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  final dataSource = GeoapifyDataSource();
  ref.onDispose(dataSource.close);
  return DestinationRepository(dataSource);
});

final destinationPlacesProvider =
FutureProvider.family<PlacesSnapshot, String>((ref, countryName) {
  final repository = ref.watch(destinationRepositoryProvider);
  return repository.getPlacesForCountry(countryName);
});
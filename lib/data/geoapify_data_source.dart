import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/place.dart';

class GeoapifyException implements Exception {
  final String message;

  const GeoapifyException(this.message);

  @override
  String toString() => message;
}

class GeoapifyDataSource {
  GeoapifyDataSource({
    http.Client? client,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _apiKey = apiKey ??
            const String.fromEnvironment('GEOAPIFY_API_KEY');

  final http.Client _client;
  final bool _ownsClient;
  final String _apiKey;

  Future<List<Place>> fetchPlacesForCountry(String countryName) async {
    if (_apiKey.trim().isEmpty) {
      throw const GeoapifyException(
        'Geoapify key is missing. Run the app with '
            '--dart-define=GEOAPIFY_API_KEY=YOUR_KEY.',
      );
    }

    final geocodeUri = Uri.https(
      'api.geoapify.com',
      '/v1/geocode/search',
      {
        'text': countryName,
        'type': 'country',
        'format': 'json',
        'limit': '1',
        'apiKey': _apiKey,
      },
    );

    final geocodeData = await _getJson(geocodeUri);
    final rawResults = geocodeData['results'];

    if (rawResults is! List || rawResults.isEmpty) {
      throw GeoapifyException('Could not find $countryName.');
    }

    final firstResult = _asJsonObject(rawResults.first);
    final placeId = firstResult?['place_id']?.toString();

    if (placeId == null || placeId.isEmpty) {
      throw const GeoapifyException(
        'Geoapify did not return a country boundary ID.',
      );
    }

    final placesUri = Uri.https(
      'api.geoapify.com',
      '/v2/places',
      {
        'categories': 'tourism.sights,accommodation',
        'filter': 'place:$placeId',
        'limit': '20',
        'apiKey': _apiKey,
      },
    );

    final placesData = await _getJson(placesUri);
    final rawFeatures = placesData['features'];

    if (rawFeatures is! List) {
      throw const FormatException(
        'Geoapify returned an invalid places response.',
      );
    }

    final places = <Place>[];
    var invalidFeatureCount = 0;

    for (final rawFeature in rawFeatures) {
      final feature = _asJsonObject(rawFeature);
      final properties = _asJsonObject(feature?['properties']);

      if (properties == null) {
        invalidFeatureCount++;
        continue;
      }

      try {
        places.add(Place.fromGeoapifyJson(properties));
      } on FormatException {
        invalidFeatureCount++;
      }
    }

    if (rawFeatures.isNotEmpty && places.isEmpty) {
      throw const FormatException(
        'Geoapify returned places in an unexpected format.',
      );
    }

    return places;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    late final http.Response response;

    try {
      response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const GeoapifyException(
        'The place search timed out. Please try again.',
      );
    } on SocketException {
      throw const GeoapifyException(
        'No internet connection. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const GeoapifyException(
        'Could not connect to Geoapify. Please try again.',
      );
    }

    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const GeoapifyException(
          'Geoapify rejected the API key. Check your local key setup.',
        );
      }

      if (response.statusCode == 429) {
        throw const GeoapifyException(
          'Geoapify’s request limit was reached. Try again later.',
        );
      }

      throw GeoapifyException(
        'Geoapify request failed (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Geoapify returned an invalid JSON response.',
      );
    }

    return decoded;
  }

  Map<String, dynamic>? _asJsonObject(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
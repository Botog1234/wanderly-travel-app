import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountryInfo {
  final String name;
  final String code;
  final String flag;

  const CountryInfo({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class CountrySearchPage extends StatefulWidget {
  const CountrySearchPage({super.key});

  @override
  State<CountrySearchPage> createState() => _CountrySearchPageState();
}

class _CountrySearchPageState extends State<CountrySearchPage> {
  // Replace this locally with your newly generated REST Countries API key.
  static const String _apiKey =
  String.fromEnvironment('REST_COUNTRIES_API_KEY');
  final TextEditingController _searchController = TextEditingController();

  List<CountryInfo> _countries = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final loadedCountries = <CountryInfo>[];
      var offset = 0;
      var hasMore = true;

      while (hasMore) {
        final uri = Uri.https(
          'api.restcountries.com',
          '/countries/v5',
          {
            'response_fields': 'names.common,codes.alpha_2,flag.emoji',
            'limit': '100',
            'offset': '$offset',
          },
        );

        final response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $_apiKey'},
        );

        if (response.statusCode != 200) {
          throw Exception(
            'Request failed (${response.statusCode}): ${response.body}',
          );
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected response format from REST Countries.');
        }

        final data = decoded['data'];
        if (data is! Map<String, dynamic>) {
          throw Exception('The response did not contain a data object.');
        }

        final objects = data['objects'];
        if (objects is! List) {
          throw Exception('The response did not contain a country list.');
        }

        for (final item in objects) {
          if (item is! Map<String, dynamic>) continue;

          final names = item['names'];
          final codes = item['codes'];
          final flagData = item['flag'];

          final name =
          names is Map ? names['common']?.toString() ?? '' : '';
          final code =
          codes is Map ? codes['alpha_2']?.toString() ?? '' : '';
          final flag =
          flagData is Map ? flagData['emoji']?.toString() ?? '🌍' : '🌍';

          if (name.isNotEmpty && code.isNotEmpty) {
            loadedCountries.add(
              CountryInfo(name: name, code: code, flag: flag),
            );
          }
        }

        final meta = data['meta'];
        hasMore = meta is Map && meta['more'] == true;
        offset += objects.length;

        if (objects.isEmpty) {
          hasMore = false;
        }
      }

      loadedCountries.sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;
      setState(() {
        _countries = loadedCountries;
        _loading = false;
        _error = loadedCountries.isEmpty ? 'No countries were returned.' : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  List<CountryInfo> get _filteredCountries {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _countries;

    return _countries
        .where((country) => country.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countries = _filteredCountries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a country'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search countries',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load countries.\n\n$_error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : countries.isEmpty
                ? const Center(child: Text('No countries found'))
                : ListView.separated(
              itemCount: countries.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (context, index) {
                final country = countries[index];

                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 25),
                  ),
                  title: Text(country.name),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                  onTap: () {
                    Navigator.pop(context, country);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
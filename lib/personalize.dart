import 'package:flutter/material.dart';

import 'home_page.dart';

class PersonalizePage extends StatefulWidget {
  const PersonalizePage({super.key});

  @override
  State<PersonalizePage> createState() => _PersonalizePageState();
}

class _PersonalizePageState extends State<PersonalizePage> {
  final Set<String> _selectedInterests = {};
  String _travelStyle = 'Relaxing';
  String _budget = 'Moderate';

  final List<String> _interests = const [
    'Beaches',
    'Nature',
    'Cities',
    'Food',
    'Adventure',
    'Culture',
    'Shopping',
    'Wildlife',
  ];

  void _finish() {
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one interest')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: const Text('Personalize your trips'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Let’s make travel yours ✨',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us what you enjoy. We’ll use your choices to suggest trips.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'What do you enjoy?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: _interests.map((interest) {
                final selected = _selectedInterests.contains(interest);

                return FilterChip(
                  label: Text(interest),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedInterests.add(interest);
                      } else {
                        _selectedInterests.remove(interest);
                      }
                    });
                  },
                  selectedColor: scheme.secondaryContainer,
                  backgroundColor: scheme.surface,
                  checkmarkColor: scheme.onSecondaryContainer,
                  labelStyle: TextStyle(
                    color: selected
                        ? scheme.onSecondaryContainer
                        : scheme.onSurface,
                  ),
                  side: BorderSide(color: scheme.outlineVariant),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              'What kind of trip do you prefer?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _travelStyle,
              decoration: _decoration(scheme),
              items: const ['Relaxing', 'Adventure', 'Cultural', 'Family']
                  .map(
                    (style) => DropdownMenuItem(
                  value: style,
                  child: Text(style),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _travelStyle = value);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'What’s your usual budget per trip?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _budget,
              decoration: _decoration(scheme),
              items: const ['Budget-friendly', 'Moderate', 'Premium']
                  .map(
                    (budget) => DropdownMenuItem(
                  value: budget,
                  child: Text(budget),
                ),
              )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _budget = value);
                }
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _finish,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Show my travel ideas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _skip,
              child: const Text('I’ll do this later'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(ColorScheme scheme) {
    return InputDecoration(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }
}
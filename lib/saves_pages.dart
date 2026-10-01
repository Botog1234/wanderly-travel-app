import 'package:flutter/material.dart';

import 'trip_store.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trips = TripStore.savedTrips;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Saved trips',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: scheme.surface,
      ),
      body: trips.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 54,
                color: scheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Nothing saved yet',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Confirmed stays and visits will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final trip = trips[index];
          final isHotel = trip.type == 'Hotel stay';

          final dateText = trip.endDate == null
              ? _formatDate(trip.startDate)
              : '${_formatDate(trip.startDate)} – '
              '${_formatDate(trip.endDate!)}';

          return Card(
            color: scheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.secondaryContainer,
                  child: Icon(
                    isHotel
                        ? Icons.hotel_outlined
                        : Icons.attractions_outlined,
                    color: scheme.primary,
                  ),
                ),
                title: Text(
                  trip.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${trip.type} · $dateText\n'
                        '${trip.address}\n'
                        '${isHotel ? 'Guests' : 'Visitors'}: ${trip.people}',
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
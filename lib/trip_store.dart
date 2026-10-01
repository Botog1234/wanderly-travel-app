class SavedTrip {
  final String id;
  final String type;
  final String name;
  final String address;
  final DateTime startDate;
  final DateTime? endDate;
  final int people;

  const SavedTrip({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    required this.startDate,
    this.endDate,
    required this.people,
  });
}

class TripStore {
  TripStore._();

  static final List<SavedTrip> savedTrips = [];
  static final Map<DateTime, List<String>> _plans = {};

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static List<String> plansFor(DateTime date) =>
      _plans[dateOnly(date)] ?? const [];

  static void addPlan(DateTime date, String description) {
    final key = dateOnly(date);
    _plans.putIfAbsent(key, () => []).add(description);
  }

  static void removePlan(DateTime date, int index) {
    final key = dateOnly(date);

    _plans[key]?.removeAt(index);

    if (_plans[key]?.isEmpty ?? false) {
      _plans.remove(key);
    }
  }

  static void saveHotel({
    required String name,
    required String address,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) {
    savedTrips.add(
      SavedTrip(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'Hotel stay',
        name: name,
        address: address,
        startDate: dateOnly(checkIn),
        endDate: dateOnly(checkOut),
        people: guests,
      ),
    );

    addPlan(checkIn, 'Check in: $name');
    addPlan(checkOut, 'Check out: $name');
  }

  static void saveAttraction({
    required String name,
    required String address,
    required DateTime visitDate,
    required int visitors,
  }) {
    savedTrips.add(
      SavedTrip(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: 'Attraction',
        name: name,
        address: address,
        startDate: dateOnly(visitDate),
        people: visitors,
      ),
    );

    addPlan(visitDate, 'Visit: $name');
  }
}
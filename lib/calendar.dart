import 'package:flutter/material.dart';

import 'trip_store.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<String> get _selectedPlans => TripStore.plansFor(_selectedDate);

  void _changeMonth(int amount) {
    final nextMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + amount,
    );
    final daysInMonth =
        DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final day = _selectedDate.day > daysInMonth
        ? daysInMonth
        : _selectedDate.day;

    setState(() {
      _visibleMonth = nextMonth;
      _selectedDate = DateTime(nextMonth.year, nextMonth.month, day);
    });
  }

  Future<void> _addPlan() async {
    final controller = TextEditingController();

    final plan = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add plan for ${_formatDate(_selectedDate)}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'For example: Visit the museum',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {
            final value = controller.text.trim();
            if (value.isNotEmpty) {
              Navigator.pop(dialogContext, value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Add plan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || plan == null || plan.isEmpty) return;

    setState(() {
      TripStore.addPlan(_selectedDate, plan);
    });
  }

  void _deletePlan(int index) {
    setState(() {
      TripStore.removePlan(_selectedDate, index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final monthName = _monthName(_visibleMonth.month);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Trip calendar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: scheme.surface,
        actions: [
          TextButton(
            onPressed: () {
              final today = _dateOnly(DateTime.now());
              setState(() {
                _selectedDate = today;
                _visibleMonth = DateTime(today.year, today.month);
              });
            },
            child: const Text('Today'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _buildCalendarCard(monthName),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _addPlan,
                icon: const Icon(Icons.add),
                label: const Text('Add plan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedPlans.isEmpty)
            Card(
              color: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'No plans for this day yet. Tap “Add plan” to add one.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...List.generate(_selectedPlans.length, (index) {
              return Card(
                color: scheme.surface,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(
                      Icons.luggage_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  title: Text(_selectedPlans[index]),
                  trailing: IconButton(
                    tooltip: 'Delete plan',
                    onPressed: () => _deletePlan(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: scheme.error,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(String monthName) {
    final scheme = Theme.of(context).colorScheme;
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leadingEmptyDays = firstDay.weekday - 1;
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '$monthName ${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          for (int row = 0; row < totalCells ~/ 7; row++)
            Row(
              children: List.generate(7, (column) {
                final cellIndex = row * 7 + column;
                final dayNumber = cellIndex - leadingEmptyDays + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 48));
                }

                final date = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  dayNumber,
                );
                final isSelected =
                    _dateOnly(date) == _dateOnly(_selectedDate);
                final isToday =
                    _dateOnly(date) == _dateOnly(DateTime.now());
                final hasPlans =
                    TripStore.plansFor(date).isNotEmpty;

                return Expanded(
                  child: Semantics(
                    label: '${_formatDate(date)}'
                        '${hasPlans ? ', has plans' : ''}'
                        '${isSelected ? ', selected' : ''}',
                    button: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _selectedDate = date),
                      child: SizedBox(
                        height: 48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? scheme.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isToday && !isSelected
                                    ? Border.all(color: scheme.primary)
                                    : null,
                              ),
                              child: Text(
                                '$dayNumber',
                                style: TextStyle(
                                  color: isSelected
                                      ? scheme.onPrimary
                                      : scheme.onSurface,
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: hasPlans
                                    ? scheme.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _formatDate(DateTime date) =>
      '${_monthName(date.month)} ${date.day}, ${date.year}';
}
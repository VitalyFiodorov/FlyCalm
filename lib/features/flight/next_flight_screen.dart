import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class NextFlightScreen extends ConsumerStatefulWidget {
  const NextFlightScreen({super.key});

  @override
  ConsumerState<NextFlightScreen> createState() => _NextFlightScreenState();
}

class _NextFlightScreenState extends ConsumerState<NextFlightScreen> {
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final flight = ref.read(nextFlightProvider);
    if (flight != null) {
      _date = flight.date;
      _origin.text = flight.origin;
      _destination.text = flight.destination;
      final parts = flight.departureTime?.split(':');
      if (parts?.length == 2) {
        _time =
            TimeOfDay(hour: int.parse(parts![0]), minute: int.parse(parts[1]));
      }
    }
  }

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final flight = NextFlight(
      date: _date,
      departureTime: _time == null
          ? null
          : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
      origin: _origin.text.trim(),
      destination: _destination.text.trim(),
    );
    await ref.read(nextFlightProvider.notifier).save(flight);
    await ref.read(analyticsProvider).log('next_flight_added', parameters: {
      'days_until_flight': flight.daysUntil(DateTime.now()),
      'has_time': _time != null,
      'has_route': flight.origin.isNotEmpty || flight.destination.isNotEmpty,
    });
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Next flight'),
            backgroundColor: Colors.transparent),
        extendBodyBehindAppBar: true,
        body: ScreenContainer(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 92, 24, 32),
            children: [
              Text('When is your next flight?',
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              const Text(
                  'Only the date is needed. Everything stays on this device.',
                  style: TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 28),
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Flight date'),
                  subtitle: Text(DateFormat.yMMMMd().format(_date),
                      style: const TextStyle(color: AppTheme.textMuted)),
                  trailing: const Icon(Icons.calendar_month,
                      color: AppTheme.softBlue),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (value != null) setState(() => _date = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Departure time (optional)'),
                  subtitle: Text(_time?.format(context) ?? 'Not set',
                      style: const TextStyle(color: AppTheme.textMuted)),
                  trailing:
                      const Icon(Icons.schedule, color: AppTheme.softBlue),
                  onTap: () async {
                    final value = await showTimePicker(
                        context: context,
                        initialTime: _time ?? TimeOfDay.now());
                    if (value != null) setState(() => _time = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _origin,
                  decoration:
                      const InputDecoration(labelText: 'Origin (optional)')),
              const SizedBox(height: 12),
              TextField(
                  controller: _destination,
                  decoration: const InputDecoration(
                      labelText: 'Destination (optional)')),
              const SizedBox(height: 32),
              PrimaryButton(onPressed: _save, text: 'Save next flight'),
            ],
          ),
        ),
      );
}

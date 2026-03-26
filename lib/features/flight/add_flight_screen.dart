import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/providers.dart';
import '../../data/models/models.dart';
import 'dart:math';

class AddFlightScreen extends ConsumerStatefulWidget {
  const AddFlightScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends ConsumerState<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  DateTime _departureTime = DateTime.now().add(const Duration(minutes: 30));
  int _durationHours = 2;
  int _durationMinutes = 0;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final totalMinutes = (_durationHours * 60) + _durationMinutes;
      if (totalMinutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duration must be greater than zero')));
        return;
      }

      final session = FlightSession(
        id: Random().nextInt(1000000).toString(),
        fromCity: _fromController.text.trim(),
        toCity: _toController.text.trim(),
        departureTime: _departureTime,
        durationMinutes: totalMinutes,
        createdAt: DateTime.now(),
      );

      ref.read(flightSessionProvider.notifier).setFlight(session);
      context.go('/flight_mode');
    }
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departureTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.softBlue,
              surface: AppTheme.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      setState(() {
        _departureTime = DateTime(
          _departureTime.year,
          _departureTime.month,
          _departureTime.day,
          selected.hour,
          selected.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Add Flight"),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("Where are you flying?", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fromController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "From",
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "To",
                    labelStyle: const TextStyle(color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.cardBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                Text("When do you depart?", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectTime,
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Departure Time", style: Theme.of(context).textTheme.bodyLarge),
                        Text(DateFormat.Hm().format(_departureTime), style: TextStyle(color: AppTheme.softBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text("Flight duration", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _durationHours.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Hours",
                          labelStyle: const TextStyle(color: AppTheme.textMuted),
                          filled: true,
                          fillColor: AppTheme.cardBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => _durationHours = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _durationMinutes.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          labelStyle: const TextStyle(color: AppTheme.textMuted),
                          filled: true,
                          fillColor: AppTheme.cardBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => _durationMinutes = int.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                PrimaryButton(
                  onPressed: _submit,
                  text: "Start Flight",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParkingTimeSelector extends StatefulWidget {
  final DateTime entryTime;
  final DateTime exitTime;
  final Function(DateTime) onEntryTimeChanged;
  final Function(DateTime) onExitTimeChanged;

  const ParkingTimeSelector({
    super.key,
    required this.entryTime,
    required this.exitTime,
    required this.onEntryTimeChanged,
    required this.onExitTimeChanged,
  });

  @override
  State<ParkingTimeSelector> createState() => _ParkingTimeSelectorState();
}

class _ParkingTimeSelectorState extends State<ParkingTimeSelector> {
  Future<void> _selectDateTime(DateTime initialDate, bool isEntry) async {
    if (!mounted) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isEntry
          ? DateTime.now().subtract(const Duration(days: 7))
          : widget.entryTime,
      lastDate: isEntry ? DateTime.now() : DateTime.now(),
    );

    if (!mounted) return;

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (!mounted) return;

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (isEntry) {
          widget.onEntryTimeChanged(selectedDateTime);
        } else {
          widget.onExitTimeChanged(selectedDateTime);
        }
      }
    }
  }

  Duration get parkingDuration => widget.exitTime.difference(widget.entryTime);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: theme.colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'Parking Duration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Entry Time Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.login,
                color: theme.colorScheme.onSurface.withOpacity(1),
              ),
              title: const Text('Entry Time'),
              subtitle: Text(dateFormat.format(widget.entryTime)),
              trailing: OutlinedButton(
                onPressed: () => _selectDateTime(widget.entryTime, true),
                child: const Text('Select'),
              ),
            ),
            // Exit Time Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.onSurface.withOpacity(1),
              ),
              title: const Text('Exit Time'),
              subtitle: Text(dateFormat.format(widget.exitTime)),
              trailing: OutlinedButton(
                onPressed: () => _selectDateTime(widget.exitTime, false),
                child: const Text('Select'),
              ),
            ),
            const Divider(height: 24),
            // Duration Display
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.timer,
                color: theme.colorScheme.onSurface.withOpacity(1),
              ),
              title: const Text('Total Duration'),
              subtitle: Text(
                '${parkingDuration.inHours}h ${parkingDuration.inMinutes.remainder(60)}m',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

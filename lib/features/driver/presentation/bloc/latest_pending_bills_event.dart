// lib/features/driver/presentation/bloc/latest_pending_bills_event.dart
import 'package:equatable/equatable.dart';

abstract class LatestPendingBillsEvent extends Equatable {
  const LatestPendingBillsEvent();

  @override
  List<Object?> get props => [];
}

class LoadLatestPendingBills extends LatestPendingBillsEvent {
  final String userId;

  const LoadLatestPendingBills(this.userId);

  @override
  List<Object> get props => [userId];
}

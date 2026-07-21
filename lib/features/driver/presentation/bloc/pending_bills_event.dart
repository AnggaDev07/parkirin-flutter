// lib/features/driver/presentation/bloc/pending_bills_event.dart
import 'package:equatable/equatable.dart';

abstract class PendingBillsEvent extends Equatable {
  const PendingBillsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingBills extends PendingBillsEvent {
  final String userId;

  const LoadPendingBills(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshPendingBills extends PendingBillsEvent {
  final String userId;

  const RefreshPendingBills(this.userId);

  @override
  List<Object> get props => [userId];
}

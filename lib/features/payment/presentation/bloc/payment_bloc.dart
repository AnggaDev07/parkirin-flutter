// lib/features/payment/presentation/bloc/payment_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/payment/domain/usecases/redeem_free_parking_usecase.dart';

import '../../../ticket_management/domain/entities/ticket.dart';
import '../../domain/usecases/create_payment_usecase.dart';
import '../../domain/usecases/get_payment_usecase.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase _createPaymentUseCase;
  final GetPaymentUseCase _getPaymentUseCase;
  final ProcessPaymentUseCase _processPaymentUseCase;
  final RedeemFreeParkingUseCase _redeemFreeParkingUseCase;

  PaymentBloc({
    required CreatePaymentUseCase createPaymentUseCase,
    required RedeemFreeParkingUseCase redeemFreeParkingUseCase,
    required GetPaymentUseCase getPaymentUseCase,
    required ProcessPaymentUseCase processPaymentUseCase,
  })  : _createPaymentUseCase = createPaymentUseCase,
        _getPaymentUseCase = getPaymentUseCase,
        _processPaymentUseCase = processPaymentUseCase,
        _redeemFreeParkingUseCase = redeemFreeParkingUseCase,
        super(PaymentInitial()) {
    on<CreatePayment>(_onCreatePayment);
    on<LoadPayment>(_onLoadPayment);
    on<ProcessPaymentCompletion>(_onProcessPaymentCompletion);
    on<RedeemFreeParking>(_onRedeemFreeParking);
  }

  Future<void> _onCreatePayment(
    CreatePayment event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading('Creating payment...'));

      final payment = await _createPaymentUseCase(
        ticketId: event.ticketId,
        userId: event.userId,
        amount: event.amount,
        itemName: event.itemName,
      );

      emit(PaymentCreated(payment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onRedeemFreeParking(
    RedeemFreeParking event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading('Processing free parking redemption...'));

      await _redeemFreeParkingUseCase(
        userId: event.userId,
        ticketId: event.ticketId,
      );

      emit(RedemptionCompleted(event.ticketId));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onLoadPayment(
    LoadPayment event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading('Loading payment details...'));

      final payment = await _getPaymentUseCase(event.paymentId);

      // If payment is in a final state, process it
      if (payment.status == PaymentStatus.paid ||
          payment.status == PaymentStatus.failed) {
        add(ProcessPaymentCompletion(
          paymentId: payment.id,
          ticketId: payment.ticketId,
          status: payment.status,
        ));
      } else {
        emit(PaymentLoaded(payment));
      }
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onProcessPaymentCompletion(
    ProcessPaymentCompletion event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoading('Processing payment completion...'));

      final updatedPayment = await _processPaymentUseCase(
        paymentId: event.paymentId,
        ticketId: event.ticketId,
        paymentStatus: event.status,
      );

      emit(PaymentCompleted(updatedPayment));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}

// lib/di/dependency_injection.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:parkirin/core/services/localization_service.dart';
import 'package:parkirin/features/authentication/data/repositories/user_repository.dart';
import 'package:parkirin/features/authentication/domain/usecases/edit_profile_usecase.dart';
import 'package:parkirin/features/authentication/presentation/bloc/profile_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/latest_pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_bills_bloc.dart';
import 'package:parkirin/features/driver/presentation/bloc/pending_tickets_count_bloc.dart';
import 'package:parkirin/features/payment/data/repositories/firebase_payment_repository.dart';
import 'package:parkirin/features/payment/data/services/midtrans_service.dart';
import 'package:parkirin/features/payment/data/services/payment_status_checker.dart';
import 'package:parkirin/features/payment/domain/repositories/i_payment_repository.dart';
import 'package:parkirin/features/payment/domain/usecases/create_payment_usecase.dart';
import 'package:parkirin/features/payment/domain/usecases/get_payment_usecase.dart';
import 'package:parkirin/features/payment/domain/usecases/process_payment_usecase.dart';
import 'package:parkirin/features/payment/domain/usecases/redeem_free_parking_usecase.dart';
import 'package:parkirin/features/payment/domain/usecases/update_payment_status_usecase.dart';
import 'package:parkirin/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:parkirin/features/ticket_management/data/repositories/firebase_parking_record_repository.dart';
import 'package:parkirin/features/ticket_management/domain/repositories/i_parking_record_repository.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/edit_ticket_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/get_user_tickets_count_usecase.dart';
import 'package:parkirin/features/ticket_management/domain/usecases/record_parking_usecase.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/record_parking_bloc.dart';
import 'package:parkirin/features/vehicle_management/data/repositories/vehicle_repository.dart';
import 'package:parkirin/features/vehicle_management/domain/repositories/i_vehicle_repository.dart';
import 'package:parkirin/features/vehicle_management/domain/usecases/add_vehicle_usecase.dart';
import 'package:parkirin/features/vehicle_management/domain/usecases/get_user_vehicles_usecase.dart';
import 'package:parkirin/features/vehicle_management/domain/usecases/upload_vehicle_photo_usecase.dart';
import 'package:parkirin/features/vehicle_management/presentation/bloc/vehicle_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/session_service.dart';
import '../features/authentication/data/repositories/firebase_auth_repository.dart';
import '../features/authentication/domain/repositories/i_auth_repository.dart';
import '../features/authentication/domain/usecases/google_sign_in_usecase.dart';
import '../features/authentication/domain/usecases/login_parking_attendant_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/presentation/bloc/auth_bloc.dart';
import '../features/ticket_management/domain/repositories/firebase_ticket_repository.dart';
import '../features/ticket_management/domain/repositories/i_ticket_repository.dart';
import '../features/ticket_management/domain/usecases/create_ticket_usecase.dart';
import '../features/ticket_management/domain/usecases/get_ticket_stream_usecase.dart';
import '../features/ticket_management/domain/usecases/get_tickets_by_date_range_usecase.dart';
import '../features/ticket_management/domain/usecases/get_user_tickets_usecase.dart';
import '../features/ticket_management/domain/usecases/search_tickets_usecase.dart';
import '../features/ticket_management/presentation/bloc/create_ticket_bloc.dart';
import '../features/ticket_management/presentation/bloc/ticket_bloc.dart';
import '../features/vehicle_management/domain/usecases/edit_vehicle_usecase.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  ///*********************************************
  /// Core Services
  ///*********************************************
  getIt.registerLazySingleton(() => SessionService(sharedPreferences));
  getIt.registerLazySingleton(() => LocalizationService());
  getIt.registerLazySingleton(() => MidtransService());

  ///*********************************************
  /// Repositories
  ///*********************************************
  // Auth & User

  // First verify UserRepository registration
  debugPrint('Registering UserRepository...');
  getIt.registerLazySingleton<UserRepository>(() {
    debugPrint('Creating UserRepository instance');
    return UserRepository();
  });
  getIt.registerLazySingleton<IAuthRepository>(() => FirebaseAuthRepository(
        userRepository: getIt<UserRepository>(),
        sessionService: getIt<SessionService>(),
      ));

  // Vehicle
  getIt.registerLazySingleton<IVehicleRepository>(() => VehicleRepository());

  // Ticket
  getIt.registerLazySingleton<ITicketRepository>(
      () => FirebaseTicketRepository());
  getIt.registerLazySingleton<IParkingRecordRepository>(
      () => FirebaseParkingRecordRepository());

  // Payment
  getIt.registerLazySingleton<IPaymentRepository>(
      () => FirebasePaymentRepository());

  ///*********************************************
  /// Use Cases
  ///*********************************************
  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt<IAuthRepository>()));
  getIt.registerLazySingleton(
      () => GoogleSignInUseCase(getIt<IAuthRepository>()));
  getIt.registerLazySingleton(
      () => LoginParkingAttendantUseCase(getIt<IAuthRepository>()));
  getIt
      .registerLazySingleton(() => EditProfileUseCase(getIt<UserRepository>()));

  // Vehicle Use Cases
  getIt.registerLazySingleton(
      () => AddVehicleUseCase(getIt<IVehicleRepository>()));
  getIt.registerLazySingleton(
      () => GetUserVehiclesUseCase(getIt<IVehicleRepository>()));
  getIt.registerLazySingleton(
      () => UploadVehiclePhotoUseCase(getIt<IVehicleRepository>()));
  getIt.registerLazySingleton(
      () => EditVehicleUseCase(getIt<IVehicleRepository>()));

  // Ticket Use Cases
  getIt.registerLazySingleton(
      () => GetUserTicketsUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(
      () => GetTicketsByDateRangeUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(
      () => SearchTicketsUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(
      () => EditTicketUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(
      () => GetTicketStreamUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(
      () => GetUserTicketsCountUseCase(getIt<ITicketRepository>()));
  getIt.registerLazySingleton(() => CreateTicketUseCase(
        getIt<ITicketRepository>(),
        getIt<IVehicleRepository>(),
      ));
  getIt.registerLazySingleton(
      () => RecordParkingUseCase(getIt<IParkingRecordRepository>()));

  // Payment Use Cases
  getIt.registerLazySingleton(
      () => CreatePaymentUseCase(getIt<IPaymentRepository>()));
  getIt.registerLazySingleton(
      () => GetPaymentUseCase(getIt<IPaymentRepository>()));
  getIt.registerLazySingleton(
      () => UpdatePaymentStatusUseCase(getIt<IPaymentRepository>()));
  debugPrint('Registering ProcessPaymentUseCase...');
  getIt.registerLazySingleton(() {
    debugPrint('Creating ProcessPaymentUseCase instance');
    final paymentRepo = getIt<IPaymentRepository>();
    final ticketRepo = getIt<ITicketRepository>();
    final userRepo = getIt<UserRepository>();

    debugPrint('Dependencies retrieved:');
    debugPrint('- Payment Repository: ${paymentRepo.runtimeType}');
    debugPrint('- Ticket Repository: ${ticketRepo.runtimeType}');
    debugPrint('- User Repository: ${userRepo.runtimeType}');

    return ProcessPaymentUseCase(
      paymentRepo,
      ticketRepo,
    );
  });
  getIt.registerLazySingleton(() => RedeemFreeParkingUseCase(
        getIt<ITicketRepository>(),
        getIt<UserRepository>(),
      ));

  ///*********************************************
  /// Services
  ///*********************************************
  getIt.registerLazySingleton(() => PaymentStatusChecker(
        paymentRepository: getIt<IPaymentRepository>(),
        midtransService: getIt<MidtransService>(),
      ));

  ///*********************************************
  /// BLoCs
  ///*********************************************
  // Auth BLoCs
  getIt.registerFactory(() => AuthBloc(
        getIt<LoginUseCase>(),
        getIt<IAuthRepository>(),
        getIt<GoogleSignInUseCase>(),
        getIt<LoginParkingAttendantUseCase>(),
        getIt<SessionService>(),
      ));
  getIt.registerFactory(
      () => ProfileBloc(editProfileUseCase: getIt<EditProfileUseCase>()));

  // Vehicle BLoC
  getIt.registerFactory(() => VehicleBloc(
        addVehicleUseCase: getIt<AddVehicleUseCase>(),
        getUserVehiclesUseCase: getIt<GetUserVehiclesUseCase>(),
        editVehicleUseCase: getIt<EditVehicleUseCase>(),
        uploadVehiclePhotoUseCase: getIt<UploadVehiclePhotoUseCase>(),
      ));

  // Ticket BLoCs
  getIt.registerFactory(() => TicketBloc(
        getUserTicketsUseCase: getIt<GetUserTicketsUseCase>(),
        getTicketsByDateRangeUseCase: getIt<GetTicketsByDateRangeUseCase>(),
        searchTicketsUseCase: getIt<SearchTicketsUseCase>(),
        getTicketStreamUseCase: getIt<GetTicketStreamUseCase>(),
        ticketRepository: getIt<ITicketRepository>(),
        parkingRecordRepository: getIt<IParkingRecordRepository>(),
        getUserTicketsCountUseCase: getIt<GetUserTicketsCountUseCase>(),
      ));
  getIt.registerFactory(() =>
      CreateTicketBloc(createTicketUseCase: getIt<CreateTicketUseCase>()));
  getIt.registerFactory(() => EditTicketBloc(
        editTicketUseCase: getIt<EditTicketUseCase>(),
        ticketRepository: getIt<ITicketRepository>(),
        vehicleRepository: getIt<IVehicleRepository>(),
      ));
  getIt.registerFactory(() => RecordParkingBloc(
        recordParkingUseCase: getIt<RecordParkingUseCase>(),
        repository: getIt<IParkingRecordRepository>(),
      ));
  getIt.registerFactory(() =>
      PendingTicketsCountBloc(ticketRepository: getIt<ITicketRepository>()));
  getIt.registerFactory(() =>
      LatestPendingBillsBloc(ticketRepository: getIt<ITicketRepository>()));
  getIt.registerFactory(
      () => PendingBillsBloc(ticketRepository: getIt<ITicketRepository>()));

  // Payment BLoC
  getIt.registerFactory(() => PaymentBloc(
        createPaymentUseCase: getIt<CreatePaymentUseCase>(),
        getPaymentUseCase: getIt<GetPaymentUseCase>(),
        processPaymentUseCase: getIt<ProcessPaymentUseCase>(),
        redeemFreeParkingUseCase: getIt<RedeemFreeParkingUseCase>(),
      ));
}

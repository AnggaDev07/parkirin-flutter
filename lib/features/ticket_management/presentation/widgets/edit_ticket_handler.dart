// lib/features/ticket_management/presentation/widgets/edit_ticket_handler.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parkirin/features/ticket_management/domain/entities/ticket.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/edit_ticket_state.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_bloc.dart';
import 'package:parkirin/features/ticket_management/presentation/bloc/ticket_event.dart';
import 'package:parkirin/features/ticket_management/presentation/widgets/edit_ticket_dialog.dart';

// lib/features/ticket_management/presentation/widgets/edit_ticket_handler.dart

class EditTicketHandler extends StatelessWidget {
  final Widget child;
  final Ticket ticket;
  final VoidCallback? onEditSuccess;

  const EditTicketHandler({
    super.key,
    required this.child,
    required this.ticket,
    this.onEditSuccess,
  });

  void _handleEditResult(BuildContext context, EditTicketState state) {
    final theme = Theme.of(context);
    debugPrint('Edit ticket state: $state');

    if (state is EditTimeValid) {
      // Add a check to prevent multiple dialogs
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (dialogContext) => BlocProvider.value(
            value: BlocProvider.of<EditTicketBloc>(context),
            child: EditTicketDialog(
              ticket: state.ticket,
              remainingTime: state.remainingTime,
            ),
          ),
        );
      }
    } else if (state is EditTicketSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ticket updated successfully'),
          backgroundColor: theme.colorScheme.secondary,
        ),
      );
      onEditSuccess?.call();
      _loadTickets(context); // Refresh the list
    } else if (state is EditTicketError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  void _loadTickets(BuildContext context) {
    final bloc = context.read<TicketBloc>();
    final attendantId = ticket.attendantId;
    bloc.add(LoadAttendantTickets(
      attendantId: attendantId,
      status: TicketStatus.pending,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditTicketBloc, EditTicketState>(
      listener: (context, state) => _handleEditResult(context, state),
      child: child,
    );
  }
}

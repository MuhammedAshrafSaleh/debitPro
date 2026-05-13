// lib/features/clients/presentation/pages/add_client_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../cubit/add_client_cubit.dart';
import '../cubit/add_client_state.dart';
import '../widgets/client_form.dart';

class AddClientPage extends StatelessWidget {
  const AddClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddClientCubit>(),
      child: const _AddClientView(),
    );
  }
}

class _AddClientView extends StatelessWidget {
  const _AddClientView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AddClientCubit, AddClientState>(
      listener: (context, state) {
        if (state is AddClientFailure) {
          AppSnackbar.error(context, state.message);
        } else if (state is AddClientSaved) {
          AppSnackbar.success(context, l10n.clientsAddSuccess);
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.clientsAddButton)),
        body: BlocBuilder<AddClientCubit, AddClientState>(
          builder: (context, state) {
            return ClientForm(
              isLoading: state is AddClientSaving,
              onSave: ({
                required fullName,
                required phone,
                required gender,
                required documentationType,
                required clientType,
                notes,
              }) {
                context.read<AddClientCubit>().save(
                      fullName: fullName,
                      phone: phone,
                      gender: gender,
                      documentationType: documentationType,
                      clientType: clientType,
                      notes: notes,
                    );
              },
              onCancel: () => context.pop(),
            );
          },
        ),
      ),
    );
  }
}

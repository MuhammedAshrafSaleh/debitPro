// lib/features/clients/presentation/pages/edit_client_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../cubit/client_detail_cubit.dart';
import '../cubit/client_detail_state.dart';
import '../cubit/edit_client_cubit.dart';
import '../cubit/edit_client_state.dart';
import '../widgets/client_form.dart';

class EditClientPage extends StatelessWidget {
  const EditClientPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ClientDetailCubit>()..loadClient(clientId),
        ),
        BlocProvider(create: (_) => sl<EditClientCubit>()),
      ],
      child: _EditClientView(clientId: clientId),
    );
  }
}

class _EditClientView extends StatelessWidget {
  const _EditClientView({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<EditClientCubit, EditClientState>(
      listener: (context, state) {
        if (state is EditClientFailure) {
          AppSnackbar.error(context, state.message);
        } else if (state is EditClientSaved) {
          AppSnackbar.success(context, l10n.clientsEditSuccess);
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsEditAccount)),
        body: BlocBuilder<ClientDetailCubit, ClientDetailState>(
          builder: (context, detailState) {
            if (detailState is ClientDetailLoading ||
                detailState is ClientDetailInitial) {
              return const AppLoadingIndicator();
            }
            if (detailState is ClientDetailFailure) {
              return Center(
                child: Text(
                  detailState.message,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            if (detailState is ClientDetailLoaded) {
              final client = detailState.client;
              return BlocBuilder<EditClientCubit, EditClientState>(
                builder: (context, editState) {
                  return ClientForm(
                    initialFullName: client.fullName,
                    initialPhone: client.phone,
                    initialGender: client.gender,
                    initialDocumentationType: client.documentationType,
                    initialClientType: client.clientType,
                    initialNotes: client.notes,
                    isLoading: editState is EditClientSaving,
                    onSave: ({
                      required fullName,
                      required phone,
                      required gender,
                      required documentationType,
                      required clientType,
                      notes,
                    }) {
                      context.read<EditClientCubit>().save(
                            id: clientId,
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

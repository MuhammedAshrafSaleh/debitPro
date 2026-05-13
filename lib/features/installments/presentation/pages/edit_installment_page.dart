// lib/features/installments/presentation/pages/edit_installment_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/quality_badge.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../clients/presentation/cubit/client_detail_cubit.dart';
import '../../../clients/presentation/cubit/client_detail_state.dart';
import '../cubit/edit_installment_cubit.dart';
import '../cubit/edit_installment_state.dart';
import '../widgets/installment_form.dart';

class EditInstallmentPage extends StatelessWidget {
  const EditInstallmentPage({super.key, required this.installmentId});

  final String installmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<EditInstallmentCubit>()..load(installmentId),
      child: _EditInstallmentView(installmentId: installmentId),
    );
  }
}

class _EditInstallmentView extends StatelessWidget {
  const _EditInstallmentView({required this.installmentId});

  final String installmentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<EditInstallmentCubit, EditInstallmentState>(
      listener: (context, state) {
        if (state.status == EditInstallmentStatus.failure &&
            state.errorMessage != null) {
          AppSnackbar.error(context, state.errorMessage!);
        } else if (state.status == EditInstallmentStatus.saved) {
          AppSnackbar.success(context, l10n.installmentsEditSuccess);
          if (context.mounted) context.pop();
        }
      },
      builder: (context, state) {
        if (state.isLoading ||
            state.status == EditInstallmentStatus.initial) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.installmentsEditTitle)),
            body: const AppLoadingIndicator(),
          );
        }

        if (state.status == EditInstallmentStatus.failure &&
            state.installment == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.installmentsEditTitle)),
            body: Center(child: Text(state.errorMessage ?? l10n.commonError)),
          );
        }

        final installment = state.installment!;
        final isLocked = installment.editLocked;

        return BlocProvider(
          create: (_) =>
              sl<ClientDetailCubit>()..loadClient(installment.clientId),
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.installmentsEditTitle)),
            body:
                BlocBuilder<ClientDetailCubit, ClientDetailState>(
              builder: (context, clientState) {
                if (clientState is ClientDetailLoading ||
                    clientState is ClientDetailInitial) {
                  return const AppLoadingIndicator();
                }
                if (clientState is ClientDetailFailure) {
                  return Center(child: Text(clientState.message));
                }
                if (clientState is! ClientDetailLoaded) {
                  return const SizedBox.shrink();
                }

                final client = clientState.client;
                final badge =
                    StatusUtils.qualityBadge(client.paymentQualityScore);

                return InstallmentForm(
                  clientName: client.fullName,
                  clientType: client.clientType,
                  qualityBadgeWidget: QualityBadgeWidget(badge: badge),
                  monthlyAmount: state.monthlyAmount,
                  totalDebt: state.totalDebt,
                  durationMonths: state.durationMonths,
                  officeCommissionAmount: state.officeCommissionAmount,
                  isLoading: state.isSaving,
                  isEditLocked: isLocked,
                  initialItemName: installment.itemName,
                  initialCapital: installment.capital,
                  initialProfitAmount: installment.profitAmount,
                  initialDurationMonths: installment.durationMonths,
                  initialStartDate: installment.startDate,
                  initialOfficeCommissionPaid:
                      installment.officeCommissionPaid,
                  onFormChanged: ({
                    required capital,
                    required profitAmount,
                    required durationMonths,
                  }) {
                    context.read<EditInstallmentCubit>().updateSummary(
                          capital: capital,
                          profitAmount: profitAmount,
                          durationMonths: durationMonths,
                        );
                  },
                  onSave: (data) {
                    context.read<EditInstallmentCubit>().save(
                          installmentId: installmentId,
                          clientId: installment.clientId,
                          itemName: data.itemName,
                          capital: data.capital,
                          profitAmount: data.profitAmount,
                          durationMonths: data.durationMonths,
                          startDate: data.startDate,
                        );
                  },
                  onCancel: () => context.pop(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

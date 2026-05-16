// lib/features/installments/presentation/pages/add_installment_page.dart

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
import '../cubit/add_installment_cubit.dart';
import '../cubit/add_installment_state.dart';
import '../widgets/installment_form.dart';

class AddInstallmentPage extends StatelessWidget {
  const AddInstallmentPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ClientDetailCubit>()..loadClient(clientId),
        ),
        BlocProvider(create: (_) => sl<AddInstallmentCubit>()),
      ],
      child: _AddInstallmentView(clientId: clientId),
    );
  }
}

class _AddInstallmentView extends StatelessWidget {
  const _AddInstallmentView({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AddInstallmentCubit, AddInstallmentState>(
      listener: (context, state) {
        if (state.status == AddInstallmentStatus.failure &&
            state.errorMessage != null) {
          AppSnackbar.error(context, state.errorMessage!);
        } else if (state.status == AddInstallmentStatus.saved) {
          AppSnackbar.success(context, l10n.installmentsAddSuccess);
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.installmentsAddTitle)),
        body: BlocBuilder<ClientDetailCubit, ClientDetailState>(
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
            final badge = StatusUtils.qualityBadge(client.paymentQualityScore);

            return BlocBuilder<AddInstallmentCubit, AddInstallmentState>(
              builder: (context, formState) {
                return InstallmentForm(
                  clientName: client.fullName,
                  clientType: client.clientType,
                  qualityBadgeWidget: QualityBadgeWidget(badge: badge),
                  monthlyAmount: formState.monthlyAmount,
                  totalDebt: formState.totalDebt,
                  durationMonths: formState.durationMonths,
                  officeCommissionAmount: formState.officeCommissionAmount,
                  discountPerMonth: formState.discountPerMonth,
                  isLoading: formState.isSaving,
                  onFormChanged:
                      ({
                        required capital,
                        required profitAmount,
                        required discountPerMonth,
                        required durationMonths,
                      }) {
                        context.read<AddInstallmentCubit>().updateSummary(
                          capital: capital,
                          profitAmount: profitAmount,
                          durationMonths: durationMonths,
                          isOfficeClient: client.clientType.name == 'office',
                          discountPerMonth: discountPerMonth,
                        );
                      },
                  onSave: (data) {
                    context.read<AddInstallmentCubit>().save(
                      clientId: clientId,
                      clientType: client.clientType,
                      officeCommissionPaidAtCreation:
                          data.officeCommissionPaidAtCreation,
                      itemName: data.itemName,
                      capital: data.capital,
                      profitAmount: data.profitAmount,
                      discountPerMonth: data.discountPerMonth,
                      durationMonths: data.durationMonths,
                      startDate: data.startDate,
                    );
                  },
                  onCancel: () => context.pop(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

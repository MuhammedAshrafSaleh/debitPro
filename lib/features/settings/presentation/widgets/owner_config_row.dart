// lib/features/settings/presentation/widgets/owner_config_row.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../cubit/owner_config_cubit.dart';
import '../cubit/owner_config_state.dart';

class OwnerConfigRow extends StatefulWidget {
  const OwnerConfigRow({super.key});

  @override
  State<OwnerConfigRow> createState() => _OwnerConfigRowState();
}

class _OwnerConfigRowState extends State<OwnerConfigRow> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerConfigCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<OwnerConfigCubit, OwnerConfigState>(
      builder: (context, state) {
        final double cardFee;
        final double riyalValue;

        if (state is OwnerConfigSuccess) {
          cardFee = state.config.cardFee;
          riyalValue = state.config.riyalValue;
        } else {
          cardFee = 0.0;
          riyalValue = 0.0;
        }

        return ListTile(
          leading: const Icon(Icons.tune_outlined),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.settingsCardFee}: $cardFee',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.settingsRiyalValue}: $riyalValue',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: state is OwnerConfigLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showEditDialog(
                    cardFee: cardFee,
                    riyalValue: riyalValue,
                  ),
                ),
        );
      },
    );
  }

  Future<void> _showEditDialog({
    required double cardFee,
    required double riyalValue,
  }) async {
    final l10n = AppLocalizations.of(context);
    final cardFeeController =
        TextEditingController(text: cardFee == 0.0 ? '' : cardFee.toString());
    final riyalController =
        TextEditingController(text: riyalValue == 0.0 ? '' : riyalValue.toString());
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.settingsOwnerConfig),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cardFeeController,
                decoration: InputDecoration(labelText: l10n.settingsCardFee),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.commonError : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: riyalController,
                decoration: InputDecoration(labelText: l10n.settingsRiyalValue),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.commonError : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    final newCardFee = double.tryParse(cardFeeController.text.trim()) ?? 0.0;
    final newRiyalValue = double.tryParse(riyalController.text.trim()) ?? 0.0;
    final cubit = context.read<OwnerConfigCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await cubit.update(
      cardFee: newCardFee,
      riyalValue: newRiyalValue,
    );

    if (!mounted) return;
    if (success) {
      messenger.clearSnackBars();
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.settingsOwnerConfigSaved),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 3),
      ));
    } else {
      final state = cubit.state;
      if (state is OwnerConfigFailure) {
        messenger.clearSnackBars();
        messenger.showSnackBar(SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }
}

class OwnerConfigRowProvider extends StatelessWidget {
  const OwnerConfigRowProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OwnerConfigCubit>(),
      child: const OwnerConfigRow(),
    );
  }
}

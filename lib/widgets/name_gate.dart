import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/radius.dart';
import 'buttons.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';

/// Name gate shown before entering a room when the user still carries the
/// default identity. Collects a display name, persists it to AppState, and
/// triggers anonymous auth so the room channel gets a stable UID. The parent
/// should watch [AppState.hasCustomName] and swap back to its real content
/// once a name is saved.
class KNameGateScreen extends StatelessWidget {
  final String title;
  final VoidCallback? onNameSet;

  const KNameGateScreen({
    super.key,
    this.title = 'Before you join\u2026',
    this.onNameSet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(title, style: const TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700,
                fontSize: 28, color: KColors.bone,
              )),
              const SizedBox(height: 12),
              Text(
                'Pick a display name so the room knows who is singing.',
                style: KTypography.uiBody.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 32),
              _NameField(onNameSet: onNameSet),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatefulWidget {
  final VoidCallback? onNameSet;

  const _NameField({this.onNameSet});

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  final _nameController = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _hasError = true);
      return;
    }
    context.read<AppState>().setUserName(name);
    // Give the guest a stable Firebase UID: the timestamp-generated local id
    // changes on restart and cannot sync with other players. Fire-and-forget.
    unawaited(context.read<AuthService>().signInAsGuest());
    widget.onNameSet?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Your display name',
            hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
            errorText: _hasError ? 'A name is required to continue.' : null,
            filled: true,
            fillColor: KColors.ink600,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KRadius.input),
              borderSide: const BorderSide(color: KColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KRadius.input),
              borderSide: const BorderSide(color: KColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KRadius.input),
              borderSide: const BorderSide(color: KColors.lime, width: 1),
            ),
          ),
          onChanged: (_) {
            if (_hasError) setState(() => _hasError = false);
          },
          onSubmitted: (_) => _confirm(),
        ),
        const SizedBox(height: 24),
        KPrimaryButton(label: 'Continue', onPressed: _confirm),
      ],
    );
  }
}

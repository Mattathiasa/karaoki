import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/ui_components.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const SettingsScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(KSpacing.mobilePaddingH, KSpacing.mobilePaddingV, KSpacing.mobilePaddingH, 0),
            child: Row(children: [
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: onBack),
              const SizedBox(width: 12),
              const Expanded(child: Text('Settings', style: TextStyle(
                fontFamily: 'BricolageGrotesque', fontWeight: FontWeight.w700, fontSize: 22, color: KColors.bone,
              ))),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(KSpacing.mobilePaddingH), children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KColors.mint.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(color: KColors.mint.withOpacity(0.2), width: 0.5),
                ),
                child: Row(children: [
                  const Icon(Icons.mic, color: KColors.mint, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('MICROPHONE', style: KTypography.monoLabel.copyWith(fontSize: 9)),
                    Text('Input level', style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
                  ])),
                  const KMicStatus(connected: true, level: 0.7),
                ]),
              ),
              const SizedBox(height: 24),
              const _SettingsRow(icon: Icons.high_quality, label: 'Audio quality', value: 'High \u00b7 256kbps'),
              const _SettingsRow(icon: Icons.notifications, label: 'Turn notifications', value: 'On'),
              const _SettingsRow(icon: Icons.dark_mode, label: 'Appearance', value: 'Dark'),
              const _SettingsRow(icon: Icons.shield, label: 'Privacy', value: 'Friends only'),
              const _SettingsRow(icon: Icons.email, label: 'Account', value: 'matt@email.com'),
              const _SettingsRow(icon: Icons.help, label: 'Help & feedback', value: ''),
              const SizedBox(height: 32),
              KDangerButton(label: 'Sign out', onPressed: () {}),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SettingsRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: KColors.ink650, borderRadius: BorderRadius.circular(KRadius.tile), border: Border.all(color: KColors.hairline, width: 0.5)),
      child: Row(children: [
        Icon(icon, color: KColors.bone28, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: KTypography.uiRowTitle)),
        Text(value, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: KColors.bone28, size: 18),
      ]),
    );
  }
}

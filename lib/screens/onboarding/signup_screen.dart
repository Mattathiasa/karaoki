import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignedUp;
  final VoidCallback? goToSignin;

  const SignupScreen({super.key, this.onBack, this.onSignedUp, this.goToSignin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 16),
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: widget.onBack),
              const SizedBox(height: 32),
              const Text(
                'Create account',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 24),
              // Microphone detected strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KColors.mint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KRadius.tile),
                  border: Border.all(color: KColors.mint.withOpacity(0.3), width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: KColors.mint, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      'Microphone detected — sounds good',
                      style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.mint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _LabeledField(
                label: 'EMAIL',
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'you@email.com',
                    hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
                    filled: true,
                    fillColor: KColors.ink600,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _emailError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _emailError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: const BorderSide(color: KColors.lime, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() => _emailError = null),
                ),
              ),
              if (_emailError != null) ...[
                const SizedBox(height: 6),
                Text(_emailError!, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red)),
              ],
              const SizedBox(height: 16),
              _LabeledField(
                label: 'PASSWORD',
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Min 8 characters',
                    hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
                    filled: true,
                    fillColor: KColors.ink600,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _passwordError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _passwordError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: const BorderSide(color: KColors.lime, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() => _passwordError = null),
                ),
              ),
              if (_passwordError != null) ...[
                const SizedBox(height: 6),
                Text(_passwordError!, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red)),
              ],
              const SizedBox(height: 16),
              _LabeledField(
                label: 'CONFIRM PASSWORD',
                child: TextField(
                  controller: _confirmController,
                  obscureText: true,
                  style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Re-enter password',
                    hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
                    filled: true,
                    fillColor: KColors.ink600,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _confirmError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: BorderSide(color: _confirmError != null ? KColors.red : KColors.hairline, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KRadius.input),
                      borderSide: const BorderSide(color: KColors.lime, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() => _confirmError = null),
                ),
              ),
              if (_confirmError != null) ...[
                const SizedBox(height: 6),
                Text(_confirmError!, style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.red)),
              ],
              const Spacer(),
              KPrimaryButton(label: 'Create account', onPressed: widget.onSignedUp),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: widget.goToSignin,
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: KTypography.uiBody.copyWith(fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: KTypography.uiButton.copyWith(color: KColors.lime, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

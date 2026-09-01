import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';

class SigninScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignedIn;
  final VoidCallback? goToSignup;

  const SigninScreen({super.key, this.onBack, this.onSignedIn, this.goToSignup});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        _emailError = 'Enter a valid email address';
      }
      if (_passwordController.text.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      }
    });
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
              // Back button
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: widget.onBack),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Sign in',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 32),
              // Email field
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
              const SizedBox(height: 20),
              // Password field
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
              const SizedBox(height: 8),
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Forgot password?',
                    style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.lime),
                  ),
                ),
              ),
              const Spacer(),
              // Sign in button
              KPrimaryButton(label: 'Sign in', onPressed: widget.onSignedIn),
              const SizedBox(height: 16),
              // Go to signup
              Center(
                child: GestureDetector(
                  onTap: widget.goToSignup,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: KTypography.uiBody.copyWith(fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Sign up',
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

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/radius.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SetupScreen({super.key, this.onComplete});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  String _selectedLevel = '';
  final Set<String> _selectedGenres = {};

  static const _genres = ['Pop', 'Rock', 'Hip Hop', 'R&B', 'Gospel', 'Classics', 'Party', 'Ethiopian'];
  static const _levels = [
    ('Beginner', 'Just here to have fun'),
    ('Casual', 'I sing at parties'),
    ('Performer', 'I take this seriously'),
    ('Karaoke Legend', 'I am the stage'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.ink800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: KSpacing.mobilePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              KIconButton(icon: Icons.arrow_back_ios_new, size: 34, onPressed: () {}),
              const SizedBox(height: 32),
              const Text(
                'Set up your profile',
                style: TextStyle(
                  fontFamily: 'BricolageGrotesque',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  color: KColors.bone,
                ),
              ),
              const SizedBox(height: 32),
              // Avatar picker
              Center(
                child: Stack(
                  children: [
                    const KAvatar(initial: 'M', size: 110),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: KColors.ink600,
                          shape: BoxShape.circle,
                          border: Border.all(color: KColors.hairline, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.edit, color: KColors.bone, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Display name
              _Field(label: 'DISPLAY NAME', child: TextField(
                controller: _nameController,
                style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                decoration: _inputDecoration('Your display name'),
              )),
              const SizedBox(height: 16),
              // Username
              _Field(label: 'USERNAME', child: TextField(
                controller: _usernameController,
                style: KTypography.uiBody.copyWith(color: KColors.bone, fontSize: 15),
                decoration: _inputDecoration('@username').copyWith(
                  prefixText: '@',
                  prefixStyle: KTypography.monoLabel.copyWith(fontSize: 15, color: KColors.bone45),
                ),
              )),
              const SizedBox(height: 24),
              // Genre chips
              Text('GENRES', style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genres.map((g) {
                  final selected = _selectedGenres.contains(g);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) _selectedGenres.remove(g);
                      else _selectedGenres.add(g);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? KColors.limeTint : KColors.ink600,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? KColors.lime : KColors.hairline,
                          width: 0.5,
                        ),
                      ),
                      child: Text(g, style: KTypography.uiButton.copyWith(
                        fontSize: 12.5,
                        color: selected ? KColors.lime : KColors.bone55,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Experience level
              Text('EXPERIENCE', style: KTypography.monoLabel.copyWith(fontSize: 11.5)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: _levels.map((l) {
                  final selected = _selectedLevel == l.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLevel = l.$1),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? KColors.limeTint.withOpacity(0.2) : KColors.ink650,
                        borderRadius: BorderRadius.circular(KRadius.tile),
                        border: Border.all(
                          color: selected ? KColors.lime : KColors.hairline,
                          width: selected ? 1 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l.$1, style: KTypography.uiRowTitle.copyWith(fontSize: 13)),
                                Text(l.$2, style: KTypography.monoLabel.copyWith(fontSize: 9)),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check, color: KColors.lime, size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              KPrimaryButton(label: 'Enter Karaoki', onPressed: widget.onComplete),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: KTypography.uiBody.copyWith(color: KColors.bone28, fontSize: 15),
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
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

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

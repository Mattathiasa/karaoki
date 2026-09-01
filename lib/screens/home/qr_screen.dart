import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

class QrScreen extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSimulate;

  const QrScreen({super.key, this.onCancel, this.onSimulate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text('CAMERA PREVIEW', style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancel,
                    child: Text('Cancel', style: KTypography.uiButton.copyWith(
                      color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 14,
                    )),
                  ),
                ],
              ),
            ),
            // Camera placeholder
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: KColors.ink900,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Reticle corners
                      const _ReticleCorner(top: 0, left: 0),
                      const _ReticleCorner(top: 0, right: 0),
                      const _ReticleCorner(bottom: 0, left: 0),
                      const _ReticleCorner(bottom: 0, right: 0),
                      // Scan line
                      Positioned(
                        top: 40,
                        left: 40,
                        right: 40,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: KColors.scoreFillGradient,
                            boxShadow: [BoxShadow(color: KColors.teal.withOpacity(0.5), blurRadius: 8)],
                          ),
                        ),
                      ),
                      // Center text
                      Text(
                        'Point at QR code',
                        style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Align the QR code within the frame',
                    style: KTypography.uiBody.copyWith(fontSize: 14.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  KPrimaryButton(label: 'Simulate successful scan', onPressed: onSimulate),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Camera permission blocked? Enter code instead",
                      style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReticleCorner extends StatelessWidget {
  final double? top, bottom, left, right;
  const _ReticleCorner({this.top, this.bottom, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: KColors.lime, width: 3) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: KColors.lime, width: 3) : BorderSide.none,
            left: left != null ? const BorderSide(color: KColors.lime, width: 3) : BorderSide.none,
            right: right != null ? const BorderSide(color: KColors.lime, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

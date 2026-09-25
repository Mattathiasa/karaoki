import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/buttons.dart';

class QrScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSimulate;

  const QrScreen({super.key, this.onCancel, this.onSimulate});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _permissionGranted = false;
  bool _checked = false;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _permissionGranted = status.isGranted;
      _permanentlyDenied = status.isPermanentlyDenied;
      _checked = true;
    });
  }

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
                    onTap: widget.onCancel,
                    child: Text('Cancel', style: KTypography.uiButton.copyWith(
                      color: KColors.bone55, fontWeight: FontWeight.w400, fontSize: 14,
                    )),
                  ),
                ],
              ),
            ),
            // Camera placeholder / permission state
            Expanded(
              child: Center(
                child: !_checked
                    ? const CircularProgressIndicator(color: KColors.lime)
                    : !_permissionGranted
                        ? _PermissionBlocked(
                            permanentlyDenied: _permanentlyDenied,
                            onRetry: _requestPermission,
                            onEnterCode: widget.onCancel,
                          )
                        : Container(
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
                            boxShadow: [BoxShadow(color: KColors.teal.withValues(alpha: 0.5), blurRadius: 8)],
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
                        )
              ),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_permissionGranted) ...[
                    Text(
                      'Align the QR code within the frame',
                      style: KTypography.uiBody.copyWith(fontSize: 14.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  KPrimaryButton(
                    label: _permissionGranted ? 'Simulate successful scan' : 'Enter code instead',
                    onPressed: _permissionGranted ? widget.onSimulate : widget.onCancel,
                  ),
                  if (_permissionGranted) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Text(
                        "Camera permission blocked? Enter code instead",
                        style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
                      ),
                    ),
                  ],
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

/// Explainer shown when camera permission is denied or blocked,
/// per the `micPerm`-style edge state in SCREENS.md.
class _PermissionBlocked extends StatelessWidget {
  final bool permanentlyDenied;
  final VoidCallback onRetry;
  final VoidCallback? onEnterCode;

  const _PermissionBlocked({
    required this.permanentlyDenied,
    required this.onRetry,
    this.onEnterCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [KColors.lime, KColors.tangerine]),
            ),
            child: const Icon(Icons.photo_camera, color: KColors.onAccent, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            'Zemaoki needs your camera',
            style: KTypography.displaySection.copyWith(fontSize: 20, color: KColors.bone),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'The camera is used only to scan the room QR code on the board. Nothing is recorded or saved.',
            style: KTypography.uiBody.copyWith(fontSize: 13.5, color: KColors.bone55),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          KSecondaryButton(
            label: permanentlyDenied ? 'Open settings' : 'Allow camera',
            onPressed: () async {
              if (permanentlyDenied) {
                await openAppSettings();
              } else {
                onRetry();
              }
            },
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onEnterCode,
            child: Text(
              'Not now — I\'ll enter the code',
              style: KTypography.uiButton.copyWith(
                color: KColors.bone55,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// QR code display widget for room sharing
/// Shows room code + scannable QR for TV board or phone join
class RoomQrCode extends StatelessWidget {
  final String roomCode;
  final String roomName;
  final double size;

  const RoomQrCode({
    super.key,
    required this.roomCode,
    required this.roomName,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = 'https://zemaoki.app/join/$roomCode';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KColors.ink700,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KColors.hairline, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SCAN TO JOIN',
            style: KTypography.monoLabel.copyWith(fontSize: 9, color: KColors.bone45),
          ),
          const SizedBox(height: 12),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            roomCode,
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: KColors.bone,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roomName,
            style: KTypography.monoLabel.copyWith(fontSize: 10, color: KColors.bone45),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _hasScanned = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _hasScanned = true);
    _controller.stop();

    await ref.read(scanReceiptProvider.notifier).scan(
          rawValue,
          onSuccess: () {
            final result = ref.read(scanReceiptProvider);
            if (result.receipt != null) {
              // Invalidate dashboard so it refreshes
              ref.invalidate(receiptsProvider);
              // Navigate to detail screen
              if (mounted) {
                context.pushReplacement('/receipt/${result.receipt!.id}');
              }
            }
          },
        );

    // If error, allow re-scan
    final result = ref.read(scanReceiptProvider);
    if (result.state == ScanState.error && mounted) {
      setState(() => _hasScanned = false);
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanReceiptProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear QR Code'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(scanReceiptProvider.notifier).reset();
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
            tooltip: _torchOn ? 'Desligar lanterna' : 'Ligar lanterna',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Overlay with scanning frame
          _ScannerOverlay(),

          // Instruction label
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (scanState.state == ScanState.loading)
                  const _StatusBanner(
                    icon: Icons.sync_rounded,
                    message: 'Processando nota fiscal...',
                    color: AppTheme.primaryAction,
                    showSpinner: true,
                  )
                else if (scanState.state == ScanState.error)
                  _StatusBanner(
                    icon: Icons.error_outline_rounded,
                    message: 'Erro: ${scanState.errorMessage ?? "Tente novamente"}',
                    color: Colors.redAccent,
                  )
                else
                  const _StatusBanner(
                    icon: Icons.qr_code_scanner_rounded,
                    message: 'Aponte para o QR Code da nota fiscal',
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated scanner overlay
// ---------------------------------------------------------------------------
class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const frameSize = 260.0;

    return Stack(
      children: [
        // Dark overlay with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.58),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: frameSize,
                  height: frameSize,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Neon border around cutout
        Align(
          alignment: Alignment.center,
          child: Container(
            width: frameSize,
            height: frameSize,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryAction, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Corner accents (neon L-shapes at each corner)
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: frameSize,
            height: frameSize,
            child: CustomPaint(
              painter: _CornerPainter(color: AppTheme.primaryAction),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status banner displayed below the frame
// ---------------------------------------------------------------------------
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final bool showSpinner;

  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.color,
    this.showSpinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter for the scan frame corners
// ---------------------------------------------------------------------------
class _CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;

  _CornerPainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.cornerLength = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Top Left
    path.moveTo(0, cornerLength);
    path.lineTo(0, 0);
    path.lineTo(cornerLength, 0);

    // Top Right
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLength);

    // Bottom Right
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - cornerLength, size.height);

    // Bottom Left
    path.moveTo(cornerLength, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

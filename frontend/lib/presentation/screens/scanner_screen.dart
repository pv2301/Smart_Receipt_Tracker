import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';
import '../providers/settings_provider.dart';
import '../../data/receipt_repository.dart';

// ── SEFAZ state detection (mirrors backend sefaz_registry.py) ────────────────

const _sefazDomains = <String, String>{
  'nfce.sefaz.pe.gov.br': 'PE',
  'www.nfce.fazenda.sp.gov.br': 'SP',
  'nfce.fazenda.sp.gov.br': 'SP',
  'nfce.fazenda.rj.gov.br': 'RJ',
  'www.fazenda.rj.gov.br': 'RJ',
  'nfce.sefaz.ba.gov.br': 'BA',
  'nfce.sefaz.mg.gov.br': 'MG',
  'www.fazenda.mg.gov.br': 'MG',
  'nfce.sefaz.rs.gov.br': 'RS',
  'nfce.sefaz.pr.gov.br': 'PR',
  'sat.sef.sc.gov.br': 'SC',
  'nfce.sef.sc.gov.br': 'SC',
  'nfce.sefaz.ce.gov.br': 'CE',
  'nfce.sefaz.go.gov.br': 'GO',
  'sistemas.sefaz.am.gov.br': 'AM',
  'nfce.sefaz.ma.gov.br': 'MA',
  'nfce.sefaz.mt.gov.br': 'MT',
  'nfce.sefaz.ms.gov.br': 'MS',
  'nfce.sefaz.es.gov.br': 'ES',
  'nfce.sefaz.pi.gov.br': 'PI',
  'nfce.sefaz.rn.gov.br': 'RN',
  'nfce.sefaz.pb.gov.br': 'PB',
  'nfce.sefaz.al.gov.br': 'AL',
  'nfce.sefaz.se.gov.br': 'SE',
  'nfce.sefaz.ro.gov.br': 'RO',
  'nfce.sefaz.to.gov.br': 'TO',
  'nfce.sefaz.pa.gov.br': 'PA',
};

const _cufToState = <String, String>{
  '11': 'RO', '12': 'AC', '13': 'AM', '14': 'RR', '15': 'PA',
  '16': 'AP', '17': 'TO', '21': 'MA', '22': 'PI', '23': 'CE',
  '24': 'RN', '25': 'PB', '26': 'PE', '27': 'AL', '28': 'SE',
  '29': 'BA', '31': 'MG', '32': 'ES', '33': 'RJ', '35': 'SP',
  '41': 'PR', '42': 'SC', '43': 'RS', '50': 'MS', '51': 'MT',
  '52': 'GO', '53': 'DF',
};

String? _detectStateFromUrl(String url) {
  try {
    final host = Uri.parse(url).host;
    return _sefazDomains[host];
  } catch (_) {
    return null;
  }
}

String? _detectStateFromKey(String key) {
  final digits = key.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 2) return _cufToState[digits.substring(0, 2)];
  return null;
}

String? _detectState(String url) =>
    _detectStateFromUrl(url) ?? _detectStateFromKey(url);

// ─────────────────────────────────────────────────────────────────────────────

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

    await _processScan(rawValue);
  }

  Future<void> _processScan(String qrUrl) async {
    await ref.read(scanReceiptProvider.notifier).scan(
      qrUrl,
      onSuccess: () async {
        final result = ref.read(scanReceiptProvider);
        if (result.receipt != null) {
          ref.invalidate(receiptsProvider);

          // Geo-aware: check if QR state differs from user's default
          await _checkStateChange(qrUrl);

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

  Future<void> _checkStateChange(String qrUrl) async {
    final settingsAsync = ref.read(settingsProvider);
    if (!settingsAsync.hasValue) return;
    final settings = settingsAsync.value!;

    if (!settings.detectStateFromQr || !settings.askOnStateChange) return;

    final detectedState = _detectState(qrUrl);
    if (detectedState == null || detectedState == settings.defaultState) return;

    if (!mounted) return;

    final adopt = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppTheme.primaryAction),
                  const SizedBox(width: 8),
                  Text(
                    'SEFAZ detectada: $detectedState',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Essa nota é de $detectedState, mas sua SEFAZ padrão é ${settings.defaultState}. '
                'Deseja atualizar para $detectedState?',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Manter atual'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Usar $detectedState'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (adopt == true) {
      final updated = settingsAsync.value!.copyWith(defaultState: detectedState);
      await ref.read(settingsProvider.notifier).save(updated);
    }
  }

  Future<void> _pickAndScanImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OCR disponível apenas no app móvel'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? photo = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Foto do cupom fiscal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppTheme.primaryAction),
              title: const Text('Tirar foto agora'),
              onTap: () async {
                final f = await picker.pickImage(source: ImageSource.camera);
                if (ctx.mounted) Navigator.pop(ctx, f);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.primaryAction),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                final f = await picker.pickImage(source: ImageSource.gallery);
                if (ctx.mounted) Navigator.pop(ctx, f);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (photo == null || !mounted) return;

    setState(() => _hasScanned = true);
    _controller.stop();

    // Show processing state
    ref.read(scanReceiptProvider.notifier).startLoading();

    try {
      // Run MLKit text recognition on device
      final inputImage = InputImage.fromFilePath(photo.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognized = await recognizer.processImage(inputImage);
      recognizer.close();

      final extractedText = recognized.text;
      if (extractedText.trim().isEmpty) {
        throw Exception('Nenhum texto encontrado na imagem');
      }

      // Send extracted text to backend for parsing
      final repo = ref.read(receiptRepositoryProvider);
      final receipt = await repo.scanReceiptOcr(extractedText);

      ref.read(scanReceiptProvider.notifier).setSuccess(receipt);
      ref.invalidate(receiptsProvider);

      if (mounted) {
        context.pushReplacement('/receipt/${receipt.id}');
      }
    } catch (e) {
      ref.read(scanReceiptProvider.notifier).setError(e.toString());
      if (mounted) {
        setState(() => _hasScanned = false);
        _controller.start();
      }
    }
  }

  void _showManualUrlDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Digitar link da nota'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://nfce.sefaz...',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isEmpty) return;
              Navigator.pop(ctx);
              setState(() => _hasScanned = true);
              _processScan(url);
            },
            child: const Text('Escanear'),
          ),
        ],
      ),
    );
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

          // Status + mode 2 button
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

                // Mode 2 + Mode 3 buttons
                if (scanState.state != ScanState.loading) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _showManualUrlDialog,
                        icon: const Icon(Icons.keyboard_rounded,
                            color: Colors.white54, size: 16),
                        label: const Text(
                          'Digitar link',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!kIsWeb)
                        TextButton.icon(
                          onPressed: _pickAndScanImage,
                          icon: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white54, size: 16),
                          label: const Text(
                            'Tirar foto',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ],
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
        // Corner accents
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

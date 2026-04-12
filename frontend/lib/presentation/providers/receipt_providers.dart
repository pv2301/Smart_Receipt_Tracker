import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/receipt_repository.dart';
import '../../domain/entities/receipt.dart';

// ---------------------------------------------------------------------------
// receiptsProvider – async list of all receipts (auto-refreshable)
// ---------------------------------------------------------------------------
final receiptsProvider = FutureProvider.autoDispose<List<Receipt>>((ref) async {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.getReceipts();
});

// ---------------------------------------------------------------------------
// receiptByIdProvider – single receipt details
// ---------------------------------------------------------------------------
final receiptByIdProvider =
    FutureProvider.autoDispose.family<Receipt, int>((ref, id) async {
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.getReceiptById(id);
});

// ---------------------------------------------------------------------------
// scanReceiptNotifier – manages the in-flight scan state (Riverpod 3.x)
// ---------------------------------------------------------------------------
enum ScanState { idle, loading, success, error }

class ScanResult {
  final ScanState state;
  final Receipt? receipt;
  final String? errorMessage;

  const ScanResult({
    required this.state,
    this.receipt,
    this.errorMessage,
  });

  const ScanResult.idle() : this(state: ScanState.idle);
}

class ScanReceiptNotifier extends Notifier<ScanResult> {
  @override
  ScanResult build() => const ScanResult.idle();

  Future<void> scan(String qrUrl, {void Function()? onSuccess}) async {
    state = const ScanResult(state: ScanState.loading);
    try {
      final repo = ref.read(receiptRepositoryProvider);
      final receipt = await repo.scanReceipt(qrUrl);
      state = ScanResult(state: ScanState.success, receipt: receipt);
      onSuccess?.call();
    } catch (e) {
      state = ScanResult(
        state: ScanState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const ScanResult.idle();
}

final scanReceiptProvider =
    NotifierProvider.autoDispose<ScanReceiptNotifier, ScanResult>(
  ScanReceiptNotifier.new,
);

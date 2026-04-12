import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/receipt.dart';
import 'api_client.dart';

/// Abstract interface for the receipt data source.
abstract class ReceiptRepository {
  Future<List<Receipt>> getReceipts({int skip = 0, int limit = 100});
  Future<Receipt> getReceiptById(int id);
  Future<Receipt> scanReceipt(String qrUrl);
}

/// Concrete implementation backed by the FastAPI backend.
class ApiReceiptRepository implements ReceiptRepository {
  final Dio _dio;

  ApiReceiptRepository(this._dio);

  @override
  Future<List<Receipt>> getReceipts({int skip = 0, int limit = 100}) async {
    final response = await _dio.get(
      '/receipts/',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Receipt.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Receipt> getReceiptById(int id) async {
    final response = await _dio.get('/receipts/$id');
    return Receipt.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Receipt> scanReceipt(String qrUrl) async {
    final response = await _dio.post(
      '/receipts/scan',
      queryParameters: {'qr_url': qrUrl},
    );
    return Receipt.fromJson(response.data as Map<String, dynamic>);
  }
}

/// Riverpod provider for the repository.
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiReceiptRepository(dio);
});

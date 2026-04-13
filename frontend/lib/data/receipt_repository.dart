import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/receipt.dart';
import '../domain/entities/suggestion.dart';
import '../domain/entities/budget_status.dart';
import 'api_client.dart';

/// Abstract interface for the receipt data source.
abstract class ReceiptRepository {
  Future<List<Receipt>> getReceipts({int skip = 0, int limit = 100});
  Future<Receipt> getReceiptById(int id);
  Future<Receipt> scanReceipt(String qrUrl);
  Future<List<Suggestion>> getSuggestions({List<String>? categories});

  // Budgeting
  Future<BudgetStatus> getBudgetStatus({int? month, int? year});
  Future<void> updateBudgetSettings(double defaultBudget, bool isFixed);
  Future<void> setMonthlyGoal(int month, int year, double amount);

  // Deletion
  Future<void> deleteReceipt(int id);

  // Reporting
  Future<Uint8List> exportReceipts(
      {required String format, int? month, int? year});
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
    return data
        .map((json) => Receipt.fromJson(json as Map<String, dynamic>))
        .toList();
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

  @override
  Future<List<Suggestion>> getSuggestions({List<String>? categories}) async {
    final response = await _dio.get(
      '/suggestions',
      queryParameters: categories != null ? {'categories': categories} : null,
    );
    final List<dynamic> data = response.data;
    return data
        .map((json) => Suggestion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BudgetStatus> getBudgetStatus({int? month, int? year}) async {
    final response = await _dio.get(
      '/budget/status',
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    return BudgetStatus.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateBudgetSettings(double defaultBudget, bool isFixed) async {
    await _dio.put(
      '/budget/settings',
      data: {
        'default_budget': defaultBudget,
        'is_budget_fixed': isFixed,
      },
    );
  }

  @override
  Future<void> setMonthlyGoal(int month, int year, double amount) async {
    await _dio.post(
      '/budget/monthly',
      data: {
        'month': month,
        'year': year,
        'amount': amount,
      },
    );
  }

  @override
  Future<void> deleteReceipt(int id) async {
    await _dio.delete('/receipts/$id');
  }

  @override
  Future<Uint8List> exportReceipts(
      {required String format, int? month, int? year}) async {
    final response = await _dio.get(
      '/receipts/export',
      queryParameters: {
        'format': format,
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data as List<int>);
  }
}

/// Riverpod provider for the repository.
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiReceiptRepository(dio);
});

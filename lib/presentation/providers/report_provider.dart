import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reports.dart';
import '../../domain/usecases/reports/generate_ledger_report_usecase.dart';
import '../../domain/usecases/reports/generate_daybook_report_usecase.dart';
import '../../domain/usecases/reports/generate_profit_loss_report_usecase.dart';
import '../../domain/usecases/reports/generate_balance_sheet_report_usecase.dart';

/// Report state
class ReportState {
  final LedgerReport? ledgerReport;
  final DaybookReport? daybookReport;
  final ProfitLossReport? profitLossReport;
  final BalanceSheetReport? balanceSheetReport;
  final bool isLoading;
  final String? error;
  final String? currentReportType;

  const ReportState({
    this.ledgerReport,
    this.daybookReport,
    this.profitLossReport,
    this.balanceSheetReport,
    this.isLoading = false,
    this.error,
    this.currentReportType,
  });

  ReportState copyWith({
    LedgerReport? ledgerReport,
    DaybookReport? daybookReport,
    ProfitLossReport? profitLossReport,
    BalanceSheetReport? balanceSheetReport,
    bool? isLoading,
    String? error,
    String? currentReportType,
    bool clearError = false,
    bool clearLedger = false,
    bool clearDaybook = false,
    bool clearProfitLoss = false,
    bool clearBalanceSheet = false,
  }) {
    return ReportState(
      ledgerReport: clearLedger ? null : (ledgerReport ?? this.ledgerReport),
      daybookReport: clearDaybook ? null : (daybookReport ?? this.daybookReport),
      profitLossReport: clearProfitLoss ? null : (profitLossReport ?? this.profitLossReport),
      balanceSheetReport: clearBalanceSheet ? null : (balanceSheetReport ?? this.balanceSheetReport),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentReportType: currentReportType ?? this.currentReportType,
    );
  }
}

/// Report provider
class ReportNotifier extends StateNotifier<ReportState> {
  final GenerateLedgerReportUseCase _generateLedgerReportUseCase;
  final GenerateDaybookReportUseCase _generateDaybookReportUseCase;
  final GenerateProfitLossReportUseCase _generateProfitLossReportUseCase;
  final GenerateBalanceSheetReportUseCase _generateBalanceSheetReportUseCase;

  ReportNotifier({
    required GenerateLedgerReportUseCase generateLedgerReportUseCase,
    required GenerateDaybookReportUseCase generateDaybookReportUseCase,
    required GenerateProfitLossReportUseCase generateProfitLossReportUseCase,
    required GenerateBalanceSheetReportUseCase generateBalanceSheetReportUseCase,
  })  : _generateLedgerReportUseCase = generateLedgerReportUseCase,
        _generateDaybookReportUseCase = generateDaybookReportUseCase,
        _generateProfitLossReportUseCase = generateProfitLossReportUseCase,
        _generateBalanceSheetReportUseCase = generateBalanceSheetReportUseCase,
        super(const ReportState());

  /// Generate ledger report
  Future<void> generateLedgerReport({
    required int customerId,
    required int startDate,
    required int endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentReportType: 'LEDGER',
    );

    final params = LedgerReportParams(
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _generateLedgerReportUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) => state = state.copyWith(
        isLoading: false,
        ledgerReport: report,
      ),
    );
  }

  /// Generate daybook report
  Future<void> generateDaybookReport({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentReportType: 'DAYBOOK',
    );

    final params = DaybookReportParams(
      businessId: businessId,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _generateDaybookReportUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) => state = state.copyWith(
        isLoading: false,
        daybookReport: report,
      ),
    );
  }

  /// Generate profit & loss report
  Future<void> generateProfitLossReport({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentReportType: 'PROFIT_LOSS',
    );

    final params = ProfitLossReportParams(
      businessId: businessId,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _generateProfitLossReportUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) => state = state.copyWith(
        isLoading: false,
        profitLossReport: report,
      ),
    );
  }

  /// Generate balance sheet report
  Future<void> generateBalanceSheetReport({
    required int businessId,
    required int asOfDate,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentReportType: 'BALANCE_SHEET',
    );

    final params = BalanceSheetReportParams(
      businessId: businessId,
      asOfDate: asOfDate,
    );

    final result = await _generateBalanceSheetReportUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) => state = state.copyWith(
        isLoading: false,
        balanceSheetReport: report,
      ),
    );
  }

  /// Clear all reports
  void clearAllReports() {
    state = state.copyWith(
      clearLedger: true,
      clearDaybook: true,
      clearProfitLoss: true,
      clearBalanceSheet: true,
      currentReportType: null,
    );
  }

  /// Clear specific report
  void clearLedgerReport() {
    state = state.copyWith(clearLedger: true);
  }

  void clearDaybookReport() {
    state = state.copyWith(clearDaybook: true);
  }

  void clearProfitLossReport() {
    state = state.copyWith(clearProfitLoss: true);
  }

  void clearBalanceSheetReport() {
    state = state.copyWith(clearBalanceSheet: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider instance (to be configured with dependency injection)
final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  throw UnimplementedError('reportProvider must be overridden with proper dependencies');
});

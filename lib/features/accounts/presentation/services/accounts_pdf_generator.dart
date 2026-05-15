// lib/features/accounts/presentation/services/accounts_pdf_generator.dart

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../payments/domain/entities/transaction_entity.dart';
import '../../domain/entities/accounts_filter.dart';
import '../../domain/entities/accounts_item.dart';
import '../../domain/entities/pdf_transaction_row.dart';

class AccountsPdfGenerator {
  AccountsPdfGenerator({
    required this.txRows,
    required this.overdueClients,
    required this.summary,
    required this.filter,
    required this.locale,
    required this.cairoFont,
    required this.l10n,
  });

  final List<PdfTransactionRow> txRows;
  final List<OverdueClientInfo> overdueClients;
  final AccountsSummary summary;
  final AccountsFilter filter;
  final String locale;
  final pw.Font cairoFont;
  final AppLocalizations l10n;

  static const _headerBg = PdfColor.fromInt(0xFF1565C0);
  static const _footerBg = PdfColor.fromInt(0xFFE3F2FD);
  static const _overdueBg = PdfColor.fromInt(0xFFFFEBEE);
  static const _overdueHeaderBg = PdfColor.fromInt(0xFFC62828);
  static const _altRow = PdfColor.fromInt(0xFFF5F5F5);
  static const _white = PdfColors.white;
  static const _black = PdfColors.black;
  static const _grey = PdfColor.fromInt(0xFF757575);
  static const _border = PdfColor.fromInt(0xFFBDBDBD);

  pw.Document generate() {
    final doc = pw.Document();

    final base = pw.TextStyle(font: cairoFont, fontSize: 10, color: _black);
    final bold = pw.TextStyle(font: cairoFont, fontSize: 10, fontWeight: pw.FontWeight.bold, color: _black);
    final colHeader = pw.TextStyle(font: cairoFont, fontSize: 10, fontWeight: pw.FontWeight.bold, color: _white);
    final title = pw.TextStyle(font: cairoFont, fontSize: 16, fontWeight: pw.FontWeight.bold, color: _black);
    final section = pw.TextStyle(font: cairoFont, fontSize: 12, fontWeight: pw.FontWeight.bold, color: _white);
    final small = pw.TextStyle(font: cairoFont, fontSize: 9, color: _grey);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          _header(title, small, bold),
          pw.SizedBox(height: 16),
          _transactionsSection(section, colHeader, base, bold),
          pw.SizedBox(height: 8),
          _summaryBar(base, bold),
          pw.SizedBox(height: 20),
          if (overdueClients.isNotEmpty)
            _overdueSection(section, colHeader, base, bold),
        ],
      ),
    );

    return doc;
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  pw.Widget _header(pw.TextStyle title, pw.TextStyle small, pw.TextStyle bold) {
    final dateStr = DateFormat('yyyy/MM/dd', 'en').format(DateTime.now());
    final period = _periodLabel();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _footerBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(l10n.accountsReportTitle, style: title, textDirection: pw.TextDirection.rtl),
              pw.SizedBox(height: 4),
              pw.Text('${l10n.accountsReportPeriod}: $period', style: bold, textDirection: pw.TextDirection.rtl),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${l10n.accountsReportGenerated}:', style: small, textDirection: pw.TextDirection.rtl),
              pw.Text(dateStr, style: small),
            ],
          ),
        ],
      ),
    );
  }

  // ── Transactions table (from transactions collection) ────────────────────────

  pw.Widget _transactionsSection(
    pw.TextStyle section,
    pw.TextStyle colHeader,
    pw.TextStyle base,
    pw.TextStyle bold,
  ) {
    const widths = <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(2), // المبلغ
      1: pw.FlexColumnWidth(2), // الحالة
      2: pw.FlexColumnWidth(2), // تاريخ الدفع
      3: pw.FlexColumnWidth(2), // النوع
      4: pw.FlexColumnWidth(3), // اسم السجل
      5: pw.FlexColumnWidth(3), // اسم العميل
    };

    final headerLabels = [
      l10n.accountsPdfColAmount,
      l10n.accountsPdfColStatus,
      l10n.accountsPdfColDueDate,
      l10n.accountsPdfColType,
      l10n.accountsPdfColItemName,
      l10n.accountsPdfColClient,
    ];

    final rows = <pw.TableRow>[_headerRow(headerLabels, colHeader, _headerBg)];

    for (var i = 0; i < txRows.length; i++) {
      final tx = txRows[i];
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: i.isOdd ? _altRow : _white),
        children: [
          _cell(CurrencyUtils.formatCurrency(tx.amount, locale), base),
          _cell(_statusLabel(tx.status), base),
          _cell(_fmtDate(tx.paidDate), base),
          _cell(_relatedTypeLabel(tx.relatedType), base),
          _cell(tx.itemName, base),
          _cell(tx.clientName, base),
        ],
      ));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader('المعاملات', section, _headerBg),
        if (txRows.isEmpty)
          _emptyRow(l10n.accountsEmpty, base)
        else
          pw.Table(
            border: pw.TableBorder.all(color: _border, width: 0.5),
            columnWidths: widths,
            children: rows,
          ),
      ],
    );
  }

  // ── Summary bar ─────────────────────────────────────────────────────────────

  pw.Widget _summaryBar(pw.TextStyle base, pw.TextStyle bold) {
    final total = txRows.fold<double>(0, (s, tx) => s + tx.amount);
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _footerBg,
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(l10n.accountsPdfTotalCollected, CurrencyUtils.formatCurrency(summary.totalCollected, locale), base, bold),
          _summaryItem(l10n.accountsPdfTotalProfits, CurrencyUtils.formatCurrency(summary.totalProfits, locale), base, bold),
          _summaryItem(l10n.accountsPdfOperationsCount, summary.operationsCount.toString(), base, bold),
          _summaryItem('الإجمالي', CurrencyUtils.formatCurrency(total, locale), base, bold),
        ],
      ),
    );
  }

  pw.Widget _summaryItem(String label, String value, pw.TextStyle base, pw.TextStyle bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: base, textDirection: pw.TextDirection.rtl),
        pw.SizedBox(height: 2),
        pw.Text(value, style: bold),
      ],
    );
  }

  // ── Overdue clients table ────────────────────────────────────────────────────

  pw.Widget _overdueSection(
    pw.TextStyle section,
    pw.TextStyle colHeader,
    pw.TextStyle base,
    pw.TextStyle bold,
  ) {
    const widths = <int, pw.TableColumnWidth>{
      0: pw.FlexColumnWidth(2), // المبلغ
      1: pw.FlexColumnWidth(3), // اسم الدين
      2: pw.FlexColumnWidth(2), // رقم الهاتف
      3: pw.FlexColumnWidth(3), // اسم العميل
    };

    final headerLabels = [
      l10n.accountsPdfColAmount,
      l10n.accountsPdfColItemName,
      l10n.accountsPdfColPhone,
      l10n.accountsPdfColClient,
    ];

    final rows = <pw.TableRow>[_headerRow(headerLabels, colHeader, _overdueHeaderBg)];

    double totalOverdue = 0;
    var rowIdx = 0;

    for (final info in overdueClients) {
      final name = info.client.fullName;
      final phone = info.client.phone;
      // For simplicity, show one summary row per overdue client using
      // the totals stored in OverdueClientInfo (no separate item-level breakdown
      // needed here since the transactions table already showed the details).
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: rowIdx.isOdd ? _altRow : _white),
        children: [
          _cell(CurrencyUtils.formatCurrency(info.totalOverdueAmount, locale), base),
          _cell(l10n.accountsPdfOverdueSummaryItem(info.overdueItemsCount), base),
          _cell(phone, base),
          _cell(name, base),
        ],
      ));
      totalOverdue += info.totalOverdueAmount;
      rowIdx++;
    }

    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: _overdueBg),
      children: [
        _cell(CurrencyUtils.formatCurrency(totalOverdue, locale), bold),
        _cell(l10n.accountsPdfTotalOverdue, bold),
        _cell('', bold),
        _cell('', bold),
      ],
    ));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(l10n.accountsOverdueClientsTitle, section, _overdueHeaderBg),
        pw.Table(
          border: pw.TableBorder.all(color: _border, width: 0.5),
          columnWidths: widths,
          children: rows,
        ),
      ],
    );
  }

  // ── Shared helpers ───────────────────────────────────────────────────────────

  pw.Widget _sectionHeader(String text, pw.TextStyle style, PdfColor bg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(color: bg),
      child: pw.Text(text, style: style, textDirection: pw.TextDirection.rtl),
    );
  }

  pw.Widget _emptyRow(String text, pw.TextStyle style) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(color: _white),
      child: pw.Center(
        child: pw.Text(text, style: style, textDirection: pw.TextDirection.rtl),
      ),
    );
  }

  pw.TableRow _headerRow(List<String> labels, pw.TextStyle style, PdfColor bg) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: labels.map((l) => _cell(l, style)).toList(),
    );
  }

  /// Table cell — NO pw.Expanded; column widths live on pw.Table.columnWidths.
  pw.Widget _cell(String text, pw.TextStyle style) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        style: style,
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  String _relatedTypeLabel(RelatedType type) => switch (type) {
        RelatedType.installmentPayment => l10n.accountsPdfTypeInstallment,
        RelatedType.gracePeriod => l10n.accountsPdfTypeGracePeriod,
        RelatedType.officeCommission => 'عمولة مكتب',
      };

  String _statusLabel(TransactionStatus status) => switch (status) {
        TransactionStatus.completed => l10n.accountsPdfStatusPaid,
        TransactionStatus.reversed => l10n.accountsPdfStatusReversed,
      };

  String _periodLabel() {
    final from = filter.fromMonth;
    final to = filter.toMonth;
    if (from == null && to == null) return l10n.accountsReportAllPeriods;
    final fromStr = from != null ? _fmtMonth(from) : '...';
    final toStr = to != null ? _fmtMonth(to) : '...';
    return '$fromStr – $toStr';
  }

  String _fmtDate(DateTime d) => DateFormat('yyyy/MM/dd', 'en').format(d);

  String _fmtMonth(DateTime d) =>
      DateFormat('MMM yyyy', locale == 'ar' ? 'ar' : 'en').format(d);
}

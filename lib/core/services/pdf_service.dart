import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import 'dart:typed_data';

class PdfService {
  PdfService._();
  static final _instance = PdfService._();
  factory PdfService() => _instance;

  // ── Colour palette ───────────────────────────────────────────
  static const _navy    = PdfColor.fromInt(0xFF0F3460);
  static const _blue    = PdfColor.fromInt(0xFF1A56A0);
  static const _blueL   = PdfColor.fromInt(0xFF2E75B6);
  static const _green   = PdfColor.fromInt(0xFF1A7A4A);
  static const _red     = PdfColor.fromInt(0xFFB22222);
  static const _gray    = PdfColor.fromInt(0xFF555555);
  static const _lightBg = PdfColor.fromInt(0xFFEEF4FB);
  static const _divider = PdfColor.fromInt(0xFFE0E6EF);
  static const _dark    = PdfColor.fromInt(0xFF1A1A1A);
  static const _white   = PdfColors.white;

  Future<void> generateMonthlyReport({
    required BuildContext       context,
    required DateTime           month,
    required List<TransactionModel> transactions,
    required List<CategoryModel>    categories,
    required List<AccountModel>     accounts,
    required double                 totalIncome,
    required double                 totalExpense,
    required Map<String, double>    expenseByCategory,
  }) async {
    final pdf = pw.Document(
      title: 'HishabKitab Report — '
          '${DateFormat('MMMM yyyy').format(month)}',
      author:  'HishabKitab',
      creator: 'HishabKitab App',
    );

    final font = await PdfGoogleFonts.nunitoRegular();
    final bold = await PdfGoogleFonts.nunitoBold();
    final extB = await PdfGoogleFonts.nunitoExtraBold();

    final monthLabel = DateFormat('MMMM yyyy').format(month);
    final balance    = totalIncome - totalExpense;

    // Sort transactions newest first
    final sortedTx = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Category breakdown for top 5
    final catData = expenseByCategory.entries
        .map((e) {
      final cat = categories.cast<CategoryModel?>()
          .firstWhere((c) => c?.id == e.key,
          orElse: () => null);
      return _CatRow(cat?.name ?? 'Other', e.value,
          totalExpense == 0 ? 0 : e.value / totalExpense);
    })
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:     const pw.EdgeInsets.all(36),
        build: (context) => [

          // ── Header ─────────────────────────────────────────
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [_navy, _blue, _blueL],
                begin:  pw.Alignment.topLeft,
                end:    pw.Alignment.bottomRight,
              ),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            padding: const pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('HishabKitab',
                          style: pw.TextStyle(
                            font:      extB,
                            fontSize:  26,
                            color:     _white,
                          ),
                        ),
                        pw.Text('আপনার টাকার হিসাব',
                          style: pw.TextStyle(
                            font:    font,
                            fontSize: 11,
                            color:   PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Monthly Report',
                          style: pw.TextStyle(
                            font:     bold,
                            fontSize: 14,
                            color:    _white,
                          ),
                        ),
                        pw.Text(monthLabel,
                          style: pw.TextStyle(
                            font:     font,
                            fontSize: 12,
                            color:    PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(
                            font:    font,
                            fontSize: 9,
                            color:   PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.white, thickness: 0.5),
                pw.SizedBox(height: 16),
                // Summary row
                pw.Row(
                  mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _headerStat(font, bold, 'Total Income',
                        _fmt(totalIncome), PdfColors.greenAccent),
                    _headerStat(font, bold, 'Total Expense',
                        _fmt(totalExpense), PdfColors.red200),
                    _headerStat(font, bold, 'Net Balance',
                        _fmt(balance.abs()),
                        balance >= 0
                            ? PdfColors.greenAccent
                            : PdfColors.red200),
                    _headerStat(font, bold, 'Transactions',
                        '${transactions.length}', PdfColors.lightBlueAccent),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── Account Balances ───────────────────────────────
          _sectionTitle(bold, 'Account Balances'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: _divider, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: _blue),
                children: [
                  _th(bold, 'Account'),
                  _th(bold, 'Type'),
                  _th(bold, 'Balance', align: pw.TextAlign.right),
                ],
              ),
              ...accounts.map((acc) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: accounts.indexOf(acc).isEven
                      ? _lightBg : _white,
                ),
                children: [
                  _td(font, acc.name),
                  _td(font, _accountTypeName(acc.type)),
                  _td(font, _fmt(acc.balance),
                      align: pw.TextAlign.right,
                      color: acc.balance >= 0 ? _green : _red),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Expense by Category ────────────────────────────
          if (catData.isNotEmpty) ...[
            _sectionTitle(bold, 'Expense Breakdown by Category'),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  color: _divider, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(3),
              },
              children: [
                pw.TableRow(
                  decoration:
                  const pw.BoxDecoration(color: _blue),
                  children: [
                    _th(bold, 'Category'),
                    _th(bold, 'Amount', align: pw.TextAlign.right),
                    _th(bold, 'Share',  align: pw.TextAlign.right),
                    _th(bold, 'Bar'),
                  ],
                ),
                ...catData.take(8).map((row) {
                  final idx = catData.indexOf(row);
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: idx.isEven ? _lightBg : _white,
                    ),
                    children: [
                      _td(font, row.name),
                      _td(font, _fmt(row.amount),
                          align: pw.TextAlign.right,
                          color: _red),
                      _td(font,
                          '${(row.percent * 100).toStringAsFixed(1)}%',
                          align: pw.TextAlign.right,
                          color: _gray),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Stack(
                          children: [
                            pw.Container(
                              height: 8,
                              decoration: pw.BoxDecoration(
                                color: _divider,
                                borderRadius:
                                pw.BorderRadius.circular(4),
                              ),
                            ),
                            pw.Container(
                              height: 8,
                              width: 80 * row.percent,
                              decoration: pw.BoxDecoration(
                                color: _blue,
                                borderRadius:
                                pw.BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // ── Transaction History ────────────────────────────
          _sectionTitle(bold, 'Transaction History'),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
                color: _divider, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration:
                const pw.BoxDecoration(color: _blue),
                children: [
                  _th(bold, 'Date'),
                  _th(bold, 'Title'),
                  _th(bold, 'Category'),
                  _th(bold, 'Account'),
                  _th(bold, 'Amount',
                      align: pw.TextAlign.right),
                ],
              ),
              ...sortedTx.take(50).map((tx) {
                final cat = categories.cast<CategoryModel?>()
                    .firstWhere((c) => c?.id == tx.categoryId,
                    orElse: () => null);
                final acc = accounts.cast<AccountModel?>()
                    .firstWhere((a) => a?.id == tx.accountId,
                    orElse: () => null);
                final idx = sortedTx.indexOf(tx);
                final amtColor = tx.isIncome ? _green : _red;
                final amtText  = '${tx.isIncome ? '+' : '-'}'
                    '${_fmt(tx.amount)}';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: idx.isEven ? _lightBg : _white,
                  ),
                  children: [
                    _td(font, DateFormat('dd/MM').format(tx.date),
                        color: _gray),
                    _td(font, tx.title),
                    _td(font, cat?.name ?? '—',
                        color: _gray),
                    _td(font, acc?.name ?? '—',
                        color: _gray),
                    _td(font, amtText,
                        align: pw.TextAlign.right,
                        color: amtColor),
                  ],
                );
              }),
              if (sortedTx.length > 50)
                pw.TableRow(
                  decoration:
                  const pw.BoxDecoration(color: _lightBg),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '... and ${sortedTx.length - 50} more transactions',
                        style: pw.TextStyle(
                            font: font, fontSize: 9,
                            color: _gray),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Footer ─────────────────────────────────────────
          pw.Divider(color: _divider, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generated by HishabKitab',
                  style: pw.TextStyle(
                      font: font, fontSize: 9, color: _gray)),
              pw.Text(
                'Balance: ${balance >= 0 ? "+" : "-"}${_fmt(balance.abs())}',
                style: pw.TextStyle(
                    font: bold, fontSize: 9,
                    color: balance >= 0 ? _green : _red),
              ),
            ],
          ),
        ],
      ),
    );

    // Save + share
    final dir  = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/HishabKitab_${DateFormat('MMM_yyyy').format(month)}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'HishabKitab Report — $monthLabel',
      text:    'My financial report for $monthLabel',
    );
  }

  // ── Preview in viewer ────────────────────────────────────────
  Future<void> previewReport({
    required BuildContext           context,
    required DateTime               month,
    required List<TransactionModel> transactions,
    required List<CategoryModel>    categories,
    required List<AccountModel>     accounts,
    required double                 totalIncome,
    required double                 totalExpense,
    required Map<String, double>    expenseByCategory,
  }) async {
    await Printing.layoutPdf(
      onLayout: (_) async {
        final tmpFile = await _buildPdfBytes(
          month:             month,
          transactions:      transactions,
          categories:        categories,
          accounts:          accounts,
          totalIncome:       totalIncome,
          totalExpense:      totalExpense,
          expenseByCategory: expenseByCategory,
        );
        return tmpFile;
      },
      name: 'HishabKitab_${DateFormat('MMM_yyyy').format(month)}',
    );
  }

  Future<Uint8List> _buildPdfBytes({
    required DateTime               month,
    required List<TransactionModel> transactions,
    required List<CategoryModel>    categories,
    required List<AccountModel>     accounts,
    required double                 totalIncome,
    required double                 totalExpense,
    required Map<String, double>    expenseByCategory,
  }) async {
    // Reuse main generation logic but return bytes
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final bold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(pw.Page(
      build: (_) => pw.Center(
        child: pw.Text('Loading...',
            style: pw.TextStyle(font: bold)),
      ),
    ));
    final bytes = await pdf.save();
    return Uint8List.fromList(bytes);
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _fmt(double amount) {
    final f = NumberFormat('#,##,##0.00', 'en_IN');
    return '৳${f.format(amount)}';
  }

  String _accountTypeName(AccountType type) {
    switch (type) {
      case AccountType.cash:  return 'Cash';
      case AccountType.bkash: return 'bKash';
      case AccountType.nagad: return 'Nagad';
      case AccountType.bank:  return 'Bank';
    }
  }

  pw.Widget _headerStat(pw.Font font, pw.Font bold,
      String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: font, fontSize: 10,
                color: PdfColors.white)),
        pw.SizedBox(height: 2),
        pw.Text(value,
            style: pw.TextStyle(
                font: bold, fontSize: 14, color: color)),
      ],
    );
  }

  pw.Widget _sectionTitle(pw.Font bold, String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: pw.BorderRadius.circular(6),
        border: const pw.Border(
            left: pw.BorderSide(color: _blue, width: 3)),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              font: bold, fontSize: 13, color: _dark)),
    );
  }

  pw.Widget _th(pw.Font bold, String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 8, vertical: 7),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: bold, fontSize: 9, color: _white),
          textAlign: align),
    );
  }

  pw.Widget _td(pw.Font font, String text, {
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor color = _dark,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 8, vertical: 6),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: font, fontSize: 8.5, color: color),
          textAlign: align),
    );
  }
}

class _CatRow {
  final String name;
  final double amount;
  final double percent;
  const _CatRow(this.name, this.amount, this.percent);
}
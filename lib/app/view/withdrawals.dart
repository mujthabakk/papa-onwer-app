import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/withdrawal_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/withdrawal_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// Add these imports to the top of your withdrawals_screen.dart file
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({Key? key}) : super(key: key);
  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Date filtering variables
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFiltering = false;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawalsController>(builder: (value) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildModernAppBar(),
        body: value.isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (_isFiltering &&
                        _startDate != null &&
                        _endDate != null) {
                      await value.getWithdrawalHistoryByIdDate(
                          DateFormat('yyyy-MM-dd').format(_startDate!),
                          DateFormat('yyyy-MM-dd').format(_endDate!));
                    } else {
                      await value.getWithdrawalHistoryById();
                    }
                  },
                  color: const Color(0xFF6366F1),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildBalanceCard(
                              value.totalAmount,
                              value.codCommission,
                              value.codCommissionPercentage),
                          const SizedBox(height: 24),
                          _buildWithdrawButton(
                              context, value, value.totalAmount),
                          const SizedBox(height: 32),
                          _buildHistoryHeader(value),
                          const SizedBox(height: 16),
                          _buildDateFilterCard(value),
                          const SizedBox(height: 16),
                          _buildHistoryList(
                              value.withdrawalRequests.reversed.toList()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      );
    });
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Color.fromARGB(255, 33, 33, 33),
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Withdrawals'.tr,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFFE2E8F0),
                Colors.transparent
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text('Loading your wallet...'.tr,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(WithdrawalsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text('Withdrawal History'.tr,
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (controller.withdrawalRequests.isNotEmpty)
          _buildExportButton(controller),
      ],
    );
  }

  // Replace the _buildExportButton() method in Part 1 with this:
  Widget _buildExportButton(WithdrawalsController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 82, 82, 82),
            Color.fromARGB(255, 34, 34, 34)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 63, 63, 63).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _generatePDFReport(controller),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Export PDF'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Add this method to your _WithdrawalsScreenState class (replace the _showComingSoonDialog method):
  Future<void> _generatePDFReport(WithdrawalsController controller) async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                  const SizedBox(height: 16),
                  Text('Generating PDF Report...'.tr),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final pdf = pw.Document();

      // Calculate totals
      final requests = controller.withdrawalRequests;
      final totalRequested =
          requests.fold<double>(0, (sum, item) => sum + item.amount.toDouble());
      final totalReceived = requests.fold<double>(
          0,
          (sum, item) =>
              sum + (item.amount.toDouble() - (item.amount.toDouble() * 0.05)));
      final totalFees = requests.fold<double>(
          0, (sum, item) => sum + (item.amount.toDouble() * 0.05));

      final header = await _buildPDFHeader(); // 👈 preload async widget

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header Section
              header,
              pw.SizedBox(height: 30),

              // Summary Section
              _buildPDFSummary(
                  controller.totalAmount,
                  controller.codCommission,
                  controller.codCommissionPercentage,
                  totalRequested,
                  totalReceived,
                  totalFees),
              pw.SizedBox(height: 30),

              // Filter Info
              if (_isFiltering && _startDate != null && _endDate != null)
                _buildPDFFilterInfo(),

              // Withdrawal Details Header
              pw.Text(
                'Withdrawal Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo,
                ),
              ),
              pw.SizedBox(height: 15),

              // Table
              _buildPDFTable(requests),

              pw.SizedBox(height: 30),

              // Footer
              _buildPDFFooter(),
            ];
          },
        ),
      );

      // Close loading dialog
      Get.back();

      // Show PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'withdrawal_history_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      _showErrorToast('Failed to generate PDF: ${e.toString()}');
    }
  }

// PDF Helper Methods - Add these to your class:
  Future<pw.Widget> _buildPDFHeader() async {
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/papa_logo_black.png'))
          .buffer
          .asUint8List(),
    );
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.indigo, PdfColors.purple],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PapaBear Withdrawal History',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Professional Financial Report',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Image(image, width: 62, height: 62),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.white),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // pw.Widget _buildPDFSummary(num totalAmount, num codCommission,
  //     double totalRequested, double totalReceived, double totalFees) {
  //   final num totalBalance = totalAmount + codCommission;

  //   return pw.Container(
  //     child: pw.Column(
  //       crossAxisAlignment: pw.CrossAxisAlignment.start,
  //       children: [
  //         pw.Text(
  //           'Account Summary',
  //           style: pw.TextStyle(
  //             fontSize: 18,
  //             fontWeight: pw.FontWeight.bold,
  //             color: PdfColors.indigo,
  //           ),
  //         ),
  //         pw.SizedBox(height: 15),

  //         // Current Balance Card
  //         pw.Container(
  //           padding: const pw.EdgeInsets.all(16),
  //           decoration: pw.BoxDecoration(
  //             color: PdfColors.grey100,
  //             borderRadius: pw.BorderRadius.circular(8),
  //             border: pw.Border.all(color: PdfColors.grey300),
  //           ),
  //           child: pw.Column(
  //             children: [
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('Current Wallet Balance:',
  //                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  //                   pw.Text('INR ${totalBalance.toStringAsFixed(2)}',
  //                       style: pw.TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: pw.FontWeight.bold,
  //                           color: PdfColors.indigo)),
  //                 ],
  //               ),
  //               pw.SizedBox(height: 8),
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('Available for Withdrawal:'.tr),
  //                   pw.Text('INR ${totalAmount.toStringAsFixed(2)}'),
  //                 ],
  //               ),
  //               pw.Row(
  //                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   pw.Text('COD Commission (5%):'),
  //                   pw.Text('INR ${codCommission.toStringAsFixed(2)}'),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),

  //         pw.SizedBox(height: 20),

  //         // Transaction Summary
  //         pw.Row(
  //           children: [
  //             pw.Expanded(
  //               child: _buildSummaryCard('Total Requested',
  //                   'INR ${totalRequested.toStringAsFixed(2)}', PdfColors.blue),
  //             ),
  //             pw.SizedBox(width: 15),
  //             pw.Expanded(
  //               child: _buildSummaryCard('Total Received',
  //                   'INR ${totalReceived.toStringAsFixed(2)}', PdfColors.green),
  //             ),
  //             pw.SizedBox(width: 15),
  //             pw.Expanded(
  //               child: _buildSummaryCard('Total Fees',
  //                   'INR ${totalFees.toStringAsFixed(2)}', PdfColors.red),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  pw.Widget _buildPDFSummary(
      num totalAmount,
      num codCommission,
      num codCommissionPercentage,
      double totalRequested,
      double totalReceived,
      double totalFees) {
    final num totalWalletBalance =
        totalAmount + codCommission; // Total = totalAmount + COD Commission
    final num availableBalance = totalWalletBalance -
        codCommission; // Available = Total - COD Commission = totalAmount

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Account Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo,
            ),
          ),
          pw.SizedBox(height: 15),

          // Current Balance Card
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              children: [
                // Total Wallet Balance
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Wallet Balance:'.tr,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR ${totalWalletBalance.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo)),
                  ],
                ),
                pw.SizedBox(height: 8),

                // COD Commission (Deducted)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        'COD Commission (${_formatPercentage(codCommissionPercentage)}% Deducted):'),
                    pw.Text('- INR ${codCommission.toStringAsFixed(2)}',
                        style: pw.TextStyle(color: PdfColors.red)),
                  ],
                ),
                pw.SizedBox(height: 8),

                // Divider
                pw.Container(
                  height: 1,
                  color: PdfColors.grey400,
                  margin: const pw.EdgeInsets.symmetric(vertical: 4),
                ),

                // Available for Withdrawal
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Available for Withdrawal:'.tr,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('INR ${availableBalance.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                  ],
                ),

                pw.SizedBox(height: 12),

                // Calculation explanation
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Available: ${totalWalletBalance.toStringAsFixed(2)} - ${codCommission.toStringAsFixed(2)} = ${availableBalance.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.blue800,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Transaction Summary Header
          pw.Text(
            'Withdrawal Transaction Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.indigo,
            ),
          ),
          pw.SizedBox(height: 10),

          // Transaction Summary Cards
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryCard('Total Requested',
                    'INR ${totalRequested.toStringAsFixed(2)}', PdfColors.blue),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: _buildSummaryCard('Platform Fees',
                    'INR ${totalFees.toStringAsFixed(2)}', PdfColors.red),
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: _buildSummaryCard('Total Received',
                    'INR ${totalReceived.toStringAsFixed(2)}', PdfColors.green),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // Additional Information Box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.amber200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 4,
                      height: 16,
                      color: PdfColors.amber600,
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'Important Information',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber800,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '1. COD Commission (${_formatPercentage(codCommissionPercentage)}%) is automatically deducted from total wallet balance',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.amber800),
                ),
                pw.Text(
                  '2. Only the available balance (after commission deduction) can be withdrawn',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.amber800),
                ),
                pw.Text(
                  '3. Additional 10% platform fee is charged on each withdrawal request',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.amber800),
                ),
                pw.Text(
                  '4. Minimum withdrawal amount is ₹ INR 500',
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.amber800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCard(String title, String amount, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFFilterInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Row(
        children: [
          pw.Icon(pw.IconData(0xe88f),
              color: PdfColors.blue, size: 16), // info icon
          pw.SizedBox(width: 8),
          pw.Text(
            'Filtered Period: ${_dateFormatter.format(_startDate!)} to ${_dateFormatter.format(_endDate!)}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.blue800,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFTable(List<Withdrawal> requests) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.indigo),
          children: [
            _buildTableCell('ID', isHeader: true),
            _buildTableCell('Date', isHeader: true),
            _buildTableCell('Requested Amount', isHeader: true),
            _buildTableCell('Fee (5%)', isHeader: true),
            _buildTableCell('Amount Received', isHeader: true),
            _buildTableCell('Status', isHeader: true),
          ],
        ),
        // Data rows
        ...requests.map((request) {
          final fee = request.amount.toDouble() * 0.05;
          final received = request.amount.toDouble() - fee;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: requests.indexOf(request) % 2 == 0
                  ? PdfColors.grey50
                  : PdfColors.white,
            ),
            children: [
              _buildTableCell(request.id.toString()),
              _buildTableCell(request.withdrawalDate),
              _buildTableCell('INR ${request.amount.toStringAsFixed(2)}'),
              _buildTableCell('INR ${fee.toStringAsFixed(2)}'),
              _buildTableCell('INR ${received.toStringAsFixed(2)}'),
              _buildTableCell(request.status),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Important Notes:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('1. Platform fee of 5% is applied to all withdrawals'.tr,
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('2. Minimum withdrawal amount is INR 500'.tr,
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('3. Processing time may vary based on payment method'.tr,
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Support Contact:',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Email: Support@papabear4u.com',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Phone: +91-9562121333',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Office: 0484-2990847',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Website: www.papabear4u.com',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Center(
            child: pw.Text(
              'This is a computer-generated report. No signature required.',
              style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterCard(WithdrawalsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text('Filter by Date Range'.tr,
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'Start Date',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  'End Date',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _isFiltering = false;
                    });
                    await controller.getWithdrawalHistoryById();
                  },
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  label: Text('Clear Filter'.tr),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    foregroundColor: const Color(0xFF64748B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_startDate != null && _endDate != null)
                      ? () async {
                          if (_endDate!.isBefore(_startDate!)) {
                            _showErrorToast(
                                'End date cannot be before start date');
                            return;
                          }
                          setState(() => _isFiltering = true);
                          await controller.getWithdrawalHistoryByIdDate(
                              DateFormat('yyyy-MM-dd').format(_startDate!),
                              DateFormat('yyyy-MM-dd').format(_endDate!));
                        }
                      : null,
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: Text('Apply Filter'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          if (_isFiltering && _startDate != null && _endDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded,
                      color: Color(0xFF6366F1), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing results from ${_dateFormatter.format(_startDate!)} to ${_dateFormatter.format(_endDate!)}',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF6366F1),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: selectedDate != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF64748B),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _dateFormatter.format(selectedDate)
                        : 'Select date',
                    style: TextStyle(
                      color: selectedDate != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text("PDF Export".tr,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text("PDF export functionality will be available in the next update. This feature will allow you to download and share your withdrawal history as a professional PDF report.".tr),
          actions: <Widget>[
            TextButton(
              child: Text("Got it".tr),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFFEF4444),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color(0xFF10B981),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Widget _buildBalanceCard(num amount, num cod) {
  //   num totalBalance = amount + cod;

  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Color.fromARGB(255, 59, 59, 59),
  //           Color.fromARGB(255, 40, 40, 40),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF6366F1).withOpacity(0.3),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(24.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Wallet Balance',
  //                 style: TextStyle(
  //                   color: Colors.white70,
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.2),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: const Icon(
  //                   Icons.account_balance_wallet_rounded,
  //                   color: Colors.white,
  //                   size: 24,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             '₹${totalBalance.toStringAsFixed(2)}',
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 28,
  //               fontWeight: FontWeight.w800,
  //               letterSpacing: -1,
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.white.withOpacity(0.2)),
  //             ),
  //             child: Column(
  //               children: [
  //                 _buildBalanceRow('Available for Withdrawal',
  //                     '₹${amount.toStringAsFixed(2)}', true),
  //                 const SizedBox(height: 12),
  //                 _buildBalanceRow('COD Commission (5%)',
  //                     '₹${cod.toStringAsFixed(2)}', false),
  //                 const SizedBox(height: 12),
  //                 Container(
  //                   height: 1,
  //                   color: Colors.white.withOpacity(0.2),
  //                 ),
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   'Calculation: ₹${totalBalance.toStringAsFixed(2)} - ₹${cod.toStringAsFixed(2)}',
  //                   style: TextStyle(
  //                     color: Colors.white.withOpacity(0.7),
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildBalanceCard(num amount, num cod, num codCommissionPercentage) {
    // amount = totalAmount from API
    // cod = COD commission
    // Total wallet balance = amount + cod
    // Available for withdrawal = (amount + cod) - cod = amount
    num totalWalletBalance =
        amount + cod; // Total = API amount + COD Commission
    num availableForWithdrawal =
        totalWalletBalance - cod; // Available = Total - COD Commission

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 59, 59, 59),
            Color.fromARGB(255, 40, 40, 40),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wallet Balance'.tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '₹${totalWalletBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildBalanceRow('Available for Withdrawal',
                      '₹${availableForWithdrawal.toStringAsFixed(2)}', true),
                  const SizedBox(height: 12),
                  _buildBalanceRow(
                      'COD Commission (${_formatPercentage(codCommissionPercentage)}% Deducted)',
                      '₹${cod.toStringAsFixed(2)}',
                      false),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Available: ₹${totalWalletBalance.toStringAsFixed(2)} - ₹${cod.toStringAsFixed(2)} = ₹${availableForWithdrawal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPercentage(num percentage) {
    return percentage % 1 == 0
        ? percentage.toStringAsFixed(0)
        : percentage.toStringAsFixed(2);
  }

  Widget _buildBalanceRow(String label, String amount, bool isMain) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isMain ? 16 : 14,
            fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMain ? 18 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // Widget _buildWithdrawButton(
  //     BuildContext context, WithdrawalsController controller, num balance) {
  //   return Container(
  //     width: double.infinity,
  //     height: 56,
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [Color(0xFF10B981), Color(0xFF059669)],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF10B981).withOpacity(0.3),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: ElevatedButton(
  //       onPressed: () => _showWithdrawDialog(context, controller, balance),
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.transparent,
  //         foregroundColor: Colors.white,
  //         shadowColor: Colors.transparent,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: const [
  //           Icon(Icons.send_rounded, size: 20),
  //           SizedBox(width: 8),
  //           Text(
  //             'Withdraw Funds',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.w600,
  //               letterSpacing: 0.5,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWithdrawButton(
      BuildContext context, WithdrawalsController controller, num balance) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showWithdrawDialog(
            context, controller, balance), // This will pass totalAmount
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 20),
            SizedBox(width: 8),
            Text('Withdraw Funds'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<Withdrawal> requests) {
    if (requests.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 48,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text('No withdrawal history'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isFiltering
                    ? 'No withdrawals found for the selected date range'
                    : 'Your withdrawal requests will appear here',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(request.status),
                    Text(
                      'ID: ${request.id}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Requested Amount'.tr,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${request.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('You Received'.tr,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${(request.amount - (request.amount * 0.05)).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Platform Fee (5%): ₹${(request.amount * 0.05).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        request.withdrawalDate,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        icon = Icons.schedule_rounded;
        break;
      default:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.error_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

//   void _showWithdrawDialog(
//       BuildContext context, WithdrawalsController controller, num balance) {
//     TextEditingController amountController = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         double commission = 0;
//         double finalAmount = 0;
//         bool isAmountValid = true;
//         String helperText = "Minimum withdrawal amount\nis ₹500";

//         return Dialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 30,
//                   offset: const Offset(0, 15),
//                 ),
//               ],
//             ),
//             child: StatefulBuilder(
//               builder: (context, setState) {
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(
//                             Icons.account_balance_wallet_rounded,
//                             color: Color(0xFF6366F1),
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         const Expanded(
//                           child: Text(
//                             'Withdraw Funds',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF1E293B),
//                               letterSpacing: -0.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),

//                     // Amount breakdown cards
//                     if (commission > 0) ...[
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8FAFC),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: const Color(0xFFE2E8F0)),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Platform Fee (5%)',
//                                   style: TextStyle(
//                                     color: Color(0xFF64748B),
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '₹${commission.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                     color: Color(0xFFEF4444),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 const Text(
//                                   'You\'ll Receive',
//                                   style: TextStyle(
//                                     color: Color(0xFF64748B),
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '₹${finalAmount.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                     color: Color(0xFF10B981),
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     TextField(
//                       onChanged: (value) {
//                         double? amt = double.tryParse(value);
//                         if (amt != null && amt > 0) {
//                           setState(() {
//                             commission = amt * 0.05;
//                             finalAmount = amt - commission;
//                             if (amt < 500) {
//                               isAmountValid = false;
//                               helperText = "Minimum withdrawal amount is ₹500";
//                             } else if (amt > balance) {
//                               isAmountValid = false;
//                               helperText =
//                                   "Amount exceeds available balance of ₹${balance.toStringAsFixed(2)}";
//                             } else {
//                               isAmountValid = true;
//                               helperText = "Amount looks good!";
//                             }
//                           });
//                         } else {
//                           setState(() {
//                             commission = 0;
//                             finalAmount = 0;
//                             isAmountValid = value.isEmpty;
//                             helperText = "Minimum withdrawal amount is ₹500";
//                           });
//                         }
//                       },
//                       controller: amountController,
//                       keyboardType: TextInputType.number,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF1E293B),
//                       ),
//                       decoration: InputDecoration(
//                         hintText: "0.00",
//                         labelText: "Withdrawal Amount".tr,
//                         labelStyle: const TextStyle(
//                           color: Color(0xFF64748B),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide:
//                               const BorderSide(color: Color(0xFFE2E8F0)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: isAmountValid
//                                 ? const Color(0xFF6366F1)
//                                 : const Color(0xFFEF4444),
//                             width: 2,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: isAmountValid
//                                 ? const Color(0xFFE2E8F0)
//                                 : const Color(0xFFEF4444),
//                           ),
//                         ),
//                         prefixIcon: Container(
//                           margin: const EdgeInsets.all(12),
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.currency_rupee_rounded,
//                             color: Color(0xFF6366F1),
//                             size: 20,
//                           ),
//                         ),
//                         suffixText: "INR",
//                         suffixStyle: const TextStyle(
//                           color: Color(0xFF64748B),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         helperText: helperText,
//                         helperStyle: TextStyle(
//                           color: isAmountValid
//                               ? const Color(0xFF10B981)
//                               : const Color(0xFFEF4444),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFF8FAFC),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 16),
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     Row(
//                       children: [
//                         Expanded(
//                           child: TextButton(
//                             onPressed: () => Navigator.of(context).pop(),
//                             style: TextButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 side:
//                                     const BorderSide(color: Color(0xFFE2E8F0)),
//                               ),
//                             ),
//                             child: const Text(
//                               'Cancel',
//                               style: TextStyle(
//                                 color: Color(0xFF64748B),
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               double? amount =
//                                   double.tryParse(amountController.text);
//                               if (amount == null ||
//                                   amount <= 0 ||
//                                   amount < 500 ||
//                                   amount > balance) {
//                                 String errorMessage;
//                                 if (amount == null || amount <= 0) {
//                                   errorMessage = 'Please enter a valid amount';
//                                 } else if (amount < 500) {
//                                   errorMessage = 'Minimum amount is ₹500';
//                                 } else if (amount > balance) {
//                                   errorMessage =
//                                       'Amount exceeds available balance';
//                                 } else {
//                                   errorMessage = 'Invalid amount';
//                                 }
//                                 _showErrorToast(errorMessage);
//                               } else {
//                                 controller.withdraw(amount);
//                                 Navigator.of(context).pop();
//                                 _showSuccessToast(
//                                     'Withdrawal request submitted successfully!');
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF6366F1),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Withdraw',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
  void _showWithdrawDialog(BuildContext context,
      WithdrawalsController controller, num totalBalance) {
    // Total wallet balance = totalAmount + CODCommission
    // Available balance = (totalAmount + CODCommission) - CODCommission = totalAmount
    num totalWalletBalance = controller.totalAmount + controller.codCommission;
    num availableBalance = totalWalletBalance -
        controller.codCommission; // This equals controller.totalAmount
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double commission = 0;
        double finalAmount = 0;
        bool isAmountValid = true;
        String helperText = "Minimum withdrawal amount\nis ₹500";

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF6366F1),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text('Withdraw Funds'.tr,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Available balance info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Wallet Balance'.tr,
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₹${totalWalletBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('COD Commission'.tr,
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '- ₹${controller.codCommission.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Available Withdrawal'.tr,
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${availableBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount breakdown cards
                      if (commission > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Platform Fee (5%)'.tr,
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${commission.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('You\'.trll Receive',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${finalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      TextField(
                        onChanged: (value) {
                          double? amt = double.tryParse(value);
                          if (amt != null && amt > 0) {
                            setState(() {
                              commission = amt * 0.05;
                              finalAmount = amt - commission;
                              if (amt < 500) {
                                isAmountValid = false;
                                helperText =
                                    "Minimum withdrawal amount is ₹500";
                              } else if (amt > availableBalance) {
                                isAmountValid = false;
                                helperText =
                                    "Amount exceeds available balance of ₹${availableBalance.toStringAsFixed(2)}";
                              } else {
                                isAmountValid = true;
                                helperText = "Amount looks good!";
                              }
                            });
                          } else {
                            setState(() {
                              commission = 0;
                              finalAmount = 0;
                              isAmountValid = value.isEmpty;
                              helperText = "Minimum withdrawal amount is ₹500";
                            });
                          }
                        },
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          labelText: "Withdrawal Amount".tr,
                          labelStyle: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isAmountValid
                                  ? const Color(0xFF6366F1)
                                  : const Color(0xFFEF4444),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isAmountValid
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.currency_rupee_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                          suffixText: "INR",
                          suffixStyle: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          helperText: helperText,
                          helperStyle: TextStyle(
                            color: isAmountValid
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Text('Cancel'.tr,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                double? amount =
                                    double.tryParse(amountController.text);
                                if (amount == null ||
                                    amount <= 0 ||
                                    amount < 500 ||
                                    amount > availableBalance) {
                                  String errorMessage;
                                  if (amount == null || amount <= 0) {
                                    errorMessage =
                                        'Please enter a valid amount';
                                  } else if (amount < 500) {
                                    errorMessage = 'Minimum amount is ₹500';
                                  } else if (amount > availableBalance) {
                                    errorMessage =
                                        'Amount exceeds available balance of ₹${availableBalance.toStringAsFixed(2)}';
                                  } else {
                                    errorMessage = 'Invalid amount';
                                  }
                                  _showErrorToast(errorMessage);
                                } else {
                                  controller.withdraw(amount);
                                  Navigator.of(context).pop();
                                  _showSuccessToast(
                                      'Withdrawal request submitted successfully!');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text('Withdraw'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom theme colors for consistency
class ModernColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color outlineVariant = Color(0xFFF1F5F9);
}

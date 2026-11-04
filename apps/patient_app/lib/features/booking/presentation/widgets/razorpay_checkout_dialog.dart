import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/constants/payment_constants.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';

class RazorpayCheckoutDialog extends StatefulWidget {
  final String title;
  final String orderRef;
  final double amount;
  final ValueChanged<PaymentInfoEntity> onSuccess;

  const RazorpayCheckoutDialog({
    super.key,
    required this.title,
    required this.orderRef,
    required this.amount,
    required this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String orderRef,
    required double amount,
    required ValueChanged<PaymentInfoEntity> onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RazorpayCheckoutDialog(
        title: title,
        orderRef: orderRef,
        amount: amount,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<RazorpayCheckoutDialog> createState() => _RazorpayCheckoutDialogState();
}

class _RazorpayCheckoutDialogState extends State<RazorpayCheckoutDialog> {
  int _selectedTab = 0; // 0: UPI, 1: Card, 2: NetBanking
  String _selectedUpiApp = 'Google Pay';
  String _selectedBank = 'HDFC Bank';
  final TextEditingController _upiController =
      TextEditingController(text: 'aisha.rahman@okhdfcbank');

  bool _isProcessing = false;
  bool _isSuccess = false;
  String _generatedPaymentId = '';

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _executePayment() async {
    setState(() {
      _isProcessing = true;
    });

    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random();
    final randStr = List.generate(14, (_) => chars[random.nextInt(chars.length)]).join();
    _generatedPaymentId = 'pay_$randStr';

    String methodDesc = 'UPI ($_selectedUpiApp)';
    if (_selectedTab == 1) {
      methodDesc = 'Test Card ending in 4242';
    } else if (_selectedTab == 2) {
      methodDesc = '$_selectedBank NetBanking';
    }

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final payment = PaymentInfoEntity(
      paymentId: _generatedPaymentId,
      status: 'paid',
      gateway: 'Razorpay (Test Mode)',
      amount: widget.amount,
      method: methodDesc,
      paidAt: timeStr,
    );

    Navigator.pop(context);
    widget.onSuccess(payment);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: _isProcessing
              ? _buildProcessingState()
              : (_isSuccess ? _buildSuccessState() : _buildCheckoutContent()),
        ),
      ),
    );
  }

  Widget _buildCheckoutContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Header with Razorpay Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFF38BDF8),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkInk,
                      ),
                    ),
                    Text(
                      widget.orderRef,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.darkInkMuted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                size: 10,
                                color: Color(0xFFFBBF24),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'KEY: ${RazorpayConstants.keyId}',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: AppColors.darkInkMuted),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Amount Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkBgApp,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount to Pay',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.darkInkMuted,
                ),
              ),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: GoogleFonts.robotoMono(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Payment Mode Tabs
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBgApp,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              _buildTabButton(0, 'UPI Apps', Icons.qr_code_rounded),
              _buildTabButton(1, 'Card', Icons.credit_card_rounded),
              _buildTabButton(2, 'NetBanking', Icons.account_balance_rounded),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Tab Content
        if (_selectedTab == 0) _buildUpiPanel(),
        if (_selectedTab == 1) _buildCardPanel(),
        if (_selectedTab == 2) _buildNetBankingPanel(),

        const SizedBox(height: 20),

        // Pay Button
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x402563EB),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _executePayment,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pay ₹${widget.amount.toStringAsFixed(2)} (Test Mode)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFF38BDF8) : AppColors.darkInkFaint,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.darkInkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiPanel() {
    final apps = ['Google Pay', 'PhonePe', 'Paytm', 'BHIM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Fast UPI App:',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: AppColors.darkInkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: apps.map((app) {
            final isSelected = _selectedUpiApp == app;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedUpiApp = app),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                        : AppColors.darkBgApp,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF38BDF8) : AppColors.darkBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      app,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF38BDF8) : AppColors.darkInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _upiController,
          style: GoogleFonts.robotoMono(fontSize: 12.5, color: AppColors.darkInk),
          decoration: InputDecoration(
            labelText: 'UPI ID / VPA',
            labelStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.darkInkMuted),
            filled: true,
            fillColor: AppColors.darkBgApp,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBgApp,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TEST CARD DETAILS',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkInkMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.credit_card_rounded,
                size: 16,
                color: Color(0xFF38BDF8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '4242 •••• •••• 4242',
            style: GoogleFonts.robotoMono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expiry: 12/28',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.darkInkMuted),
              ),
              Text(
                'CVV: 123',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.darkInkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetBankingPanel() {
    final banks = ['HDFC Bank', 'ICICI Bank', 'State Bank of India', 'Axis Bank'];

    return Column(
      children: banks.map((bank) {
        final isSelected = _selectedBank == bank;

        return GestureDetector(
          onTap: () => setState(() => _selectedBank = bank),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                  : AppColors.darkBgApp,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF38BDF8) : AppColors.darkBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bank,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF38BDF8) : AppColors.darkInk,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF38BDF8),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Authorizing Payment...',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Simulating Razorpay Test Sandbox checkout for ₹${widget.amount.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.darkInkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Verified!',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transaction ID: $_generatedPaymentId',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

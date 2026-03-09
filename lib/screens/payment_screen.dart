import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.orderItems,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  String? _qrString;
  String? _orderId;
  String _errorMessage = '';
  bool _isPaymentConfirmed = false;
  bool _isConfirming = false;

  // ABA / Bakong Red Theme
  final Color _abaRed = const Color(0xFFD32F2F);
  final Color _abaDarkRed = const Color(0xFFB71C1C);
  final Color _bgLight = const Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  Future<void> _createOrder() async {
    try {
      final orderData = {
        "orderItems": widget.orderItems,
        "totalPrice": widget.totalPrice,
      };

      final response = await ApiService.createOrder(
        orderData: orderData,
      );

      // Assuming API returns qrString and order tracking info
      // e.g. { "_id": "...", "qrString": "..." }
      if (mounted) {
        setState(() {
          _orderId = response['_id'] ?? response['id'];
          // Fallback if the backend uses another key for qrString
          _qrString = response['qrString'] ?? response['qrCode'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_orderId == null) return;

    setState(() => _isConfirming = true);
    try {
      await ApiService.confirmPayment(
        orderId: _orderId!,
      );
      if (mounted) {
        setState(() {
          _isConfirming = false;
          _isPaymentConfirmed = true;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation for success
              SizedBox(
                height: 150,
                width: 150,
                child: Lottie.network(
                  'https://lottie.host/972cf7f7-b2e8-4aba-8dc9-76228addb4e0/N2a2656wU8.json',
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.check_circle,
                        color: Colors.green, size: 100);
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been paid and is being processed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _abaRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    // Pop dialog
                    Navigator.pop(context);
                    // Return true to caller screen indicating success
                    Navigator.pop(context, true);
                  },
                  child: const Text('Back to Home',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title:
            const Text('KHQR Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: _abaRed,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _abaRed),
            const SizedBox(height: 16),
            const Text('Generating KHQR...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text('Failed to generate order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _abaRed),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _createOrder();
                },
                child:
                    const Text('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Total Amount Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _abaDarkRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // QR Code Card
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              children: [
                // Top KHQR Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner, color: _abaRed),
                    const SizedBox(width: 8),
                    Text(
                      'Scan to Pay via Bakong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _abaDarkRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // QR Image
                if (_qrString != null)
                  QrImageView(
                    data: _qrString!,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  )
                else
                  const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(child: Text('QR data is empty')),
                  ),

                const SizedBox(height: 24),

                // Supported Banks Mock Image or Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBankCircle('ABA'),
                    const SizedBox(width: 8),
                    _buildBankCircle('ACLEDA'),
                    const SizedBox(width: 8),
                    const Text('and more KHQR apps',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed:
                  _isConfirming || _isPaymentConfirmed ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _abaRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isConfirming
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Only click confirm after you have successfully scanned and paid.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCircle(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bgLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: _abaDarkRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

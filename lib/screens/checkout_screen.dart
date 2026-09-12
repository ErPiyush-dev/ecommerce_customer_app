import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../providers/address_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../models/order_model.dart';
import 'add_address_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  late Razorpay _razorpay;
  bool _isPlacingOrder = false;

  OrderResponse?
  _pendingOrder; // Jab tak payment verify na ho, order yahan store rakhenge

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  @override
  void dispose() {
    _razorpay.clear(); // Memory leak se bachne ke liye zaroori hai
    super.dispose();
  }

  void _placeOrder() async {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );

    if (addressProvider.selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle ek address select karein')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // Step 1: Apne backend me Order place karo
      final order = await _orderService.placeOrder(
        addressProvider.selectedAddressId!,
      );
      _pendingOrder = order;

      // Step 2: Razorpay payment order create karo
      final paymentOrder = await _paymentService.createPaymentOrder(
        order.orderId,
      );

      // Step 3: Razorpay ka checkout popup kholo
      var options = {
        'key': paymentOrder.razorpayKeyId,
        'amount': (paymentOrder.amount * 100).toInt(), // paise me chahiye
        'order_id': paymentOrder.razorpayOrderId,
        'name': 'Ecommerce App',
        'description': 'Order #${order.orderId}',
        'prefill': {'contact': '', 'email': ''},
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kuch galat ho gaya: $e')));
      }
      setState(() => _isPlacingOrder = false);
    }
  }

  // Payment successful hone par Razorpay ye call karta hai
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Step 4: Signature verify karo apne backend se
      await _paymentService.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart();

      if (mounted && _pendingOrder != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(order: _pendingOrder!),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verify nahi ho paaya: $e')),
        );
      }
    }
    setState(() => _isPlacingOrder = false);
  }

  // Payment fail/cancel hone par
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment fail ho gaya: ${response.message}')),
    );
    setState(() => _isPlacingOrder = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
    setState(() => _isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer2<AddressProvider, CartProvider>(
        builder: (context, addressProvider, cartProvider, _) {
          if (addressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddressScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (addressProvider.addresses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Koi address nahi hai. Upar se "Add New" dabakar ek add karein.',
                        ),
                      )
                    else
                      ...addressProvider.addresses.map((address) {
                        final isSelected =
                            addressProvider.selectedAddressId == address.id;
                        return Card(
                          color: isSelected ? Colors.deepPurple.shade50 : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: RadioListTile<int>(
                            value: address.id,
                            groupValue: addressProvider.selectedAddressId,
                            onChanged: (value) =>
                                addressProvider.selectAddress(value!),
                            title: Text(
                              address.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${address.shortAddress}\nPhone: ${address.phoneNumber}',
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),

                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...cartProvider.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} x${item.quantity}',
                              ),
                            ),
                            Text('₹${item.totalPrice.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isPlacingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Pay & Place Order',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

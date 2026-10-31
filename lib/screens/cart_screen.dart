import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';
import '../services/xendit_services.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  Future<void> _checkoutWithXendit() async {
    if (CartService.instance.items.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? 'customer@mjs.com';
      final totalAmount = CartService.instance.grandTotal;

      final invoiceUrl = await XenditService.createInvoice(
        externalId: 'mjs-order-${DateTime.now().millisecondsSinceEpoch}',
        amount: totalAmount,
        payerEmail: email,
        description: 'MJS Craft Coffee Order (${CartService.instance.totalItems} items)',
      );

      if (invoiceUrl != null) {
        final Uri uri = Uri.parse(invoiceUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          CartService.instance.clearCart();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create Xendit payment link.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, child) {
        final cartItems = CartService.instance.items;
        final grandTotal = CartService.instance.grandTotal;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF6EE),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF4A3428)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Your Cart',
              style: TextStyle(color: Color(0xFF4A3428), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          body: cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: Color(0xFFA1887F), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
                                ? Image.network(item.product.imageUrl!, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(width: 60, height: 60, color: const Color(0xFFEFE6D8), child: const Icon(Icons.coffee)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               Text(
                              '${item.product.name} (${item.selectedSize})', // Dito makikita kung Small, Medium, o Large
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A3428)),
                         ),
                          const SizedBox(height: 4),
                          Text(
                           '₱${item.unitPrice.toStringAsFixed(2)} each', // Dito lalabas ang tamang presyo batay sa piniling size (hal. ₱150.00 o ₱170.00)
                          style: const TextStyle(color: Color(0xFFA1887F), fontSize: 12),
                        ),
                      ],
                   ),
                 ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF8D6E63)),
                                onPressed: () {
                                   CartService.instance.decrementQuantity(index);
                                }
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF4A3428)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8D6E63)),
                                onPressed: () => CartService.instance.incrementQuantity(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Color(0xFFA1887F), fontSize: 15)),
                    Text(
                      '₱${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF4A3428)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A3428),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading || cartItems.isEmpty ? null : _checkoutWithXendit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Mag-bayad na gamit ang Xendit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import 'payment_screen.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'Small';
  int _quantity = 1;
  bool _isFavorite = false;

  final List<String> _sizes = ['Small', 'Medium', 'Large', 'Bottled'];

  double _calculateTotalPrice() {
    double sizeAddon = 0.0;

    switch (_selectedSize) {
      case 'Small':
        sizeAddon = 0.0;
        break;
      case 'Medium':
        sizeAddon = 20.0;
        break;
      case 'Large':
        sizeAddon = 40.0;
        break;
      case 'Bottled':
        sizeAddon = 50.0;
        break;
    }

    return (widget.product.price + sizeAddon) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    double currentPrice = _calculateTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6D4C41)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My order',
          style: TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
              color: _isFavorite ? Colors.redAccent : const Color(0xFF6D4C41),
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 200,
                child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.local_cafe, size: 100, color: Color(0xFF8D6E63)),
                      )
                    : const Icon(Icons.local_cafe, size: 100, color: Color(0xFF8D6E63)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 4),
                    Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.product.description.toString(),
              style: const TextStyle(color: Color(0xFFA1887F), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Size Selector Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDE2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _sizes.map((size) {
                  bool isSelected = _selectedSize == size;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSize = size),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF4A3428) : const Color(0xFFA1887F),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 30),

            // Quantity Counter & Dynamic Price Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDE2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18, color: Color(0xFF6D4C41)),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18, color: Color(0xFF6D4C41)),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₱${currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
                ),
              ],
            ),
            const Spacer(),

            // Add to Cart Button katabi ng Order Now Button
            Row(
              children: [
                // Add to Cart Icon Button
                GestureDetector(
                  onTap: () {
                  double singleUnitPrice = currentPrice / _quantity;

  // I-pasa ang tamang size, quantity, at customPrice nang sabay-sabay
  CartService.instance.addToCart(
    widget.product,
    size: _selectedSize,
    qty: _quantity,
    customPrice: singleUnitPrice,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${widget.product.name} ($_selectedSize) naidagdag sa cart!'),
      duration: const Duration(milliseconds: 800),
      action: SnackBarAction(
        label: 'VIEW',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        },
      ),
    ),
  );
},
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDE2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD7CCC8)),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6D4C41)),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Order Now Button
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFAF6EE),
                        foregroundColor: const Color(0xFF2E7D32),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFD7CCC8)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              totalAmount: currentPrice,
                              productName: widget.product.name,
                              selectedSize: _selectedSize,
                              quantity: _quantity,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18, color: Color(0xFF2E7D32)),
                          SizedBox(width: 8),
                          Text('Order now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
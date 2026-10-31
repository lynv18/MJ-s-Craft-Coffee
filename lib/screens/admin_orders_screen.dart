import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      // Kunin ang mga orders mula sa Supabase table (halimbawa ay 'orders' table)
      final response = await supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _orders = response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Admin - Customer Orders',
          style: TextStyle(color: Color(0xFF4A3428), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A3428)),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'Wala pang pumapasok na order.',
                    style: TextStyle(color: Color(0xFFA1887F), fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order['id'].toString().substring(0, 6)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: order['status'] == 'PAID' ? Colors.green[100] : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order['status'] ?? 'PENDING',
                                  style: TextStyle(
                                    color: order['status'] == 'PAID' ? Colors.green[800] : Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text('Customer: ${order['customer_email'] ?? 'N/A'}', style: const TextStyle(color: Color(0xFFA1887F))),
                          const SizedBox(height: 4),
                          Text(
                            'Amount: ₱${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A3428)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
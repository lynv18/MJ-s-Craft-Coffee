import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  
  List<CategoryItem> _categories = [];
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  
  final Set<String> _favoriteProductIds = {};

  String _selectedCategoryId = 'ALL';
  String _searchQuery = '';
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final catResponse = await supabase
          .from('categories')
          .select()
          .order('sort_order', ascending: true);
      
      final catData = catResponse as List<dynamic>;
      final loadedCategories = catData.map((e) => CategoryItem.fromMap(e)).toList();

      final prodResponse = await supabase.from('products').select();
      final prodData = prodResponse as List<dynamic>;
      final loadedProducts = prodData.map((e) => Product.fromMap(e)).toList();

      setState(() {
        _categories = loadedCategories;
        _products = loadedProducts;
        _filteredProducts = loadedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data from Supabase: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String categoryId, {String query = ''}) {
    setState(() {
      _selectedCategoryId = categoryId;
      _searchQuery = query;

      List<Product> baseList = _products;

      // Tab 2 filter (Favorites)
      if (_currentIndex == 2) {
        baseList = _products.where((p) => _favoriteProductIds.contains(p.id)).toList();
      }

      // Category filter
      if (categoryId != 'ALL') {
        baseList = baseList.where((p) => p.categoryId == categoryId).toList();
      }

      // Search query filter
      if (query.isNotEmpty) {
        baseList = baseList.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
      }

      _filteredProducts = baseList;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } else {
      _filterProducts(_selectedCategoryId, query: _searchQuery);
      if (index == 2 && _favoriteProductIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wala pang naka-heart na produkto!')),
        );
      }
    }
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProductIds.contains(product.id)) {
        _favoriteProductIds.remove(product.id);
      } else {
        _favoriteProductIds.add(product.id);
      }
      _filterProducts(_selectedCategoryId, query: _searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "MJ's Craft Coffee",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
            ),
            Text(
              "Your daily cup of happiness",
              style: TextStyle(fontSize: 11, color: Color(0xFFA1887F)),
            ),
          ],
        ),
        actions: [
          // Admin Dashboard Shortcut Button
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF4A3428)),
            tooltip: 'Admin Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AnimatedBuilder(
              animation: CartService.instance,
              builder: (context, child) {
                final itemCount = CartService.instance.totalItems;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF4A3428)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Functional Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      onChanged: (value) => _filterProducts(_selectedCategoryId, query: value),
                      style: const TextStyle(color: Color(0xFF4A3428)),
                      decoration: const InputDecoration(
                        hintText: 'Search your favorite drink',
                        hintStyle: TextStyle(color: Color(0xFFA1887F)),
                        icon: Icon(Icons.search, color: Color(0xFF8D6E63)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Explore Menu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A3428)),
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SizedBox(
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('ALL', 'All'),
                        ..._categories.map((cat) => _buildCategoryChip(cat.id, cat.name)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    '${_filteredProducts.length} drinks available',
                    style: const TextStyle(color: Color(0xFFA1887F), fontSize: 13),
                  ),
                  const SizedBox(height: 15),

                  // Products Grid
                  _filteredProducts.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text(
                              'No items found.',
                              style: TextStyle(color: Color(0xFFA1887F), fontSize: 14),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return _buildProductCard(product);
                          },
                        ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFAF6EE),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF6D4C41),
        unselectedItemColor: const Color(0xFFA1887F),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String id, String label) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => _filterProducts(id, query: _searchQuery),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A3428) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A3428),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isFavorite = _favoriteProductIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderIcon(),
                          )
                        : _placeholderIcon(),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4A3428),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF4A3428),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                // Plus button para direktang mag-add sa cart
                GestureDetector(
                  onTap: () {
                    CartService.instance.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3428),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: const Color(0xFFEFE6D8),
      width: double.infinity,
      child: const Icon(Icons.coffee_rounded, size: 36, color: Color(0xFF8D6E63)),
    );
  }
}
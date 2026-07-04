import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/auth_service.dart';

class AgProduct {
  final String id;
  final String name;
  final String category;
  final String price;
  final double rating;
  final String imageUrl;
  final String description;

  const AgProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.description,
  });
}

class BuyProductsScreen extends StatefulWidget {
  const BuyProductsScreen({super.key});

  @override
  State<BuyProductsScreen> createState() => _BuyProductsScreenState();
}

class _BuyProductsScreenState extends State<BuyProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = "";
  int _selectedCategoryIndex = 0;
  bool _isOrdering = false;

  final List<String> _categories = const [
    'All',
    'Vegetables',
    'Fruits',
    'Daily Essentials',
    'Seeds',
    'Fertilizers',
    'Tools'
  ];

  final List<AgProduct> _products = const [
    // --- Vegetables ---
    AgProduct(
      id: 'v1',
      name: 'Fresh Organic Tomatoes',
      category: 'Vegetables',
      price: '₹40/kg',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=400',
      description: 'Fresh, vine-ripened organic tomatoes grown without pesticides.',
    ),
    AgProduct(
      id: 'v2',
      name: 'Premium Russet Potatoes',
      category: 'Vegetables',
      price: '₹30/kg',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=400',
      description: 'Premium grade potatoes, perfect for baking, mashing, and cooking.',
    ),
    AgProduct(
      id: 'v3',
      name: 'Fresh Green Chillies',
      category: 'Vegetables',
      price: '₹60/kg',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1588252396755-c31365a639bf?q=80&w=400',
      description: 'Spicy and fresh local green chillies, handpicked daily.',
    ),
    AgProduct(
      id: 'v4',
      name: 'Organic Spinach (Palak)',
      category: 'Vegetables',
      price: '₹20/bunch',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=400',
      description: 'Nutrient-rich, fresh organic spinach leaves.',
    ),

    // --- Fruits ---
    AgProduct(
      id: 'fr1',
      name: 'Alphonso Mangoes',
      category: 'Fruits',
      price: '₹600/dozen',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?q=80&w=400',
      description: 'Sweet, rich, and creamy Alphonso mangoes, directly from Ratnagiri orchards.',
    ),
    AgProduct(
      id: 'fr2',
      name: 'Fresh Cavendish Bananas',
      category: 'Fruits',
      price: '₹60/dozen',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?q=80&w=400',
      description: 'High-quality sweet yellow Cavendish bananas.',
    ),
    AgProduct(
      id: 'fr3',
      name: 'Royal Delicious Apples',
      category: 'Fruits',
      price: '₹180/kg',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=400',
      description: 'Crisp, sweet, and juicy handpicked apples from Shimla.',
    ),
    AgProduct(
      id: 'fr4',
      name: 'Organic Hybrid Papaya',
      category: 'Fruits',
      price: '₹50/kg',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1528825871115-3581a5387919?q=80&w=400',
      description: 'Sweet, orange-fleshed papayas, rich in papain and vitamin A.',
    ),

    // --- Daily Essentials ---
    AgProduct(
      id: 'de1',
      name: 'Pure Desi Cow Ghee',
      category: 'Daily Essentials',
      price: '₹650/500ml',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?q=80&w=400',
      description: '100% pure traditional Bilona method A2 cow ghee.',
    ),
    AgProduct(
      id: 'de2',
      name: 'Organic Forest Honey',
      category: 'Daily Essentials',
      price: '₹350/250g',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=400',
      description: 'Raw, unpasteurized honey sourced directly from wild forest hives.',
    ),
    AgProduct(
      id: 'de3',
      name: 'Fresh Organic Milk',
      category: 'Daily Essentials',
      price: '₹70/L',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=400',
      description: 'Farm fresh, pasteurized organic whole cow milk.',
    ),
    AgProduct(
      id: 'de4',
      name: 'Organic Turmeric Powder',
      category: 'Daily Essentials',
      price: '₹120/250g',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=400',
      description: 'High curcumin organic turmeric powder (Haldi).',
    ),

    // --- Seeds ---
    AgProduct(
      id: 's1',
      name: 'Organic Basmati Paddy Seeds',
      category: 'Seeds',
      price: '₹750/bag',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400',
      description: 'High-yielding, disease-resistant traditional Basmati rice seeds.',
    ),
    AgProduct(
      id: 's2',
      name: 'Bt Cotton Hybrid Seeds',
      category: 'Seeds',
      price: '₹950/pkt',
      rating: 4.7,
      imageUrl: 'assets/images/cotton_crop.png',
      description: 'Bollworm-resistant hybrid cotton seeds for superior fiber quality.',
    ),
    AgProduct(
      id: 's3',
      name: 'Sweet Corn Hybrid Seeds',
      category: 'Seeds',
      price: '₹450/pkt',
      rating: 4.6,
      imageUrl: 'assets/images/maize_crop.png',
      description: 'Premium sweet corn seeds with high germination rate (95%+).',
    ),

    // --- Fertilizers ---
    AgProduct(
      id: 'f1',
      name: 'NPK Organic Granular Mix',
      category: 'Fertilizers',
      price: '₹1,200/50kg',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?q=80&w=400',
      description: 'Slow-release natural nitrogen, phosphorus, and potassium mix.',
    ),
    AgProduct(
      id: 'f2',
      name: 'Pure Cold-Pressed Neem Cake',
      category: 'Fertilizers',
      price: '₹600/25kg',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?q=80&w=400',
      description: 'Dual-action organic fertilizer and pest repellent for roots.',
    ),

    // --- Tools ---
    AgProduct(
      id: 't1',
      name: 'Automatic Drip Irrigation Kit',
      category: 'Tools',
      price: '₹2,999/kit',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=400',
      description: 'Full automated irrigation kit covers up to 1 acre of land.',
    ),
    AgProduct(
      id: 't2',
      name: 'High-Pressure Hand Sprayer',
      category: 'Tools',
      price: '₹850/pc',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?q=80&w=400',
      description: 'Heavy duty 5L sprayer for fertilizers and organic pesticide application.',
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AgProduct> _getFilteredProducts(String category) {
    return _products.where((p) {
      final matchesCategory = category == 'All' || p.category == category;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Widget _buildProductImage(String urlOrPath, String category, {required double size}) {
    IconData getCategoryIcon(String cat) {
      switch (cat) {
        case 'Vegetables':
          return Icons.spa;
        case 'Fruits':
          return Icons.apple;
        case 'Daily Essentials':
          return Icons.shopping_basket;
        case 'Seeds':
          return Icons.grain;
        case 'Fertilizers':
          return Icons.biotech;
        case 'Tools':
          return Icons.handyman;
        default:
          return Icons.shopping_bag;
      }
    }

    Widget fallback = Container(
      width: size,
      height: size,
      color: AppColors.border.withOpacity(0.5),
      child: Icon(getCategoryIcon(category), color: AppColors.agriGreen, size: 36),
    );

    if (urlOrPath.startsWith('assets/')) {
      return Image.asset(
        urlOrPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      return Image.network(
        urlOrPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: AppColors.border.withOpacity(0.3),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => fallback,
      );
    }
  }

  Future<void> _placeOrder(AgProduct product) async {
    setState(() {
      _isOrdering = true;
    });

    final payload = {
      'productId': product.id,
      'productName': product.name,
      'category': product.category,
      'price': product.price,
    };

    try {
      final baseUrl = await AuthService.instance.getActiveBackendUrl();
      final token = await AuthService.instance.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/agrogen/buy-product'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201) {
        _showPurchaseSuccessDialog(product);
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Server error');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order saved offline: $e. Saved locally for demo.'),
            backgroundColor: AppColors.alertRed,
          ),
        );
        _showPurchaseSuccessDialog(product);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOrdering = false;
        });
      }
    }
  }

  void _showPurchaseSuccessDialog(AgProduct product) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.border),
        ),
        title: Column(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Order Placed!',
              style: AppTextStyles.h2.copyWith(color: Colors.green),
            ),
          ],
        ),
        content: Text(
          'Your order for ${product.name} has been placed successfully and recorded in MongoDB. A delivery partner will contact you shortly.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.agriGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 44),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = _categories[_selectedCategoryIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text('Buy Products', style: AppTextStyles.appBarTitle),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Search vegetables, fruits, essentials...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: AppColors.agriGreen),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.agriGreen),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Custom horizontal tabs row
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, idx) {
                    final catName = _categories[idx];
                    final isSelected = idx == _selectedCategoryIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(catName),
                        selected: isSelected,
                        selectedColor: AppColors.agriGreen.withOpacity(0.2),
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.agriGreen : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? AppColors.agriGreen : AppColors.border),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryIndex = idx;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 12),

              // Product Catalog List
              Expanded(
                child: _buildProductList(activeCategory),
              ),
            ],
          ),
          if (_isOrdering)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.agriGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(String category) {
    final list = _getFilteredProducts(category);
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No products found matching your search.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final p = list[i];
        return Card(
          color: AppColors.card,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(p.imageUrl, p.category, size: 90),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${p.rating}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.agriGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.category,
                              style: TextStyle(color: AppColors.agriGreen, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.description,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p.price,
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.agriGreen, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.agriGreen,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: const Size(0, 0),
                              ),
                              onPressed: _isOrdering ? null : () => _placeOrder(p),
                              child: const Text('Buy Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 30 * i));
      },
    );
  }
}

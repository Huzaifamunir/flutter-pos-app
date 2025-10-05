import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../data/sample_products.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_widget.dart';
import 'checkout_screen.dart';
import 'add_menu_screen.dart';
import 'manage_categories_screen.dart';
import 'order_history_screen.dart';
import 'add_expense_screen.dart';
import 'expense_history_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String selectedCategory = 'All';
  List<Product> filteredProducts = [];
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final products = await SampleProducts.getProducts();
      final categoryList = await SampleProducts.getCategories();
      
      setState(() {
        filteredProducts = products;
        categories = categoryList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProducts(String category) async {
    setState(() {
      selectedCategory = category;
      isLoading = true;
    });

    try {
      List<Product> products;
      if (category == 'All') {
        products = await SampleProducts.getProducts();
      } else {
        products = await SampleProducts.getProductsByCategory(category);
      }
      
      setState(() {
        filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Order History',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.money_off),
            tooltip: 'Expense History',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_card),
            tooltip: 'Add Expense',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoriesScreen(),
                ),
              ).then((_) {
                // Refresh the product list when returning from manage categories
                _loadData();
              });
            },
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMenuScreen(),
                ),
              ).then((_) {
                // Refresh the product list when returning from add menu
                _loadData();
              });
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Menu Item',
          ),
        ],
      ),
      body: Row(
        children: [
          // Product Grid Section
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Category Filter
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Categories:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                onSelected: (selected) {
                                  if (selected) {
                                    _filterProducts(category);
                                  }
                                },
                                selectedColor: Colors.blue[200],
                                checkmarkColor: Colors.blue[800],
                              ),
                            );
                          }).toList(),
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Grid
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 6 : 
                                           MediaQuery.of(context).size.width > 800 ? 5 : 
                                           MediaQuery.of(context).size.width > 600 ? 4 : 3,
                            childAspectRatio: MediaQuery.of(context).size.width > 800 ? 0.7 : 0.6,
                            crossAxisSpacing: MediaQuery.of(context).size.width > 800 ? 12 : 8,
                            mainAxisSpacing: MediaQuery.of(context).size.width > 800 ? 12 : 8,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: filteredProducts[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
          // Cart Section
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                left: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return Text(
                            '${cart.itemCount} items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Cart Items
                const Expanded(
                  child: CartWidget(),
                ),
                // Checkout Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: cart.items.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const CheckoutScreen(),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ),
        ],
      ),
    );
  }
}

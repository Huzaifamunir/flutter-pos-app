import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add items to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cart.items.length,
          itemBuilder: (context, index) {
            final item = cart.items[index];
            return CartItemWidget(item: item);
          },
        );
      },
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<CartProvider>().removeItemCompletely(item.product);
                },
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red,
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<CartProvider>().removeItem(item.product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.read<CartProvider>().addItem(item.product);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                'PKR ${item.totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class ReceiptPrinter {
  static Future<void> printReceipts(Order order, BuildContext context) async {
    // For now, just show the receipts dialog since printing is not supported on desktop
    _showReceiptsDialog(order, context);
  }

  static void _showReceiptsDialog(Order order, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Processed Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been completed and saved to the database.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Total: PKR ${order.totalAmount.toStringAsFixed(0)}'),
                  Text('Payment: ${order.paymentMethod}'),
                  Text('Items: ${order.items.length}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Receipt printing is not available on desktop. The order has been saved to your database and can be viewed in Order History.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // PDF generation methods are commented out since printing is not supported on desktop
  // These can be uncommented and used when printing support is needed
  
  /*
  static Future<void> _printCustomerReceipt(Order order) async {
    // PDF generation code here
  }

  static Future<void> _printKitchenReceipt(Order order) async {
    // PDF generation code here
  }
  */
}

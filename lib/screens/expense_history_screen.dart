import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Expense> expenses = [];
  bool isLoading = true;
  DateTime? selectedDate;
  double totalExpenses = 0.0;
  int totalExpenseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      isLoading = true;
    });

    try {
      final expenseList = await _dbHelper.getExpenses();
      final total = await _dbHelper.getTotalExpenses();

      setState(() {
        expenses = expenseList;
        totalExpenses = total;
        totalExpenseCount = expenseList.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _filterByDate(DateTime date) async {
    setState(() {
      isLoading = true;
      selectedDate = date;
    });

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      final expenseList = await _dbHelper.getExpensesByDateRange(startOfDay, endOfDay);

      setState(() {
        expenses = expenseList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
    });
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                _filterByDate(date);
              }
            },
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by Date',
          ),
          if (selectedDate != null)
            IconButton(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt, size: 32, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            totalExpenseCount.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total Expenses'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.attach_money, size: 32, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'PKR ${totalExpenses.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Total Amount'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expenses List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.money_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No expenses found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red[100],
                                child: Icon(
                                  _getCategoryIcon(expense.category),
                                  color: Colors.red[700],
                                ),
                              ),
                              title: Text(
                                expense.description,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category: ${expense.category}'),
                                  Text(
                                    '${expense.createdAt.day}/${expense.createdAt.month}/${expense.createdAt.year} ${expense.createdAt.hour}:${expense.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                                  if (expense.notes != null && expense.notes!.isNotEmpty)
                                    Text('Notes: ${expense.notes}'),
                                ],
                              ),
                              trailing: Text(
                                'PKR ${expense.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home;
      case 'utilities':
        return Icons.electrical_services;
      case 'supplies':
        return Icons.inventory;
      case 'equipment':
        return Icons.build;
      case 'marketing':
        return Icons.campaign;
      case 'staff':
        return Icons.people;
      case 'maintenance':
        return Icons.handyman;
      default:
        return Icons.money_off;
    }
  }
}


import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/models/category.dart';
import 'package:personal_finance_tracker/services/database_helper.dart';
import 'package:personal_finance_tracker/models/expense.dart';
import 'package:personal_finance_tracker/screens/add_expense_screen.dart';
import 'package:personal_finance_tracker/utils/date_formatter.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const Map<String, IconData> _categoryIcons = {
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'shopping_cart': Icons.shopping_cart,
  'receipt': Icons.receipt,
  'movie': Icons.movie,
  'fitness_center': Icons.fitness_center,
  'school': Icons.school,
  'more_horiz': Icons.more_horiz,
};

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  double _totalSpending = 0.0;
  int? _selectedCategoryId = null;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    final categories = await DatabaseHelper.instance.getAllCategories();
    final totalExp = await _getTotalOfExpenses(_selectedCategoryId);

    // String dropdownValue = await categories.first.name;

    setState(() {
      _expenses = expenses;
      _categories = categories;
      _totalSpending = totalExp;
    });
  }

  Category? _getCategoryForExpense(Expense expense) {
    try {
      return _categories.firstWhere((cat) => cat.id == expense.catId);
    } catch (e) {
      return null;
    }
  }

  IconData? _getIconForCategory(String icon) {
    try {
      return _categoryIcons[icon];
    } catch (e) {
      return null;
    }
  }

  void dropdownCallback(int? selectedValue) async {
    setState(() {
      _selectedCategoryId = selectedValue;
      if (_selectedCategoryId != null) {
        final selectedCategory = _categories.firstWhere(
          (cat) => cat.id == _selectedCategoryId,
          orElse: () => throw Exception("Category not found"),
        );
        //print("Selected Category: ${selectedCategory.name}");
      }
    });

    final filteredExpenses = await _getFilteredExpenses(selectedValue);
    final filteredTotal = await _getTotalOfExpenses(selectedValue);

    setState(() {
      _expenses = filteredExpenses;
      _totalSpending = filteredTotal;
    });
  }

  Future<List<Expense>> _getFilteredExpenses(int? id) async {
    if (id == null) {
      return await DatabaseHelper.instance.getAllExpenses();
    }
    List<Expense> tempExpenses = await DatabaseHelper.instance
        .getAllExpensesByCategory(id);
    return tempExpenses;
  }

  Future<double> _getTotalOfExpenses(int? id) async {
    double sum = 0.0;
    var tempExpenses;
    if (id == null) {
      tempExpenses = await DatabaseHelper.instance.getAllExpenses();
      for (var expense in tempExpenses) {
        sum += expense.amount;
        print(sum.toString());
      }
    } else {
      tempExpenses = await DatabaseHelper.instance.getAllExpensesByCategory(id);
      for (var expense in tempExpenses) {
        sum += expense.amount;
        print(sum.toString());
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          _totalSpending.toString(),
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<int?>(
                  isExpanded: false,
                  items: [
                    DropdownMenuItem(value: null, child: Text("All")),
                    ..._categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ],
                  value: _selectedCategoryId,
                  onChanged: dropdownCallback,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _expenses.isEmpty
                    ? Center(child: Text("No expenses added yet. Add one!"))
                    : ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        final categoryId = _expenses[index].catId;
                        final iconName = (_categories[categoryId].icon);
                        return Dismissible(
                          key: Key(expense.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Delete Expense"),
                                    content: Text(
                                      "Are you sure you want to delete this expense?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          onDismissed: (direction) async {
                            await DatabaseHelper.instance.deleteExpense(
                              expense.id!,
                            );
                            setState(() {
                              _expenses.removeAt(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Expense deleted successfully"),
                                ),
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 20,
                              right: 20,
                            ),
                            child: ListTile(
                              tileColor: Colors.grey.shade200,
                              leading:
                                  _getCategoryForExpense(expense) != null
                                      ? Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            int.parse(
                                              "0x${_getCategoryForExpense(expense)!.color}",
                                            ),
                                          ),
                                          shape: BoxShape.circle,
                                        ),

                                        child: Icon(
                                          _getIconForCategory(iconName),
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                      : null,
                              title: Text(
                                _getCategoryForExpense(expense)?.name ??
                                    'Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.desc,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatExpenseDate(
                                      expense.date,
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                'LKR ${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()),
          );
          _loadAll();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

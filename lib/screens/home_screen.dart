import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/models/category.dart';
import 'package:personal_finance_tracker/services/database_helper.dart';
import 'package:personal_finance_tracker/models/expense.dart';
import 'package:personal_finance_tracker/screens/add_expense_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    final categories = await DatabaseHelper.instance.getAllCategories();

    setState(() {
      _expenses = expenses;
      _categories = categories;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body:
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
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                      );
                    },
                    onDismissed: (direction) async {
                      await DatabaseHelper.instance.deleteExpense(expense.id!);
                      setState(() {
                        _expenses.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Expense deleted successfully"),
                          ),
                        );
                      });
                    },
                    child: ListTile(
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
                        _getCategoryForExpense(expense)?.name ?? 'Unknown',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.desc,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            expense.date.toString().split(' ')[0],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
                  );
                },
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

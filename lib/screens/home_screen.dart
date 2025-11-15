import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/services/database_helper.dart';
import 'package:personal_finance_tracker/models/expense.dart';
import 'package:personal_finance_tracker/screens/add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses;
  }

  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    setState(() {
      _expenses = expenses;
    });
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
                  return ListTile(
                    title: Text(expense.desc),
                    subtitle: Text(expense.date.toString().split(' ')[0]),
                    trailing: Text(
                      'LKR ${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
          _loadExpenses();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

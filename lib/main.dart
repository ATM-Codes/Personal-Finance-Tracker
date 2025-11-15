import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/screens/home_screen.dart';
import 'package:personal_finance_tracker/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //DAtabase is initialised
  var db = await DatabaseHelper.instance.getDatabase;
  print("DB created succesfully");

  //Getting categories
  final categories = await db.query('categories');
  print('Categories: ${categories.length} found');

  for (var cat in categories) {
    print(' - ${cat['name']}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}

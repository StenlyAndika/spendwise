import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_style.dart';
import 'data/local/database_helper.dart';
import 'data/local/sqlite_expense_repository.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/expense_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final db = await DatabaseHelper.instance.database;
  final repository = SqliteExpenseRepository(db);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseProvider(repository),
      child: const SpendwiseApp(),
    ),
  );
}

class SpendwiseApp extends StatelessWidget {
  const SpendwiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendwise',
      debugShowCheckedModeBanner: false,
      theme: AppStyle.darkTheme,
      home: const HomePage(),
    );
  }
}

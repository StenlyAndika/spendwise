import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_style.dart';
import 'data/local/database_helper.dart';
import 'data/local/sqlite_expense_repository.dart';
import 'presentation/cubits/expense_cubit.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final db = await DatabaseHelper.instance.database;
  final repository = SqliteExpenseRepository(db);

  runApp(
    BlocProvider(
      create: (_) => ExpenseCubit(repository),
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
      theme: AppStyle.lightTheme,
      // The palette is light-only, so pin it instead of falling back to the
      // platform brightness, which would otherwise pick darkTheme (null) and
      // leave the brightness signal wrong on a dark-mode device.
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}

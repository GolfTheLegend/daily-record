import 'package:daily_record/components/box.dart';
import 'package:daily_record/components/button.dart';
import 'package:daily_record/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: MyBox(
          color: Theme.of(context).colorScheme.primary,
          child: Mybutton(
            color: Theme.of(context).colorScheme.secondary, 
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            }
            ),
        ),
      ),
    );
  }
}

import 'package:app_casal_flutter/home.dart';
import 'package:app_casal_flutter/themes/my_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppCasal());
}

class AppCasal extends StatelessWidget {
    const AppCasal({ super.key });

    @override
    Widget build(BuildContext context){
    return MaterialApp(
      title: 'App Casal',
      theme: MyTheme,
      home: const Home(),
    );
  }
}

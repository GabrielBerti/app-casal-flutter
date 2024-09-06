import 'package:app_casal_flutter/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: ThemeColors.headerGradient
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(75)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'App Casal',
                  style: TextStyle(
                    fontSize: 20, // Define o tamanho da fonte
                    fontWeight: FontWeight.bold, // Deixa o texto em negrito
                  ),
                ),
              ],

            ),
          ),
        ],
      )


    );
  }
}

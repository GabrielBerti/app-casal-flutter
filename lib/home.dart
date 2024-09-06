import 'package:app_casal_flutter/modulo_card_item.dart';
import 'package:app_casal_flutter/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: Column(
            children: [
              Container(
                height: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: ThemeColors.headerGradient),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(75)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'App Casal',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const ModuloCardItem(
                  text: "Finanças",
                  icon: Icons.monetization_on_outlined,
                  colorBg: ThemeColors.yellowCard),
              const ModuloCardItem(
                  text: "Metas",
                  icon: Icons.done_outline_rounded,
                  colorBg: ThemeColors.purpleCard),
              const ModuloCardItem(
                  text: "Receitas",
                  icon: Icons.food_bank_outlined,
                  colorBg: ThemeColors.blueCard),
              const ModuloCardItem(
                  text: "Viagens",
                  icon: Icons.card_travel_outlined,
                  colorBg: ThemeColors.pinkCard),
            ],
          ),
        ),
      ],
    );
  }
}

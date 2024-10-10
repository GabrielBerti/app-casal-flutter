import 'package:app_casal_flutter/financas/models/resumo.dart';
import 'package:app_casal_flutter/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderFinancas extends StatefulWidget {
  final Resumo resumo;

  const HeaderFinancas({super.key, required this.resumo});

  @override
  _HeaderFinancasState createState() => _HeaderFinancasState();
}

class _HeaderFinancasState extends State<HeaderFinancas> {
  Color receiverColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: double.infinity, // Ocupará toda a largura disponível
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 88, 90, 94),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Biel",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              color: ThemeColors.colorBiel,
                            ),
                          ),
                          Text(
                            "Mari",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              color: ThemeColors.colorMari,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            NumberFormat.currency(
                                    locale: 'pt_BR', symbol: 'R\$')
                                .format(widget.resumo.saldoBiel),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                              color: ThemeColors.colorBiel,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'pt_BR', symbol: 'R\$')
                                .format(widget.resumo.saldoMari),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                              color: ThemeColors.colorMari,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      calculateBalance(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: receiverColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String calculateBalance() {
    String result;
    String textBalance;
    Color newReceiverColor;

    if (widget.resumo.saldoBiel > widget.resumo.saldoMari) {
      result = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(widget.resumo.saldoBiel - widget.resumo.saldoMari);
      newReceiverColor = ThemeColors.colorBiel;
      textBalance = "Mari deve $result para Biel";
    } else if (widget.resumo.saldoMari > widget.resumo.saldoBiel) {
      result = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
          .format(widget.resumo.saldoMari - widget.resumo.saldoBiel);

      newReceiverColor = ThemeColors.colorMari;
      textBalance = "Biel deve $result para Mari";
    } else {
      newReceiverColor = Colors.white;
      textBalance = "Tudo zerado !";
    }

    setState(() {
      receiverColor = newReceiverColor;
    });

    return textBalance;
  }
}

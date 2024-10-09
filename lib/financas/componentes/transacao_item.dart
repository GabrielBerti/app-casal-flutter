import 'package:app_casal_flutter/financas/models/transacao.dart';
import 'package:app_casal_flutter/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransacaoItem extends StatelessWidget {
  final Transacao transacao;

  const TransacaoItem({super.key, required this.transacao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity, // Ocupará toda a largura disponível
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 88, 90, 94),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Espaçamento interno
            child: Row(
              children: [
                Icon(
                  Icons.attach_money_outlined,
                  size: 42,
                  color: transacao.tipo == "BIEL"
                      ? ThemeColors.colorBiel
                      : ThemeColors.colorMari,
                ),
                const SizedBox(
                    width: 8.0), // Espaçamento entre o ícone e o texto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transacao.descricao,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(transacao.data),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      transacao.valor.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.white,
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
}

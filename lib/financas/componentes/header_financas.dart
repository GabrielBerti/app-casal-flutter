import 'package:flutter/material.dart';

class HeaderFinancas extends StatelessWidget {
  const HeaderFinancas({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity, // Ocupará toda a largura disponível
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 88, 90, 94),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0), // Espaçamento interno
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Align(
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
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Mari",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "RS 200,00",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "RS 300,00",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Biel deve RS 500,00 para Mari",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
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
}

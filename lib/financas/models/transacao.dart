import 'package:app_casal_flutter/financas/models/tipo.dart';

class Transacao {
  int? id = 0;
  String descricao = "";
  double valor = 0.0;
  Tipo tipo = Tipo.biel;
  DateTime data = DateTime.now();

  Transacao(
      {this.id,
      required this.valor,
      required this.descricao,
      required this.tipo,
      required this.data});

  factory Transacao.fromJson(Map<String, dynamic> json) {
    Tipo typeTransaction = Tipo.values.firstWhere(
      (tipo) => tipo.name.toUpperCase().split('.').last == json['tipo'],
      orElse: () => Tipo.mari,
    );

    return Transacao(
        id: json['id'],
        descricao: json['descricao'],
        valor: json['valor'],
        tipo: typeTransaction,
        data: DateTime.parse(json['data']));
  }
}

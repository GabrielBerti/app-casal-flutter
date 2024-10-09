class Transacao {
  int id = 0;
  String descricao = "";
  double valor = 0.0;
  String tipo = "";
  DateTime data = DateTime.now();

  Transacao(
      {id,
      required this.valor,
      required this.descricao,
      required this.tipo,
      required this.data});

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
        id: json['id'],
        descricao: json['descricao'],
        valor: json['valor'],
        tipo: json['tipo'],
        data: DateTime.parse(json['data']));
  }
}

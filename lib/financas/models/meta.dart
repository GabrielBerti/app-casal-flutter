class Meta {
  int? id = 0;
  String descricao = "";
  bool concluido = false;

  Meta({this.id, required this.descricao, required this.concluido});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'],
      descricao: json['descricao'],
      concluido: json['concluido'],
    );
  }
}

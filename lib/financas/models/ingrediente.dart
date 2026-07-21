class Ingrediente {
  int? id;
  String descricao;
  bool marcado;

  Ingrediente({
    this.id,
    required this.descricao,
    required this.marcado,
  });

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      id: json['id'],
      descricao: json['descricao'],
      marcado: json['marcado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'marcado': marcado,
    };
  }
}

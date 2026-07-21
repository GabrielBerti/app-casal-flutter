import 'ingrediente.dart';

class Receita {
  final int? id;
  final String? nome;
  final String? descricao;
  final List<Ingrediente> ingredientes;

  Receita({
    this.id,
    this.nome,
    this.descricao,
    this.ingredientes = const [],
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      ingredientes: (json['ingredientes'] as List<dynamic>? ?? [])
          .map((e) => Ingrediente.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ingredientes': ingredientes.map((e) => e.toJson()).toList(),
    };
  }
}

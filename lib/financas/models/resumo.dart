class Resumo {
  double saldoBiel = 0.0;
  double saldoMari = 0.0;

  Resumo({required this.saldoBiel, required this.saldoMari});

  factory Resumo.fromJson(Map<String, dynamic> json) {
    return Resumo(saldoBiel: json['saldoBiel'], saldoMari: json['saldoMari']);
  }
}

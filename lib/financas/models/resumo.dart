class Resumo {
  double saldoBiel = 0.0;
  double saldoMari = 0.0;

  Resumo({required this.saldoBiel, required this.saldoMari});

  factory Resumo.fromJson(Map<String, dynamic> json) {
    double saldoBiel = json['saldoBiel'] ?? 0.0;
    double saldoMari = json['saldoMari'] ?? 0.0;

    return Resumo(saldoBiel: saldoBiel, saldoMari: saldoMari);
  }
}

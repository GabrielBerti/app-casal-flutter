import 'package:app_casal_flutter/financas/models/transacao.dart';
import 'package:app_casal_flutter/financas/services/financas_endpoints.dart';
import 'package:app_casal_flutter/financas/services/financas_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class FinancasService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: FinancasEndpoints.devBaseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  FinancasService() {
    _dio.interceptors.add(FinancasInterceptor());
  }

  Future<List<Transacao>?> getTransactions() async {
    try {
      Response response = await _dio.get(_dio.options.baseUrl);
      // await _dio.get('https://jsonplaceholder.typicode.com/posts/1');

      // print(response.statusCode);
      // print(response.headers.toString());
      // print(response.data);
      // print(response.data.runtimeType);

      if (response.statusCode == 200) {
        List<Transacao> transacoes = (response.data as List)
            .map((item) => Transacao.fromJson(item))
            .toList();

        return transacoes;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar transações: $e');
      return null;
    }
  }

  Future<Transacao?> addTransaction(Transacao newTransaction) async {
    try {
      Map<String, dynamic> data = {
        'data': DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .format(newTransaction.data),
        'descricao': newTransaction.descricao,
        'tipo': newTransaction.tipo.toUpperCase(),
        'valor': newTransaction.valor,
      };

      Response response = await _dio.post(_dio.options.baseUrl, data: data);

      if (response.statusCode == 201) {
        Transacao transaction = Transacao.fromJson(response.data);
        return transaction;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao inserir transação: $e');
      return null;
    }
  }

  // Future<void> clearServerData() async {
  //   await _dio.delete(FinancasEndpoints.listins);
  // }
}

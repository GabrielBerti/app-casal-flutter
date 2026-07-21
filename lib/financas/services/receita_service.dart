import 'package:dio/dio.dart';
import 'package:app_casal_flutter/financas/services/endpoint_interceptor.dart';
import 'package:app_casal_flutter/financas/services/url_base_endpoints.dart';
import '../models/receita.dart';

class ReceitaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlBaseEndpoints.baseUrlReceitas,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  ReceitaService() {
    _dio.interceptors.add(EndpointInterceptor());
  }

  /// GET /api/receitas
  Future<List<Receita>> recuperaReceitas({String? search}) async {
    final response = await _dio.get(
      _dio.options.baseUrl,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return (response.data as List)
        .map((json) => Receita.fromJson(json))
        .toList();
  }

  /// POST /api/receitas
  Future<Receita> insereReceita(Receita receita) async {
    final response = await _dio.post(
      _dio.options.baseUrl,
      data: _toRequest(receita),
    );

    return Receita.fromJson(response.data);
  }

  /// PUT /api/receitas/{id}
  Future<Receita> alteraReceita(Receita receita) async {
    if (receita.id == null) {
      throw Exception('Receita sem id.');
    }

    final response = await _dio.put(
      '${_dio.options.baseUrl}/${receita.id}',
      data: _toRequest(receita),
    );

    return Receita.fromJson(response.data);
  }

  /// DELETE /api/receitas/{id}
  Future<void> deletaReceita(int id) async {
    await _dio.delete('${_dio.options.baseUrl}/$id');
  }

  Map<String, dynamic> _toRequest(Receita receita) {
    return {
      'id': receita.id,
      'nome': receita.nome,
      'descricao': receita.descricao,
    };
  }
}

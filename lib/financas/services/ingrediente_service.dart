import 'package:dio/dio.dart';

import '../models/ingrediente.dart';
import '../models/receita.dart';
import 'package:app_casal_flutter/financas/services/endpoint_interceptor.dart';
import 'package:app_casal_flutter/financas/services/url_base_endpoints.dart';

class IngredienteService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlBaseEndpoints.baseUrlIngredientes,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  IngredienteService() {
    _dio.interceptors.add(EndpointInterceptor());
  }

  /// GET /api/ingredientes/{receitaId}
  Future<List<Ingrediente>> recuperaIngredientesByReceitaId(
    int receitaId,
  ) async {
    final response = await _dio.get(
      '${_dio.options.baseUrl}/$receitaId',
    );

    return (response.data as List)
        .map((json) => Ingrediente.fromJson(json))
        .toList();
  }

  /// POST /api/ingredientes
  Future<void> insereIngrediente(
    List<Ingrediente> ingredientes,
    Receita receita,
  ) async {
    final body = ingredientes.map((e) => _toRequest(e, receita)).toList();

    await _dio.post(
      _dio.options.baseUrl,
      data: body,
    );
  }

  /// PUT /api/ingredientes/{id}
  Future<void> alteraIngrediente(
    Ingrediente ingrediente,
    Receita receita,
  ) async {
    await _dio.put(
      '${_dio.options.baseUrl}/${ingrediente.id}',
      data: _toRequest(
        ingrediente,
        receita,
      ),
    );
  }

  /// PUT /api/ingredientes/marcou/{id}/{marcado}
  Future<void> marcarDesmarcarIngrediente(
    int id,
    bool marcado,
  ) async {
    await _dio.put(
      '${_dio.options.baseUrl}/marcou/$id/$marcado',
    );
  }

  /// PUT /api/ingredientes/desmarcarTodos/{receitaId}
  Future<void> desmarcarTodosIngredientes(
    int receitaId,
  ) async {
    await _dio.put(
      '${_dio.options.baseUrl}/desmarcarTodos/$receitaId',
    );
  }

  /// DELETE /api/ingredientes/{id}
  Future<void> deletaIngrediente(
    int id,
  ) async {
    await _dio.delete(
      '${_dio.options.baseUrl}/$id',
    );
  }

  Map<String, dynamic> _toRequest(
    Ingrediente ingrediente,
    Receita receita,
  ) {
    return {
      'id': ingrediente.id,
      'descricao': ingrediente.descricao,
      'marcado': ingrediente.marcado,
      'receita': {
        'id': receita.id,
        'nome': receita.nome,
        'descricao': receita.descricao,
      },
    };
  }
}

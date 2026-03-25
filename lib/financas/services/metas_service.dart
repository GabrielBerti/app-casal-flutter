import 'package:app_casal_flutter/financas/models/meta.dart';
import 'package:app_casal_flutter/financas/services/url_base_endpoints.dart';
import 'package:app_casal_flutter/financas/services/endpoint_interceptor.dart';
import 'package:dio/dio.dart';

class MetasService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlBaseEndpoints.baseUrlMetas,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  MetasService() {
    _dio.interceptors.add(EndpointInterceptor());
  }

  Future<List<Meta>?> getMetas() async {
    try {
      Response response = await _dio.get(_dio.options.baseUrl);

      if (response.statusCode == 200) {
        List<Meta> metas =
            (response.data as List).map((item) => Meta.fromJson(item)).toList();

        return metas;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar metas: $e');
      return null;
    }
  }

  Future<Meta?> addMeta(Meta newMeta) async {
    try {
      Map<String, dynamic> data = {
        'descricao': newMeta.descricao,
        'concluido': newMeta.concluido,
      };

      Response response = await _dio.post(_dio.options.baseUrl, data: data);

      if (response.statusCode == 201) {
        Meta meta = Meta.fromJson(response.data);
        return meta;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao inserir meta: $e');
      return null;
    }
  }

  Future<Meta?> updateMeta(Meta metaUpdate) async {
    try {
      Map<String, dynamic> data = {
        'id': metaUpdate.id,
        'descricao': metaUpdate.descricao,
        'concluido': metaUpdate.concluido,
      };

      Response response = await _dio
          .put('${_dio.options.baseUrl}/${metaUpdate.id}', data: data);

      if (response.statusCode == 200) {
        Meta meta = Meta.fromJson(response.data);
        return meta;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao alterar meta: $e');
      return null;
    }
  }

  Future<bool> removeMeta(String idTransaction) async {
    try {
      Response response =
          await _dio.delete('${_dio.options.baseUrl}/$idTransaction');

      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro ao remover transação: $e');
      return false;
    }
  }
}

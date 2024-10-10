import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/web.dart';

class FinancasInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: false,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String log = "";
    log += "REQUISIÇÃO\n";
    log += "Timestamp: ${DateTime.now()}\n";
    log += "Método: ${options.method}\n";
    log += "URL: ${options.uri}\n";
    log +=
        "Cabeçalho: ${const JsonEncoder.withIndent("  ").convert(options.headers)}\n";

    // if (options.data != null) {
    //   try {
    //     log +=
    //         "Corpo: ${const JsonEncoder.withIndent("  ").convert(json.decode(options.data.toString()))}\n";
    //   } catch (e) {
    //     log += "Corpo: ${options.data}\n";
    //   }
    // } else {
    //   log += "Corpo: null\n";
    // }

    _logger.w(log);
    super.onRequest(options, handler);
  }
}

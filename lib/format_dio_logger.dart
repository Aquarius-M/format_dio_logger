import 'dart:math' as math;
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// dio打印
class FormatDioLogger extends Interceptor {
  FormatDioLogger({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseBody = true,
    this.responseHeader = false,
    this.maxWidth = 90,
    this.logPrint = print,
    this.error = true,
  });

  /// 打印请求，如果此字段为false，则[requestHeader]和[requestBody]也不会打印
  bool request;

  /// 打印请求头 [Options.headers]
  bool requestHeader;

  /// 打印请求参数 [Options.data]
  bool requestBody;

  /// 打印响应 [Response.data]，如果此字段为false，则[responseHeader]也不会打印
  bool responseBody;

  /// 打印响应头部 [Response.headers]
  bool responseHeader;

  /// 打印错误信息
  bool error;

  /// 打印最大宽度，超出则换行
  final int maxWidth;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  final void Function(String object) logPrint;

  static const String _errorColor = "\x1b[38;5;196m";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      // 打印请求方式和api地址
      _printBoxHeader(header: 'Request ║ ${options.method} ╠', text: options.uri.toString());
      // 打印请求头
      if (requestHeader) {
        _printSubHeader(header: "Header");
        final requestHeaders = <String, dynamic>{};
        requestHeaders.addAll(options.headers);
        requestHeaders['responseType'] = options.responseType.toString();
        requestHeaders['followRedirects'] = options.followRedirects;
        _printMap(requestHeaders);
      }
      // 打印请求体
      if (requestBody) {
        // 打印Query Parameters数据
        if (options.queryParameters.isNotEmpty) {
          _printSubHeader(header: "Query Parameters");
          logPrint("║${_prettyJson(options.queryParameters).replaceAll("\n", "\n║")}");
        }
        // 打印 data 数据
        if (options.data != null) {
          _printSubHeader(header: "Body Data");
          final dynamic data = options.data;
          if (data is FormData) {
            final formDataMap = <String, dynamic>{}
              ..addEntries(data.fields)
              ..addEntries(data.files);
            _printMap(formDataMap);
          } else {
            _print("║${_prettyJson(data).replaceAll("\n", "\n║")}");
          }
        }
      }
    }
    _printLine(pre: "╚");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (responseBody) {
      _printBoxHeader(
        header: "Response ║ ${response.requestOptions.method} ║ Status: ${response.statusCode} ${response.statusMessage} ╠",
        text: response.requestOptions.uri.toString(),
      );
      if (responseHeader) {
        _printSubHeader(header: "Header");
        final responseHeaders = <String, String>{};
        response.headers.forEach((k, list) => responseHeaders[k] = list.toString());
        _printMap(responseHeaders);
      }
      _printSubHeader(header: "Body");
      _printResponseBody(response);
    }
    _printLine(pre: "╚");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (error) {
      _printBoxHeader(
        header: "Error ║ code: [${err.response?.statusCode}] message: [${err.response?.statusMessage}] ╠",
        text: err.requestOptions.uri.toString(),
        color: _errorColor,
      );
      _printSubHeader(header: "Detail", color: _errorColor,);
      _print("$_errorColor║ type: ${err.type}\x1b[0m");
      _print("$_errorColor║ msg: ${err.error}\x1b[0m");
      _printLine(pre: "╚", color: _errorColor);
    }
    super.onError(err, handler);
  }

  /// 打印响应体
  void _printResponseBody(Response response) {
    String data = _prettyJson(response.data).replaceAll("\n", "\n║");
    List<String> list = data.split("\n║");
    for (var value in list) {
      if (value.length > maxWidth) {
        // 获取当前缩进字符
        String space = value.substring(0, value.indexOf('"'));
        // 截取文本的缩进字符，由打印输出
        value = value.substring(value.indexOf('"'));
        // 获取最大宽度 - 缩进字符宽度，还剩多少宽度
        final lineWidth = maxWidth - space.length;
        // 获取当前文本至少需要几行
        final lines = (value.length / lineWidth).ceil();
        for (int i = 0; i < lines; i++) {
          int start = i * lineWidth;
          int end = math.min<int>((i + 1) * lineWidth, value.length);
          _print("║$space${value.substring(start, end)}");
        }
      } else {
        _print("║$value");
      }
    }
  }

  /// 打印盒子头部
  void _printBoxHeader({String? header, String? text, String? color}) {
    header = '╔╣ $header';
    _print('${color ?? ''}$header${'═' * (maxWidth - header.length)}╗\x1b[0m');
    _print('${color ?? ''}╟  $text\x1b[0m');
  }

  /// 打印副头部
  void _printSubHeader({String? header, String? color}) {
    String body = '╠═ $header ';
    _print("${color ?? ''}$body${'┄' * (maxWidth - body.length)}\x1b[0m");
  }

  /// 打印整个map数据
  void _printMap(Map? map) {
    if (map?.isEmpty ?? true) return;
    map?.forEach((key, value) => _printKV(key, value));
  }

  /// 打印key: value值
  void _printKV(String? key, Object? v) {
    final pre = '╟ $key: ';
    final msg = v.toString();
    _print('$pre$msg');
  }

  /// 打印分割线
  void _printLine({String pre = '', String suf = '╝', String? color}) {
    _print('${color ?? ''}$pre${'═' * (maxWidth - 1)}$suf\x1b[0m');
  }

  void _print(String msg) {
    if (kDebugMode) {
      logPrint(msg);
    }
  }
}

/// 创建多行 JSON
String _prettyJson(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

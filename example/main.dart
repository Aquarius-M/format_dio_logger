import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:format_dio_logger/format_dio_logger.dart';

void main()async {
  final dio = Dio()..interceptors.add(FormatDioLogger());

  try {
    await dio.get('https://run.mocky.io/v3/4687f3cb-2b88-4782-8fea-3d0fbae1c76a');
  } catch (e) {
    debugPrint(e.toString());
  }
}
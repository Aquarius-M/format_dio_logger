import 'package:dio/dio.dart';
import 'package:example/my_button.dart';
import 'package:flutter/material.dart';
import 'package:format_dio_logger/format_dio_logger.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Dio dio;

  @override
  void initState() {
    dio = Dio()..interceptors.add(FormatDioLogger());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("测试"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            MyButton(
              onTap: () {
                dio.get(
                  "https://run.mocky.io/v3/2943e324-75f3-4471-a5a4-ba8886b755e6",
                  queryParameters: {
                    "name": "xxx",
                  },
                );
              },
              text: "接口正常响应",
            ),
            MyButton(
              onTap: () {
                dio.get(
                  "https://www.baidu.com/",
                  options: Options(
                    responseType: ResponseType.plain,
                  ),
                );
              },
              text: "接口正常响应，非json返回数据",
            ),
            MyButton(
              onTap: () {
                dio.get(
                  "https://run.mocky.io/v3/34c80cf8-e2b2-4a08-b245-b38c8fb66a00",
                  options: Options(
                    responseType: ResponseType.plain,
                  ),
                );
              },
              text: "接口正常响应，非json返回长数据",
            ),
            MyButton(
              onTap: () {
                dio.get("https://run.mocky.io/v3/f4c30d34-fb3a-4e22-9f01-bcb7c445f9e5");
              },
              text: "接口错误响应",
            ),
          ],
        ),
      ),
    );
  }
}

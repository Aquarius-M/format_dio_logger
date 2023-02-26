# FormatDioLogger

FormatDioLogger是一个Dio拦截器，将请求、响应与错误以盒子的形状，易于阅读的格式输出在控制台。

## 目前使用版本

flutter  `3.3.2`

dio `5.0`
 
## 用法

只需要将FormatDioLogger添加到Dio拦截器中，如下：

```Dart
  final dio = Dio()..interceptors.add(FormatDioLogger());

  try {
    await dio.get('https://run.mocky.io/v3/4687f3cb-2b88-4782-8fea-3d0fbae1c76a');
  } catch (e) {
    debugPrint(e.toString());
  }
```
## 输出

![response](/images/response.png)
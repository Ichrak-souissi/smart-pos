import 'package:dio/dio.dart';


class AuthInterceptor implements Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    handler.next(options);
  }

  @override
  void onError( err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
    }
  }
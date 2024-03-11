import 'package:dio/dio.dart';
import 'package:pos/constants.dart';

import 'auth_interceptor.dart';

class ClientDio {
  final Dio dio;

  ClientDio() : dio = Dio(BaseOptions(baseUrl: Constants.getLoginUrl())) {
    addInterceptor(AuthInterceptor());
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}

class Constants {
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const String loginEndpoint = '/users/login';


  static String getLoginUrl() => '$baseUrl$loginEndpoint';
}

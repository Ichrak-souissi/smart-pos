class Constants {
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const String loginEndpoint = '/users/login';
  static const String tableEndpoint = '/table';

  static String getBaseUrl() => baseUrl;
  static String getLoginUrl() => '$baseUrl$loginEndpoint';
  static String getTableUrl() => '$baseUrl$tableEndpoint';
}

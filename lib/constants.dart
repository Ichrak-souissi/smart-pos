class Constants {
  //endpoints :table
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const String loginEndpoint = '/users/login';
  static const String tableEndpoint = '/table';
  static const String addTableEndpoint = '/table/add';
  static const String updateTableEndpoint = '/table/{id}';
  //endpoints :catgory
  static const String categoryEndpoint = '/category';

//urls: table
  static String getBaseUrl() => baseUrl;
  static String getLoginUrl() => '$baseUrl$loginEndpoint';
  static String getTableUrl() => '$baseUrl$tableEndpoint';
  static String addTableUrl() => '$baseUrl$addTableEndpoint';
  static String updateTableUrl() => '$baseUrl$updateTableEndpoint';
//urls : category
  static String getCategoryUrl() => '$baseUrl$categoryEndpoint';

}

class Constants {
  static const String baseUrl = 'http://127.0.0.1:3000';
 
  //Endpoints pour la gestion des room 
  static const String roomEndpoint ='/room';

  // Endpoints pour la gestion des tables
  static const String loginEndpoint = '/users/login';
  static const String tableEndpoint = '/table';
  static const String addTableEndpoint = '/table/add';
  static const String updateTableEndpoint = '/table/{id}';
  static const String tablesByRoomIdEndpoint = '/room/{id}/tables';

    // Endpoints pour la gestion des ingrédient 
    static const ingredientEndpoint='/ingredient';
    static const updateIngredientEndpoint='/ingredient';

  //  static const String ingredientByItemIdEndpoint='/item/{id}/ingredients';

  //Enpoints pour la gestion des suppléments 
      static const supplementEndpoint='/supplement';

  // Endpoints pour la gestion des catégories
  static const String categoryEndpoint = '/category';
  static const String itemsByCategoryIdEndpoint = '/category/{id}/items';
  
  // Endpoints pour la gestion des items
  static const String itemEndpoint = '/item';
    static const String addItemEndpoint = '/item/add';

  // URLs pour les endpoints liés aux tables
  static String getBaseUrl() => baseUrl;
  static String getLoginUrl() => '$baseUrl$loginEndpoint';
  static String getTableUrl() => '$baseUrl$tableEndpoint';
  static String addTableUrl() => '$baseUrl$addTableEndpoint';
  static String updateTableUrl(String id) => '$baseUrl${updateTableEndpoint.replaceFirst('{id}', id)}';
  static String getTablesByRoomIdUrl(String id) => '$baseUrl$tableEndpoint/room/$id';

  
  // URLs pour les endpoints liés aux catégories
  static String getCategoryUrl() => '$baseUrl$categoryEndpoint';
static String getItemsByCategoryIdUrl(String id) => '$baseUrl$itemEndpoint/category/$id';
  
  // URLs pour les endpoints liés aux items
  static String getItemUrl() => '$baseUrl$itemEndpoint';
  static String addItemUrl() =>'$baseUrl$addItemEndpoint';
static String getIngredientByItemIdUrl(String id) => '$baseUrl$ingredientEndpoint/item/$id';

    // URLs pour les endpoints liés aux ingrédient
  static String getUpdateIngredientUrl(String string) => '$baseUrl$updateIngredientEndpoint';

//Urls pour les endpoints liés au suppléments 
  static String getSupplementByItemIdUrl(String string) =>'$baseUrl$supplementEndpoint';
//Urls pour les endpoints des étages 
  static String getRoomUrl() => '$baseUrl$roomEndpoint';


}

class AppConstants {
  static const String baseUrl = 'http://192.168.1.7:3001/api/users/';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Auth endpoints
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String profile = '/auth/profile';

  // User endpoints
  static const String users = '${baseUrl}users';
  static String userById(String id) => '/users/$id';
}

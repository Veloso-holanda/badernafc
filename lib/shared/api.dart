abstract final class Api {
  // Mude para true quando quiser apontar para produção
  static const bool apiLocal = true;

  // Emulador Android: use 10.0.2.2 | Device físico: use o IP da rede local
  static const String _urlLocal = 'http://192.168.100.8:3000';
  static const String _urlProd = 'https://api.badernafc.com.br';

  static String get baseUrl => apiLocal ? _urlLocal : _urlProd;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Headers padrão
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}

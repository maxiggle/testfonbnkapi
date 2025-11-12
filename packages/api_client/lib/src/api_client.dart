import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:authentication_repository/authentication_repository.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required AuthenticationRepository authRepository,
  }) : _authRepository = authRepository;

  final String baseUrl;
  final AuthenticationRepository _authRepository;
  String _buildQueryString(Map<String, String>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) return '';
    final sortedEntries = queryParams.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final queryString = _buildQueryString(queryParams);
    final endpointWithQuery = queryString.isEmpty
        ? endpoint
        : '$endpoint?$queryString';

    final headers = _authRepository.generateHeaders(
      endpoint: endpointWithQuery,
    );

    final url = Uri.parse('$baseUrl$endpointWithQuery');
    final response = await http.get(url, headers: headers);
    return response;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    final queryString = _buildQueryString(queryParams);
    final endpointWithQuery = queryString.isEmpty
        ? endpoint
        : '$endpoint?$queryString';

    final headers = _authRepository.generateHeaders(
      endpoint: endpointWithQuery,
    );

    final url = Uri.parse('$baseUrl$endpointWithQuery');

    print('Making POST request to: $url');
    print('Headers: $headers');

    final response = await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return response;
  }
}

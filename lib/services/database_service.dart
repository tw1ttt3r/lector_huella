import 'package:libsql_dart/libsql_dart.dart';

class DatabaseService {
  late LibsqlClient _client;
  bool _isInitialized = false;

  Future<void> initialize(String url, String authToken) async {
    _client = LibsqlClient(
      url,
      authToken: authToken.isNotEmpty ? authToken : null,
    );
    _isInitialized = true;
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<Object?>? args,
  ]) async {
    if (!_isInitialized) throw Exception('Database not initialized');

    try {
      final result = await _client.query(sql, positional: args ?? []);
      return result;
    } catch (e) {
      print('Database query error: $e');
      throw Exception('Database operation failed: $e');
    }
  }

  Future<int> execute(String sql, [List<Object?>? args]) async {
    if (!_isInitialized) throw Exception('Database not initialized');

    try {
      final result = await _client.execute(sql, positional: args ?? []);
      return result;
    } catch (e) {
      print('Database execute error: $e');
      throw Exception('Database operation failed: $e');
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _client.dispose();
      _isInitialized = false;
    }
  }
}

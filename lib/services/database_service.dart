import 'package:libsql_dart/libsql_dart.dart';

class DatabaseService {
  late LibsqlClient _client;
  bool _isInitialized = false;

  Future<void> initialize(String url, String authToken) async {
    try {
      _client = LibsqlClient(
        url
      )..authToken = authToken.isNotEmpty ? authToken : null;

      // Crear conexión con turso
      await _client.connect();

      // Intenta una consulta simple para forzar conexión
      await _client.execute('SELECT 1');

      _isInitialized = true;
      print('Conexión establecida correctamente');
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      throw Exception('Fallo al conectar con la base de datos');
    }
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

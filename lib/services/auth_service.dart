import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'database_service.dart';
import '../models/models.dart';

class AuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final DatabaseService _dbService;

  AuthService(this._dbService);

  Future<bool> checkBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      print('Biométricos disponibles: $biometrics');
      
      if (biometrics.contains(BiometricType.strong)) {
        print('Autenticación fuerte disponible');
      }

      return true;
    } catch (e) {
      print('Error al verificar biométricos: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
  try {
    final canAuthenticate = await _localAuth.canCheckBiometrics 
        || await _localAuth.isDeviceSupported();
    
    if (!canAuthenticate) return false;

    return await _localAuth.authenticate(
      localizedReason: 'Autentícate para acceder',
      options: const AuthenticationOptions(
        biometricOnly: true,
        useErrorDialogs: true,
        stickyAuth: true,
      ),
      authMessages: const [
        AndroidAuthMessages(
          biometricHint: '',
          cancelButton: 'Cancelar',
          signInTitle: 'Autenticación requerida',
        ),
      ],
    );
  } on PlatformException catch (e) {
    print('Error de autenticación: ${e.message}');
    return false;
  }
}

  Future<User?> getUserByFingerprint(String fingerprintData) async {
    try {
      final results = await _dbService.query(
        'SELECT * FROM users WHERE fingerprint_data = ?',
        [fingerprintData],
      );

      if (results.isEmpty) return null;

      return User.fromMap(results.first);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<bool> hasPreviousAccess(int userId) async {
    try {
      final results = await _dbService.query(
        'SELECT COUNT(*) as count FROM access_logs WHERE user_id = ?',
        [userId],
      );

      return (results.first['count'] as int) > 0;
    } catch (e) {
      print('Error checking previous access: $e');
      return false;
    }
  }

  Future<AccessLog?> getLastAccess(int userId) async {
    try {
      final results = await _dbService.query(
        'SELECT * FROM access_logs WHERE user_id = ? ORDER BY access_time DESC LIMIT 1',
        [userId],
      );

      if (results.isEmpty) return null;

      return AccessLog.fromMap(results.first);
    } catch (e) {
      print('Error getting last access: $e');
      return null;
    }
  }

  Future<void> logAccess(int? userId) async {
    try {
      await _dbService.execute('INSERT INTO access_logs (user_id) VALUES (?)', [
        userId,
      ]);
    } catch (e) {
      print('Error logging access: $e');
    }
  }

  Future<bool> registerUser({
    required String fingerprintData,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
  }) async {
    try {
      final existingUser = await getUserByFingerprint(fingerprintData);
      if (existingUser != null) return false;

      await _dbService.execute(
        '''
        INSERT INTO users 
        (fingerprint_data, first_name, paternal_last_name, maternal_last_name) 
        VALUES (?, ?, ?, ?)
        ''',
        [fingerprintData, firstName, paternalLastName, maternalLastName],
      );

      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  final AuthService authService;

  const AuthScreen({super.key, required this.authService});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _message = 'Presiona el botón para autenticarte';
  bool _isAuthenticating = false;
  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final hasBiometrics = await widget.authService.checkBiometrics();
    setState(() {
      _hasBiometrics = hasBiometrics;
      if (!hasBiometrics) {
        _message = 'Dispositivo no compatible con autenticación biométrica';
      }
    });
  }

  Future<void> _authenticate() async {
    if (!_hasBiometrics || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _message = 'Autenticando...';
    });

    try {
      final isAuthenticated = await widget.authService.authenticate();

      if (!isAuthenticated) {
        setState(() {
          _message = 'Autenticación fallida o cancelada';
        });
        return;
      }

      // Simulamos obtener datos de huella digital (en una app real, esto vendría del sensor)
      const simulatedFingerprintData = 'simulated_fingerprint_data';

      final user = await widget.authService.getUserByFingerprint(
        simulatedFingerprintData,
      );

      if (user == null) {
        await widget.authService.logAccess(null);
        setState(() {
          _message = 'Usuario no registrado';
        });
        return;
      }

      final hasPreviousAccess = await widget.authService.hasPreviousAccess(
        user.id,
      );
      await widget.authService.logAccess(user.id);

      if (hasPreviousAccess) {
        final lastAccess = await widget.authService.getLastAccess(user.id);
        final formattedDate = DateFormat(
          'dd/MM/yyyy HH:mm',
        ).format(lastAccess!.accessTime);

        setState(() {
          _message = '${user.fullName} - Registro previo el $formattedDate';
        });
      } else {
        setState(() {
          _message = 'Bienvenido ${user.fullName} - Primer acceso';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticación por Huella Digital'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          RegisterScreen(authService: widget.authService),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80),
            const SizedBox(height: 20),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            if (_hasBiometrics)
              ElevatedButton.icon(
                icon:
                    _isAuthenticating
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.fingerprint),
                label: Text(
                  _isAuthenticating ? 'Autenticando...' : 'Autenticar',
                ),
                onPressed: _isAuthenticating ? null : _authenticate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

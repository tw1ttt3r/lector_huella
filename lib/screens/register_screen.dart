import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _paternalLastNameController = TextEditingController();
  final _maternalLastNameController = TextEditingController();
  bool _isRegistering = false;
  String _message = '';
  bool _fingerprintRegistered = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    super.dispose();
  }

  Future<void> _registerFingerprint() async {
    setState(() {
      _isRegistering = true;
      _message = 'Toque el sensor de huella digital...';
    });

    try {
      final isAuthenticated = await widget.authService.authenticate();

      if (!isAuthenticated) {
        setState(() {
          _message = 'Registro de huella cancelado o fallido';
          _fingerprintRegistered = false;
        });
        return;
      }

      setState(() {
        _message = 'Huella digital registrada con éxito';
        _fingerprintRegistered = true;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _fingerprintRegistered = false;
      });
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_fingerprintRegistered) {
      setState(() {
        _message = 'Debes registrar una huella digital primero';
      });
      return;
    }

    setState(() {
      _isRegistering = true;
      _message = 'Registrando usuario...';
    });

    try {
      // En una app real, aquí obtendrías los datos reales del sensor de huella
      const simulatedFingerprintData = 'simulated_fingerprint_data';

      final success = await widget.authService.registerUser(
        fingerprintData: simulatedFingerprintData,
        firstName: _firstNameController.text,
        paternalLastName: _paternalLastNameController.text,
        maternalLastName: _maternalLastNameController.text,
      );

      if (success) {
        _message = 'Usuario registrado con éxito';
        Navigator.pop(context);
      } else {
        _message = 'Error: La huella digital ya está registrada';
      }
    } catch (e) {
      _message = 'Error al registrar: $e';
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre(s)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _paternalLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido Paterno',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido paterno';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _maternalLastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido Materno',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido materno';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon:
                    _fingerprintRegistered
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.fingerprint),
                label: const Text('Registrar Huella Digital'),
                onPressed: _isRegistering ? null : _registerFingerprint,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color:
                          _message.contains('Error')
                              ? Colors.red
                              : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegistering ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    _isRegistering
                        ? const CircularProgressIndicator()
                        : const Text('Completar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

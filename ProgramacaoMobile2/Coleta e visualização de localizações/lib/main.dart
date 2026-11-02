import 'package:flutter/material.dart';
import 'app.dart';

/// Ponto de entrada da aplicação Flutter.
/// Inicializa os bindings necessários do framework e executa o widget raiz.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

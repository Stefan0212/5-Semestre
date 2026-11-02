import 'package:flutter_test/flutter_test.dart';
import 'package:trabalho_flutter/app.dart';

void main() {
  testWidgets('Verifica renderização da tela inicial da aplicação', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    // Verifica se a tela inicial e os botões principais são renderizados
    expect(find.text('Coleta de Localizações'), findsOneWidget);
    expect(find.text('Iniciar coleta'), findsOneWidget);
    expect(find.text('Parar coleta'), findsOneWidget);
    expect(find.text('Consultar histórico'), findsOneWidget);
    expect(find.text('Ver mapa'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:trabalho_flutter/features/localizacoes/models/localizacao.dart';

void main() {
  group('Localizacao Model Testes', () {
    test('Conversão para Map e a partir de Map mantém fidelidade', () {
      final instante = DateTime.utc(2026, 11, 2, 14, 30, 0);
      final loc = Localizacao(
        id: 1,
        latitude: -23.550520,
        longitude: -46.633308,
        precisao: 4.8,
        instante: instante,
      );

      final map = loc.toMap();
      expect(map['id'], 1);
      expect(map['latitude'], -23.550520);
      expect(map['longitude'], -46.633308);
      expect(map['precisao'], 4.8);
      expect(map['instante'], '2026-11-02T14:30:00.000Z');

      final locRecriada = Localizacao.fromMap(map);
      expect(locRecriada.id, loc.id);
      expect(locRecriada.latitude, loc.latitude);
      expect(locRecriada.longitude, loc.longitude);
      expect(locRecriada.precisao, loc.precisao);
      expect(locRecriada.instante, loc.instante);
    });

    test('Formatações de 6 casas decimais e precisão com 1 casa decimal', () {
      final loc = Localizacao(
        latitude: -23.55051987,
        longitude: -46.63330812,
        precisao: 4.823,
        instante: DateTime.utc(2026, 11, 2, 12, 0, 0),
      );

      expect(loc.latitudeFormatada, '-23.550520');
      expect(loc.longitudeFormatada, '-46.633308');
      expect(loc.precisaoFormatada, '4.8 m');
    });
  });
}


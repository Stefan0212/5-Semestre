import 'package:intl/intl.dart';

/// Representa um registro tipado de localização geográfica coletada pelo aplicativo.
class Localizacao {
  final int? id;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime instante;

  const Localizacao({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.instante,
  });

  /// Converte a instância em um Map para persistência no SQLite.
  /// O instante é armazenado em formato UTC no padrão ISO 8601.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'precisao': precisao,
      'instante': instante.toUtc().toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Cria uma instância a partir de um registro obtido do SQLite.
  factory Localizacao.fromMap(Map<String, dynamic> map) {
    return Localizacao(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      precisao: (map['precisao'] as num).toDouble(),
      instante: DateTime.parse(map['instante'] as String),
    );
  }

  /// Retorna a data e hora no fuso horário local do dispositivo.
  DateTime get instanteLocal => instante.toLocal();

  /// Retorna a data e hora locais formatadas no padrão dd/MM/yyyy HH:mm:ss.
  String get instanteFormatado {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(instanteLocal);
  }

  /// Retorna a latitude formatada com 6 casas decimais.
  String get latitudeFormatada => latitude.toStringAsFixed(6);

  /// Retorna a longitude formatada com 6 casas decimais.
  String get longitudeFormatada => longitude.toStringAsFixed(6);

  /// Retorna a precisão formatada com 1 casa decimal em metros.
  String get precisaoFormatada => '${precisao.toStringAsFixed(1)} m';

  Localizacao copyWith({
    int? id,
    double? latitude,
    double? longitude,
    double? precisao,
    DateTime? instante,
  }) {
    return Localizacao(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      precisao: precisao ?? this.precisao,
      instante: instante ?? this.instante,
    );
  }

  @override
  String toString() {
    return 'Localizacao(id: $id, lat: $latitudeFormatada, lon: $longitudeFormatada, precisao: $precisaoFormatada, instante: $instanteFormatado)';
  }
}


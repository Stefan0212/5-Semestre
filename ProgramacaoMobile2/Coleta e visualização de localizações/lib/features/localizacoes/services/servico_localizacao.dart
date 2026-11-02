import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Responsável por gerenciar os serviços de localização do dispositivo,
/// verificação e solicitação de permissões, abertura de configurações e
/// fornecimento do stream contínuo de posições com suporte a serviço em primeiro plano.
class ServicoLocalizacao {
  /// Verifica se os serviços de localização (GPS) estão habilitados no aparelho.
  Future<bool> verificarServicoHabilitado() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Retorna o status atual da permissão de localização.
  Future<LocationPermission> verificarPermissao() async {
    return await Geolocator.checkPermission();
  }

  /// Solicita ao usuário as permissões de localização necessárias.
  Future<LocationPermission> solicitarPermissao() async {
    return await Geolocator.requestPermission();
  }

  /// Abre a tela de configurações do aplicativo no sistema operacional
  /// para que o usuário possa conceder permissões caso tenham sido negadas permanentemente.
  Future<bool> abrirConfiguracoes() async {
    return await Geolocator.openAppSettings();
  }

  /// Fornece o stream contínuo de posições geográficas.
  /// Configurado com alta precisão e intervalo solicitado de 20 segundos.
  /// No Android, ativa a notificação de Foreground Service para manter a coleta
  /// mesmo ao minimizar ou navegar para outras telas.
  Stream<Position> obterStreamPosicoes() {
    late final LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 20),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Coleta de Localizações Ativa',
          notificationText: 'Registrando localização a cada 20 segundos',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}


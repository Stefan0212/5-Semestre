import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import 'item_localizacao.dart';

/// Widget encapsulado para exibição do mapa interativo, renderizando
/// a camada de ruas (com cache em pasta privada), marcadores de localização
/// e destaque visual para a posição mais recente em vermelho.
class MapaLocalizacoes extends StatefulWidget {
  final List<Localizacao> localizacoes;
  final MapController mapController;
  final Directory? pastaCache;

  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.mapController,
    this.pastaCache,
  });

  @override
  State<MapaLocalizacoes> createState() => _MapaLocalizacoesState();
}

class _MapaLocalizacoesState extends State<MapaLocalizacoes> {
  Directory? _pastaCache;

  @override
  void initState() {
    super.initState();
    _pastaCache = widget.pastaCache;
    if (_pastaCache == null) {
      _carregarPastaCache();
    }
  }

  Future<void> _carregarPastaCache() async {
    final pasta = await CacheMapa.instancia.obterPastaCache();
    if (mounted) {
      setState(() {
        _pastaCache = pasta;
      });
    }
  }

  void _mostrarDetalhesPonto(BuildContext context, Localizacao localizacao, bool isMaisRecente) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ItemLocalizacao(
              localizacao: localizacao,
              destacarMaisRecente: isMaisRecente,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.localizacoes.isEmpty) {
      return const Center(
        child: Text('Nenhuma localização para exibir no mapa.'),
      );
    }

    // A lista vem ordenada da mais recente para a mais antiga
    final maisRecente = widget.localizacoes.first;
    final centroInicial = LatLng(maisRecente.latitude, maisRecente.longitude);

    final markers = <Marker>[];
    for (int i = 0; i < widget.localizacoes.length; i++) {
      final loc = widget.localizacoes[i];
      final isMaisRecente = (i == 0);
      final ponto = LatLng(loc.latitude, loc.longitude);

      markers.add(
        Marker(
          point: ponto,
          width: isMaisRecente ? 46 : 36,
          height: isMaisRecente ? 46 : 36,
          child: GestureDetector(
            onTap: () => _mostrarDetalhesPonto(context, loc, isMaisRecente),
            child: isMaisRecente
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withValues(alpha: 0.25),
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ],
                  )
                : const Icon(
                    Icons.location_on,
                    color: Colors.blueAccent,
                    size: 32,
                  ),
          ),
        ),
      );
    }

    // Provedor de tiles com cache em diretório privado se disponível
    final tileProvider = _pastaCache != null
        ? CacheMapa.instancia.criarProvedorTiles(_pastaCache!)
        : NetworkTileProvider();

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: centroInicial,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 19.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trabalho_flutter',
          tileProvider: tileProvider,
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/mapa_localizacoes.dart';

/// Tela responsável por carregar os registros de localização e gerenciar
/// os estados de espera, erro e histórico vazio antes de renderizar o mapa interativo.
class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();
  final MapController _mapController = MapController();

  List<Localizacao> _pontos = [];
  bool _carregando = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados({bool enquadrarAposCarregar = true}) async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final registros = await _repositorio.consultarUltimas(limite: 100);
      if (mounted) {
        setState(() {
          _pontos = registros;
          _carregando = false;
        });

        if (enquadrarAposCarregar && registros.isNotEmpty) {
          // Aguarda a renderização do mapa antes de ajustar o enquadramento
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _enquadrarTodosOsPontos();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemErro = 'Falha ao carregar registros para o mapa: $e';
          _carregando = false;
        });
      }
    }
  }

  /// Ajusta a câmera do mapa para que todos os pontos fiquem visíveis na tela.
  void _enquadrarTodosOsPontos() {
    if (_pontos.isEmpty) return;

    if (_pontos.length == 1) {
      final ponto = LatLng(_pontos.first.latitude, _pontos.first.longitude);
      _mapController.move(ponto, 16.0);
      return;
    }

    final coordenadas = _pontos
        .map((loc) => LatLng(loc.latitude, loc.longitude))
        .toList();

    final bounds = LatLngBounds.fromPoints(coordenadas);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interativo'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Enquadrar todos os pontos',
            icon: const Icon(Icons.center_focus_strong_rounded),
            onPressed: (_carregando || _pontos.isEmpty)
                ? null
                : _enquadrarTodosOsPontos,
          ),
          IconButton(
            tooltip: 'Atualizar pontos',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _carregando ? null : () => _carregarDados(enquadrarAposCarregar: false),
          ),
        ],
      ),
      body: _buildCorpo(theme),
      floatingActionButton: (_pontos.isNotEmpty && !_carregando)
          ? FloatingActionButton(
              heroTag: 'fab_enquadrar',
              tooltip: 'Enquadrar pontos',
              onPressed: _enquadrarTodosOsPontos,
              child: const Icon(Icons.crop_free_rounded),
            )
          : null,
    );
  }

  Widget _buildCorpo(ThemeData theme) {
    // 1. Estado de espera (Carregando)
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando posições no mapa...'),
          ],
        ),
      );
    }

    // 2. Estado de erro
    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 56, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _carregarDados(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Estado de histórico vazio
    if (_pontos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma posição para exibir',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicie a coleta de localização na tela inicial para gravar posições e visualizá-las no mapa interativo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _carregarDados(),
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Apresentação do mapa interativo
    return Stack(
      children: [
        MapaLocalizacoes(
          localizacoes: _pontos,
          mapController: _mapController,
        ),
        // Banner informativo com a contagem de pontos e legenda
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_pontos.length} pontos mapeados',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mais recente',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

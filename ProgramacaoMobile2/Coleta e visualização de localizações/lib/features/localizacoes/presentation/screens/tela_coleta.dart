import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

/// Tela inicial do aplicativo.
/// Apresenta os controles principais, gerencia a assinatura do stream de posições
/// e coordena a gravação contínua no SQLite por meio do repositório.
class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  /// Permite que outras telas verifiquem se a coleta está ativa no momento.
  static bool isColetandoAtiva = false;

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final ServicoLocalizacao _servicoLocalizacao = ServicoLocalizacao();
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  // Assinatura única do stream para evitar duplicidade
  StreamSubscription<Position>? _posicaoSubscription;

  // Controle de gravação para evitar escritas concorrentes sobrepostas
  bool _estaGravando = false;

  // Estado da UI
  bool get _isColetando => _posicaoSubscription != null;
  Localizacao? _ultimaLocalizacaoSalva;
  int _totalGravadoNestaSessao = 0;
  String? _mensagemStatus;

  @override
  void dispose() {
    _posicaoSubscription?.cancel();
    TelaColeta.isColetandoAtiva = false;
    super.dispose();
  }

  Future<void> _iniciarColeta() async {
    if (_isColetando) return;

    setState(() {
      _mensagemStatus = 'Verificando GPS e permissões...';
    });

    try {
      // 1. Verificar se o GPS / serviço de localização está habilitado
      final servicoHabilitado = await _servicoLocalizacao.verificarServicoHabilitado();
      if (!servicoHabilitado) {
        if (!mounted) return;
        _exibirDialogo(
          titulo: 'GPS Desabilitado',
          mensagem: 'O serviço de localização do aparelho está desativado. '
              'Por favor, ative o GPS para iniciar a coleta.',
          acaoBotao: 'Abrir Configurações',
          onAcao: () => _servicoLocalizacao.abrirConfiguracoes(),
        );
        setState(() {
          _mensagemStatus = 'GPS desativado.';
        });
        return;
      }

      // 2. Verificar e solicitar permissões
      var permissao = await _servicoLocalizacao.verificarPermissao();
      if (permissao == LocationPermission.denied) {
        permissao = await _servicoLocalizacao.solicitarPermissao();
        if (permissao == LocationPermission.denied) {
          if (!mounted) return;
          _exibirSnackBar(
            'Permissão de localização negada. O aplicativo necessita da permissão para coletar posições.',
            isErro: true,
          );
          setState(() {
            _mensagemStatus = 'Permissão negada.';
          });
          return;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        if (!mounted) return;
        _exibirDialogo(
          titulo: 'Permissão Necessária',
          mensagem: 'A permissão de localização foi negada permanentemente. '
              'Acesse as configurações do aplicativo para habilitá-la.',
          acaoBotao: 'Configurações',
          onAcao: () => _servicoLocalizacao.abrirConfiguracoes(),
        );
        setState(() {
          _mensagemStatus = 'Permissão negada permanentemente.';
        });
        return;
      }

      // 3. Iniciar Stream de posições a cada 20 segundos
      final stream = _servicoLocalizacao.obterStreamPosicoes();

      _posicaoSubscription = stream.listen(
        (Position posicao) async {
          await _processarNovaPosicao(posicao);
        },
        onError: (erro) {
          if (!mounted) return;
          _exibirSnackBar('Erro na coleta de localização: $erro', isErro: true);
        },
        cancelOnError: false,
      );

      TelaColeta.isColetandoAtiva = true;

      if (mounted) {
        setState(() {
          _mensagemStatus = 'Coleta ativa (intervalo: 20s).';
        });
        _exibirSnackBar('Coleta contínua iniciada com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemStatus = 'Erro ao iniciar coleta.';
        });
        _exibirSnackBar('Falha ao iniciar coleta: $e', isErro: true);
      }
    }
  }

  Future<void> _processarNovaPosicao(Position posicao) async {
    // Evita gravações concorrentes sobrepostas no SQLite
    if (_estaGravando) return;
    _estaGravando = true;

    try {
      final novaLoc = Localizacao(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        precisao: posicao.accuracy,
        instante: DateTime.now().toUtc(),
      );

      final idGerado = await _repositorio.inserir(novaLoc);
      final locSalva = novaLoc.copyWith(id: idGerado);

      if (mounted) {
        setState(() {
          _ultimaLocalizacaoSalva = locSalva;
          _totalGravadoNestaSessao++;
          _mensagemStatus = 'Coleta ativa. Último registro: #${locSalva.id}';
        });
      }
    } catch (e) {
      if (mounted) {
        _exibirSnackBar('Erro ao salvar localização no banco: $e', isErro: true);
      }
    } finally {
      _estaGravando = false;
    }
  }

  Future<void> _pararColeta() async {
    if (!_isColetando) return;

    await _posicaoSubscription?.cancel();
    _posicaoSubscription = null;
    TelaColeta.isColetandoAtiva = false;

    if (mounted) {
      setState(() {
        _mensagemStatus = 'Coleta interrompida.';
      });
      _exibirSnackBar('Coleta interrompida.');
    }
  }

  void _abrirConfiguracoes() async {
    await _servicoLocalizacao.abrirConfiguracoes();
  }

  void _navegarHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => TelaLocalizacoes(
          isColetando: _isColetando,
        ),
      ),
    );
  }

  void _navegarMapa() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const TelaMapa(),
      ),
    );
  }

  void _exibirSnackBar(String mensagem, {bool isErro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isErro ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exibirDialogo({
    required String titulo,
    required String mensagem,
    required String acaoBotao,
    required VoidCallback onAcao,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onAcao();
            },
            child: Text(acaoBotao),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleta de Localizações'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Configurações de Permissão',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _abrirConfiguracoes,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com o status da coleta
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _isColetando
                      ? Colors.green.withValues(alpha: 0.5)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isColetando
                            ? Colors.green.shade50
                            : colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        _isColetando
                            ? Icons.my_location_rounded
                            : Icons.location_off_rounded,
                        size: 34,
                        color: _isColetando
                            ? Colors.green.shade700
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isColetando ? 'Coleta em Andamento' : 'Coleta Parada',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isColetando
                            ? Colors.green.shade700
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _mensagemStatus ??
                          (_isColetando
                              ? 'Gravando coordenadas a cada 20 segundos.'
                              : 'Toque em "Iniciar coleta" para começar.'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_isColetando && _totalGravadoNestaSessao > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Registros gravados nesta sessão: $_totalGravadoNestaSessao',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Card da última localização capturada (se houver)
            if (_ultimaLocalizacaoSalva != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Último Ponto Gravado',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        'Horário: ${_ultimaLocalizacaoSalva!.instanteFormatado}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_ultimaLocalizacaoSalva!.latitudeFormatada} | '
                        'Lon: ${_ultimaLocalizacaoSalva!.longitudeFormatada}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Precisão: ${_ultimaLocalizacaoSalva!.precisaoFormatada}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Botão Iniciar Coleta
            FilledButton.icon(
              onPressed: _isColetando ? null : _iniciarColeta,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Iniciar coleta'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Parar Coleta
            OutlinedButton.icon(
              onPressed: _isColetando ? _pararColeta : null,
              icon: const Icon(Icons.stop_rounded),
              label: const Text('Parar coleta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(
                  color: _isColetando ? Colors.red.shade400 : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Botão Consultar Histórico
            FilledButton.tonalIcon(
              onPressed: _navegarHistorico,
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: const Text('Consultar histórico'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Ver Mapa
            FilledButton.tonalIcon(
              onPressed: _navegarMapa,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver mapa'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Configurações de Permissão
            TextButton.icon(
              onPressed: _abrirConfiguracoes,
              icon: const Icon(Icons.security_rounded),
              label: const Text('Configurações de permissão'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

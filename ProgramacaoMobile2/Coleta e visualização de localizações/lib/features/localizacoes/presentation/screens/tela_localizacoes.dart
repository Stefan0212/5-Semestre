import 'package:flutter/material.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';
import 'tela_coleta.dart';

/// Tela responsável por consultar e exibir as últimas 100 localizações salvas,
/// permitir atualização manual dos dados sem interromper a coleta e
/// confirmar a exclusão completa do histórico.
class TelaLocalizacoes extends StatefulWidget {
  final bool isColetando;

  const TelaLocalizacoes({
    super.key,
    this.isColetando = false,
  });

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final RepositorioLocalizacoes _repositorio = RepositorioLocalizacoes();

  List<Localizacao> _historico = [];
  bool _carregando = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final registros = await _repositorio.consultarUltimas(limite: 100);
      if (mounted) {
        setState(() {
          _historico = registros;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemErro = 'Falha ao carregar registros: $e';
          _carregando = false;
        });
      }
    }
  }

  Future<void> _confirmarExclusaoHistorico() async {
    final coletaAtiva = widget.isColetando || TelaColeta.isColetandoAtiva;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tem certeza de que deseja apagar todos os registros de localização salvos?\n\n'
              'Esta operação é permanente e não poderá ser desfeita.',
            ),
            if (coletaAtiva) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber.shade900,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A coleta está ativa no momento. Novos registros continuarão sendo salvos após a limpeza.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _executarLimpeza();
    }
  }

  Future<void> _executarLimpeza() async {
    try {
      await _repositorio.excluirTodas();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Histórico limpo com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _carregarHistorico();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar histórico: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Localizações'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _carregando ? null : _carregarHistorico,
          ),
          IconButton(
            tooltip: 'Limpar Histórico',
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: (_carregando || _historico.isEmpty)
                ? null
                : _confirmarExclusaoHistorico,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarHistorico,
        child: _buildCorpo(theme),
      ),
    );
  }

  Widget _buildCorpo(ThemeData theme) {
    if (_carregando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando localizações...'),
          ],
        ),
      );
    }

    if (_mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 54, color: Colors.red.shade400),
              const SizedBox(height: 12),
              Text(
                _mensagemErro!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarHistorico,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_historico.isEmpty) {
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
                'Nenhum registro encontrado',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicie a coleta na tela inicial para que as posições sejam registradas e exibidas aqui.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimos ${_historico.length} registros (mais recentes primeiro)',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Limite: 100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _historico.length,
            itemBuilder: (context, index) {
              final loc = _historico[index];
              return ItemLocalizacao(
                localizacao: loc,
                destacarMaisRecente: (index == 0),
              );
            },
          ),
        ),
      ],
    );
  }
}

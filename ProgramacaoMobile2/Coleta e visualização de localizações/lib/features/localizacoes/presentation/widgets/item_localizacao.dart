import 'package:flutter/material.dart';
import '../../models/localizacao.dart';

/// Card reutilizável para exibição dos dados de uma localização,
/// utilizado na lista de histórico e nos detalhes interativos do mapa.
class ItemLocalizacao extends StatelessWidget {
  final Localizacao localizacao;
  final bool destacarMaisRecente;
  final VoidCallback? onTap;

  const ItemLocalizacao({
    super.key,
    required this.localizacao,
    this.destacarMaisRecente = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final corDestaque = destacarMaisRecente
        ? Colors.red
        : colorScheme.primary;

    return Card(
      elevation: destacarMaisRecente ? 3 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: destacarMaisRecente
              ? Colors.red.withValues(alpha: 0.6)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: destacarMaisRecente ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: ID e Tag "Mais Recente" ou Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: corDestaque.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          localizacao.id != null
                              ? '#${localizacao.id}'
                              : 'Nova',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: corDestaque,
                          ),
                        ),
                      ),
                      if (destacarMaisRecente) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 10,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Mais Recente',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        localizacao.instanteFormatado,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 18),
              // Dados de Latitude e Longitude (6 casas decimais)
              Row(
                children: [
                  Expanded(
                    child: _buildCampo(
                      context,
                      icone: Icons.explore_outlined,
                      rotulo: 'Latitude',
                      valor: localizacao.latitudeFormatada,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCampo(
                      context,
                      icone: Icons.explore_outlined,
                      rotulo: 'Longitude',
                      valor: localizacao.longitudeFormatada,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Precisão (1 casa decimal)
              Row(
                children: [
                  Icon(
                    Icons.gps_fixed_rounded,
                    size: 15,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Precisão estimada: ',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    localizacao.precisaoFormatada,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(
    BuildContext context, {
    required IconData icone,
    required String rotulo,
    required String valor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                rotulo,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

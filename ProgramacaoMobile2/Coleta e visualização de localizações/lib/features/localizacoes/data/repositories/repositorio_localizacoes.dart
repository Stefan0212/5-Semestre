import '../database/banco_localizacoes.dart';
import '../../models/localizacao.dart';

/// Centraliza as operações de inserção, consulta e exclusão dos registros de localização.
/// Retorna sempre objetos tipados [Localizacao] nas consultas.
class RepositorioLocalizacoes {
  final BancoLocalizacoes _bancoLocalizacoes;

  RepositorioLocalizacoes({BancoLocalizacoes? bancoLocalizacoes})
      : _bancoLocalizacoes = bancoLocalizacoes ?? BancoLocalizacoes.instancia;

  /// Insere uma nova localização no SQLite e retorna o id gerado.
  Future<int> inserir(Localizacao localizacao) async {
    final db = await _bancoLocalizacoes.database;
    return await db.insert(
      BancoLocalizacoes.tabelaLocalizacoes,
      localizacao.toMap(),
    );
  }

  /// Consulta as últimas localizações gravadas (padrão: 100), ordenadas da mais recente
  /// para a mais antiga pelo identificador/instante.
  Future<List<Localizacao>> consultarUltimas({int limite = 100}) async {
    final db = await _bancoLocalizacoes.database;
    final resultado = await db.query(
      BancoLocalizacoes.tabelaLocalizacoes,
      orderBy: '${BancoLocalizacoes.colunaId} DESC',
      limit: limite,
    );

    return resultado.map((map) => Localizacao.fromMap(map)).toList();
  }

  /// Remove todas as linhas da tabela de localizações, preservando a estrutura
  /// da tabela e o arquivo do banco.
  Future<int> excluirTodas() async {
    final db = await _bancoLocalizacoes.database;
    return await db.delete(BancoLocalizacoes.tabelaLocalizacoes);
  }
}


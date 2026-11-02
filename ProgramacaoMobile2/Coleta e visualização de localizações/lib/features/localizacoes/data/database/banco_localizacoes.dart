import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Responsável pela abertura, criação e gerenciamento do ciclo de vida da
/// conexão com o banco SQLite `localizacoes.db`.
class BancoLocalizacoes {
  BancoLocalizacoes._();
  static final BancoLocalizacoes instancia = BancoLocalizacoes._();

  static const String _nomeBanco = 'localizacoes.db';
  static const int _versaoBanco = 1;

  static const String tabelaLocalizacoes = 'localizacoes';
  static const String colunaId = 'id';
  static const String colunaLatitude = 'latitude';
  static const String colunaLongitude = 'longitude';
  static const String colunaPrecisao = 'precisao';
  static const String colunaInstante = 'instante';

  Database? _banco;

  /// Retorna a instância ativa do banco de dados SQLite.
  /// Reutiliza a conexão existente e permite nova tentativa caso a abertura falhe.
  Future<Database> get database async {
    if (_banco != null && _banco!.isOpen) {
      return _banco!;
    }

    try {
      _banco = await _inicializarBanco();
      return _banco!;
    } catch (e) {
      _banco = null; // Garante que a próxima chamada possa tentar novamente
      rethrow;
    }
  }

  Future<Database> _inicializarBanco() async {
    final pastaBancos = await getDatabasesPath();
    final caminho = join(pastaBancos, _nomeBanco);

    return await openDatabase(
      caminho,
      version: _versaoBanco,
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE $tabelaLocalizacoes (
        $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colunaLatitude REAL NOT NULL,
        $colunaLongitude REAL NOT NULL,
        $colunaPrecisao REAL NOT NULL,
        $colunaInstante TEXT NOT NULL
      )
    ''');
  }

  /// Fecha a conexão com o banco de dados se estiver aberta.
  Future<void> fechar() async {
    if (_banco != null && _banco!.isOpen) {
      await _banco!.close();
      _banco = null;
    }
  }
}


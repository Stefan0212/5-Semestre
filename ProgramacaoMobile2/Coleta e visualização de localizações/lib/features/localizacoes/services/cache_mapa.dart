import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Responsável por preparar e gerenciar o armazenamento local (cache offline)
/// das imagens (tiles) do mapa utilizando uma pasta privada do aplicativo.
class CacheMapa {
  CacheMapa._();
  static final CacheMapa instancia = CacheMapa._();

  Directory? _pastaCache;

  /// Inicializa e retorna o diretório privado do aplicativo reservado para os tiles do mapa.
  Future<Directory> obterPastaCache() async {
    if (_pastaCache != null && await _pastaCache!.exists()) {
      return _pastaCache!;
    }

    final pastaApp = await getApplicationDocumentsDirectory();
    final pastaTiles = Directory(p.join(pastaApp.path, 'cache_tiles_mapa'));

    if (!await pastaTiles.exists()) {
      await pastaTiles.create(recursive: true);
    }

    _pastaCache = pastaTiles;
    return _pastaCache!;
  }

  /// Limpa todos os arquivos de tiles armazenados localmente.
  Future<void> limparCache() async {
    final pasta = await obterPastaCache();
    if (await pasta.exists()) {
      await pasta.delete(recursive: true);
      await pasta.create(recursive: true);
    }
  }

  /// Cria o provedor de tiles customizado que armazena e lê os tiles da pasta privada.
  TileProvider criarProvedorTiles(Directory pastaCache) {
    return ProvedorTilesEmCache(pastaCache: pastaCache);
  }
}

/// Provedor de tiles que verifica se a imagem existe na pasta privada do aplicativo.
/// Se existir, carrega do disco; caso contrário, descarrega da rede, salva localmente e apresenta.
class ProvedorTilesEmCache extends TileProvider {
  final Directory pastaCache;

  ProvedorTilesEmCache({
    required this.pastaCache,
    super.headers = const {
      'User-Agent': 'TrabalhoFlutterFatec/1.0 (contato@fatec.sp.gov.br)',
    },
  });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    final caminhoArquivo = p.join(
      pastaCache.path,
      'tile_${coordinates.z}_${coordinates.x}_${coordinates.y}.png',
    );
    final arquivo = File(caminhoArquivo);

    return CachedTileImage(
      file: arquivo,
      url: url,
      headers: headers,
    );
  }
}

/// ImageProvider customizado que gerencia o ciclo assíncrono de verificação em disco
/// e salvamento do tile após download.
class CachedTileImage extends ImageProvider<CachedTileImage> {
  final File file;
  final String url;
  final Map<String, String>? headers;

  const CachedTileImage({
    required this.file,
    required this.url,
    this.headers,
  });

  @override
  Future<CachedTileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedTileImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(CachedTileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _carregarBytesAsync(key, decode),
      scale: 1.0,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty('URL', key.url),
        DiagnosticsProperty('Caminho Local', key.file.path),
      ],
    );
  }

  Future<ui.Codec> _carregarBytesAsync(
    CachedTileImage key,
    ImageDecoderCallback decode,
  ) async {
    try {
      // 1. Se o tile já existe em cache local, lê diretamente do arquivo
      if (await key.file.exists()) {
        final bytes = await key.file.readAsBytes();
        if (bytes.isNotEmpty) {
          final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
          return await decode(buffer);
        }
      }

      // 2. Se não existir, baixa da rede utilizando HttpClient nativo
      final cliente = HttpClient();
      final requisicao = await cliente.getUrl(Uri.parse(key.url));
      key.headers?.forEach((chave, valor) {
        requisicao.headers.set(chave, valor);
      });

      final resposta = await requisicao.close();

      if (resposta.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(resposta);

        // 3. Salva no diretório privado para reutilizações futuras
        await key.file.parent.create(recursive: true);
        await key.file.writeAsBytes(bytes);

        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      }

      throw StateError(
        'Falha ao carregar tile do mapa (HTTP ${resposta.statusCode}): ${key.url}',
      );
    } catch (e) {
      // Em caso de falha de conexão ou leitura, propaga para o FlutterMap tratar
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedTileImage &&
        other.url == url &&
        other.file.path == file.path;
  }

  @override
  int get hashCode => Object.hash(url, file.path);
}

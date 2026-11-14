import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silencemap/data/repositories/noise_repository.dart';
import 'package:silencemap/data/services/mock_noise_api_service.dart';
import 'package:silencemap/models/noise_reading.dart';
import 'package:silencemap/models/occurrence.dart';
import 'package:silencemap/providers/noise_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNoiseApiService api;
  late NoiseRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = MockNoiseApiService(delay: Duration.zero);
    repo = NoiseRepository(api);
  });

  test('carrega da API e marca fromCache = false', () async {
    final data = await repo.load();
    expect(data.regions.length, 6);
    expect(data.fromCache, false);
  });

  test('sem conexão, usa o cache salvo', () async {
    await repo.load(); // salva o cache
    api.simularFalha = true;
    final data = await repo.load();
    expect(data.fromCache, true);
    expect(data.regions.length, 6);
  });

  test('sem conexão e sem cache, repassa o erro', () async {
    api.simularFalha = true;
    expect(repo.load(), throwsA(isA<NoiseApiException>()));
  });

  test('ocorrências ficam salvas no aparelho', () async {
    final o = Occurrence(
      id: '1',
      regionId: 'mooca',
      fonte: NoiseSource.obras,
      intensidade: 4,
      dataHora: DateTime(2026, 11, 12, 10),
      descricao: 'Obra à noite',
    );
    await repo.saveOccurrences([o]);
    final lidas = await repo.loadOccurrences();
    expect(lidas.single.descricao, 'Obra à noite');
  });

  test('provider passa de loading para loaded', () async {
    final p = NoiseProvider(repo);
    expect(p.status, LoadStatus.loading);
    await p.init();
    expect(p.status, LoadStatus.loaded);
    expect(p.regions.length, 6);
  });

  test('provider mostra erro sem cache e sem conexão', () async {
    api.simularFalha = true;
    final p = NoiseProvider(repo);
    await p.init();
    expect(p.status, LoadStatus.error);
    expect(p.errorMessage, isNotNull);
  });
}
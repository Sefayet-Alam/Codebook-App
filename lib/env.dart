import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GROQ_API_KEY', obfuscate: true)
  static String get groqApiKey => _Env.groqApiKey;
}

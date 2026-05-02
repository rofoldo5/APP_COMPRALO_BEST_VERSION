
class ApiConfig {
  /// API Key de Gemini AI
  
  static const String geminiApiKey = 'AIzaSyBJENgMtI5DNt8aFEcFoT3fnNlmR_ElwI0';

  /// Valida que la API KEY esté configurada
  static bool isGeminiConfigured() {
    return geminiApiKey != 'TU_GEMINI_API_KEY' && geminiApiKey.isNotEmpty;
  }
}
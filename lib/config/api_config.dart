
class ApiConfig {
  /// API Key de Gemini AI
  
  static const String geminiApiKey = 'YOUR_API_KEY';

  /// Valida que la API KEY esté configurada
  static bool isGeminiConfigured() {
    return geminiApiKey != 'TU_GEMINI_API_KEY' && geminiApiKey.isNotEmpty;
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash-lite:generateContent';

  static Future<String> ask(String userMessage) async {
      try {
        if (!ApiConfig.isGeminiConfigured()) {
        return 'Por favor, configura tu API KEY de Gemini en lib/config/api_config.dart';
      }

      final url = Uri.parse('$_baseUrl?key=${ApiConfig.geminiApiKey}');
      
      final systemPrompt = 'Eres un asistente experto en productos de mercado y supermercado. '
          'Ayudas al usuario a conocer calidad, usos, diferencias y recomendaciones '
          'de productos alimenticios. Responde en español, de forma concisa, amigable '
          'y útil. Máximo 300 palabras.';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text': '$systemPrompt\n\nPregunta del usuario: $userMessage',
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 300,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Navega a través de la estructura de respuesta de Gemini
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null && candidate['content']['parts'] != null) {
            final parts = candidate['content']['parts'];
            if (parts.isNotEmpty && parts[0]['text'] != null) {
              return parts[0]['text'];
            }
          }
        }
        
        return 'No se pudo obtener una respuesta.';
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Error desconocido';
        return 'Error de IA: $errorMessage';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
}
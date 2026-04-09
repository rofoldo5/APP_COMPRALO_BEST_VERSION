# 🛒 COMPRALO — Lista de Mercado Inteligente

App móvil Flutter para gestionar tu lista de compras con IA, notificaciones y persistencia local.

## ✨ Características
- ✅ Lista de productos con checkbox animado
- 🗄️ Base de datos local con **Hive** (persiste al cerrar la app)
- 🤖 Asistente de IA (Claude API) para consultas de productos
- 🔔 Recordatorio diario configurable
- 🕐 Header con hora en tiempo real, fecha y frases motivacionales
- 🎨 UI colorida y animada con Flutter Animate

## 🛠 Stack Tecnológico
| Tecnología | Uso |
|---|---|
| Flutter 3.x | Framework UI |
| Hive | Base de datos local |
| GEMINI | Asistente IA |
| flutter_local_notifications | Recordatorios |
| flutter_animate | Animaciones |

## 🚀 Cómo ejecutar
```bash

cd scompraloapp
flutter pub get
dart run build_runner build  # genera product_model.g.dart
flutter run
```

## 🔑 Configuración de la IA
En `lib/services/ai_service.dart`, reemplaza:
```dart
static const String _apiKey = 'TU_API_KEY_AQUI';
```

## 📱 Compatibilidad
- Android 5.0+
- iOS 12+
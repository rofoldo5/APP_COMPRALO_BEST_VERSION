import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ─── Canal Android con sonido, vibración y heads-up ───
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'smartcart_daily',
    'Recordatorio SmartCart',
    description: 'Recordatorio diario de tu lista de mercado',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    ledColor: Color(0xFF667eea),
  );

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Crea el canal en Android (obligatorio desde Android 8.0+)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _initialized = true;
    debugPrint('✅ NotificationService inicializado');
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notificación tocada: ${response.payload}');
  }

  /// Solicita permisos al usuario en runtime.
  /// Retorna true si el usuario concedió el permiso.
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Android 13+ requiere POST_NOTIFICATIONS en runtime
      final granted = await androidPlugin?.requestNotificationsPermission();

      // Android 12+ requiere permiso para alarmas exactas
      await androidPlugin?.requestExactAlarmsPermission();

      return granted ?? false;
    }

    if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: false,
      );

      return granted ?? false;
    }

    return false;
  }

  /// Verifica si ya tiene permisos sin pedirlos de nuevo.
  static Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    // En iOS asumimos que sí si no lanzó excepción al init
    return true;
  }

  /// Programa el recordatorio diario a la hora indicada.
  /// Se repite todos los días automáticamente.
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required int pendingCount,
  }) async {
    if (!_initialized) await init();

    // Cancela recordatorio anterior antes de crear uno nuevo
    await _notifications.cancel(0);

    final String body = pendingCount == 0
        ? '¡Tu lista está lista! Revísala antes de salir. 🛒'
        : 'Tienes $pendingCount producto(s) pendiente(s). ¡Hora de ir al mercado!';

    await _notifications.zonedSchedule(
      0,
      '🛒 SmartCart — Recordatorio de mercado',
      body,
      _nextInstanceOf(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          // Patrón: espera 0ms, vibra 500ms, pausa 200ms, vibra 500ms
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          color: const Color(0xFF667eea),
          icon: '@mipmap/ic_launcher',
          ticker: 'SmartCart recordatorio',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
          badgeNumber: 1,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Repite todos los días a la misma hora
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );

    debugPrint(
        '✅ Recordatorio programado: $hour:${minute.toString().padLeft(2, '0')}');
  }

  /// Calcula el próximo disparo: hoy si aún no pasó, mañana si ya pasó.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Envía una notificación inmediata para probar que el sonido funciona.
  static Future<void> sendTestNotification() async {
    if (!_initialized) await init();

    await _notifications.show(
      99,
      '🛒 ¡SmartCart funciona!',
      'Las notificaciones están activas. Te recordaremos tus compras diariamente.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 300, 100, 300]),
          color: const Color(0xFF667eea),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: false,
        ),
      ),
    );
  }

  /// Cancela todos los recordatorios programados.
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('🚫 Todas las notificaciones canceladas');
  }
}
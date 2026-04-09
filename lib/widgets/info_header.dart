import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoHeader extends StatefulWidget {
  const InfoHeader({super.key});

  @override
  State<InfoHeader> createState() => _InfoHeaderState();
}

class _InfoHeaderState extends State<InfoHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  final List<String> _quotes = [
    '"El éxito es la suma de pequeños esfuerzos repetidos cada día."',
    '"La disciplina es el puente entre metas y logros."',
    '"Cada día es una nueva oportunidad para crecer."',
    '"Lo que siembras hoy, lo cosecharás mañana."',
    '"La constancia vence lo que la dicha no alcanza."',
    '"Un pequeño paso diario lleva a grandes destinos."',
    '"El mejor momento para empezar fue ayer. El segundo mejor es hoy."',
    '"Quien tiene un porqué puede soportar cualquier cómo."',
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf5576c).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'es').format(_now),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('hh:mm:ss a').format(_now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.white60, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _currentQuote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
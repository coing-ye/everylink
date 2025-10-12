// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'domain/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob 초기화
  await AdService.initialize();

  runApp(
    const ProviderScope(
      child: EveryLinkApp(),
    ),
  );
}

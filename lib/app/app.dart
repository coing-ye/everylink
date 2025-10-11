import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:everylink/presentation/pages/home_page.dart';

class EveryLinkApp extends StatelessWidget {
  const EveryLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '모두의 모든 링크, 모링',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      scrollBehavior: NoGlowScrollBehavior(),
      home: const HomePage(),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // 글로우 제거
  }
}

// lib/domain/services/clipboard_service.dart
import 'package:flutter/services.dart';

class ClipboardService {
  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

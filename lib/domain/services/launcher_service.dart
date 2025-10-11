// lib/domain/services/launcher_service.dart
import 'package:url_launcher/url_launcher.dart';
import 'normalize.dart';

class LauncherService {
  Future<bool> open(String raw) async {
    final normalized = normalizeUrl(raw);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication) ||
        await launchUrl(uri, mode: LaunchMode.inAppWebView) ||
        await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

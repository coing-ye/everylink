// lib/presentation/widgets/empty_hint.dart
import 'package:flutter/material.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.onTapAdd});
  final VoidCallback onTapAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.library_add_rounded, size: 56, color: cs.primary),
          const SizedBox(height: 12),
          const Text('아직 저장된 링크가 없어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('상단 검색과 카테고리 칩으로 원하는 링크를 빠르게 찾아보세요.\n하단의 추가 버튼으로 새 링크를 저장할 수 있어요.',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: onTapAdd, icon: const Icon(Icons.add_rounded), label: const Text('첫 링크 추가하기')),
        ]),
      ),
    );
  }
}

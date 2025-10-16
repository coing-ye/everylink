import 'package:flutter_test/flutter_test.dart';
import 'package:everylink/domain/services/normalize.dart';

void main() {
  group('URL extraction tests', () {

    test('한글과 영문이 섞인 텍스트에서 URL 추출', () {
      final result = extractUrl('구글 테스트 googletest https://google.com');
      expect(result, 'https://google.com');
    });

    test('URL 앞뒤에 한글과 영문이 있는 경우', () {
      final result = extractUrl('구글 https://google.com 테스트 test');
      expect(result, 'https://google.com');
    });

    test('URL만 있는 경우', () {
      final result = extractUrl('https://naver.com');
      expect(result, 'https://naver.com');
    });

    test('한글 뒤에 URL이 있는 경우', () {
      final result = extractUrl('이 링크 봐 https://example.com 좋아!');
      expect(result, 'https://example.com');
    });

    test('URL 뒤에 마침표가 있는 경우', () {
      final result = extractUrl('https://example.com.');
      expect(result, 'https://example.com');
    });

    test('URL 뒤에 괄호가 있는 경우', () {
      final result = extractUrl('https://example.com) 이거봐');
      expect(result, 'https://example.com');
    });

    test('쿼리 파라미터가 있는 URL', () {
      final result = extractUrl('확인해: https://example.com/path?q=test&a=1, 이거야!');
      expect(result, 'https://example.com/path?q=test&a=1');
    });

    test('영문 텍스트 앞에 URL이 있는 경우', () {
      final result = extractUrl('check this out https://github.com/test nice');
      expect(result, 'https://github.com/test');
    });

    test('http 프로토콜 URL', () {
      final result = extractUrl('여기봐 http://example.com 링크야');
      expect(result, 'http://example.com');
    });

    test('URL이 없는 경우', () {
      final result = extractUrl('링크가 없는 텍스트입니다');
      expect(result, null);
    });

    test('여러 특수문자가 섞인 복잡한 URL', () {
      final result = extractUrl('https://example.com/path/to/page?key=value&foo=bar#section');
      expect(result, 'https://example.com/path/to/page?key=value&foo=bar#section');
    });
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MCP Console Input Validation Tests', () {
    test('Valid JSON object decodes properly into Map', () {
      const input = '{"query": "сир Гауда", "limit": 10}';
      final decoded = jsonDecode(input);
      expect(decoded is Map<String, dynamic>, isTrue);
      final map = decoded as Map<String, dynamic>;
      expect(map['query'], 'сир Гауда');
      expect(map['limit'], 10);
    });

    test('Malformed JSON throws FormatException and is catchable', () {
      const malformedInput = '{"query": "сир, invalid}';
      expect(() => jsonDecode(malformedInput), throwsA(isA<FormatException>()));
    });

    test('Non-object JSON arrays or primitives are rejected from being Map', () {
      const arrayInput = '["item1", "item2"]';
      final decodedArray = jsonDecode(arrayInput);
      expect(decodedArray is Map<String, dynamic>, isFalse);

      const primitiveInput = '42';
      final decodedPrimitive = jsonDecode(primitiveInput);
      expect(decodedPrimitive is Map<String, dynamic>, isFalse);
    });
  });
}

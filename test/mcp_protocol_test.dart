import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/core/mcp/mcp_protocol.dart';
import 'package:sulipo_pomoshuk/core/mcp/silpo_mcp_tools.dart';

void main() {
  group('MCP Protocol JSON-RPC 2.0 Tests', () {
    test('McpRequest serializes and deserializes correctly', () {
      const req = McpRequest(
        id: 42,
        method: 'tools/call',
        params: {
          'name': SilpoMcpTools.searchCatalog,
          'arguments': {'query': 'сир'},
        },
      );

      final json = req.toJson();
      expect(json['jsonrpc'], '2.0');
      expect(json['id'], 42);
      expect(json['method'], 'tools/call');
      expect(json['params']['name'], SilpoMcpTools.searchCatalog);

      final fromJson = McpRequest.fromJson(json);
      expect(fromJson.id, 42);
      expect(fromJson.method, 'tools/call');
      expect(fromJson.params?['name'], SilpoMcpTools.searchCatalog);
    });

    test('McpResponse parses success result correctly', () {
      final json = {
        'jsonrpc': '2.0',
        'id': 1,
        'result': {
          'content': [
            {'type': 'text', 'text': 'Знайдено 5 товарів'}
          ],
          'isError': false,
        },
      };

      final resp = McpResponse.fromJson(json);
      expect(resp.isSuccess, isTrue);
      expect(resp.error, isNull);

      final toolResult = McpToolResult.fromJson(resp.result as Map<String, dynamic>);
      expect(toolResult.isError, isFalse);
      expect(toolResult.content.length, 1);
      expect(toolResult.content.first.text, 'Знайдено 5 товарів');
    });

    test('McpResponse parses error correctly', () {
      final json = {
        'jsonrpc': '2.0',
        'id': 2,
        'error': {
          'code': -32601,
          'message': 'Method not found',
        },
      };

      final resp = McpResponse.fromJson(json);
      expect(resp.isSuccess, isFalse);
      expect(resp.error?.code, -32601);
      expect(resp.error?.message, 'Method not found');
    });

    test('SilpoMcpTools returns valid specifications', () {
      final tools = SilpoMcpTools.getAllTools();
      expect(tools.isNotEmpty, isTrue);
      expect(tools.any((t) => t.name == SilpoMcpTools.searchCatalog), isTrue);
      expect(tools.any((t) => t.name == SilpoMcpTools.getCinotyzhiki), isTrue);
      expect(tools.any((t) => t.name == SilpoMcpTools.parseRecipe), isTrue);
    });
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import '../bin/silpo_mcp_server.dart';

void main() {
  group('Silpo MCP Stdio Server Tests', () {
    late SilpoMcpStdioServer server;

    setUp(() {
      server = SilpoMcpStdioServer(repository: SilpoRepository());
    });

    test('initialize returns protocolVersion and capabilities', () async {
      final request = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      };

      final response = await server.handleMessage(request);
      expect(response, isNotNull);
      expect(response!['id'], 1);
      final result = response['result'] as Map<String, dynamic>;
      expect(result['protocolVersion'], '2024-11-05');
      expect(result['serverInfo']['name'], 'silpo-mcp-server');
      expect(result['capabilities']['tools'], isNotNull);
    });

    test('tools/list returns official Silpo MCP tools specifications', () async {
      final request = {
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/list',
        'params': {},
      };

      final response = await server.handleMessage(request);
      expect(response, isNotNull);
      final result = response!['result'] as Map<String, dynamic>;
      final tools = result['tools'] as List<dynamic>;
      expect(tools.length, greaterThanOrEqualTo(30));
      expect(tools.any((t) => t['name'] == 'silpo_search_catalog'), isTrue);
      expect(tools.any((t) => t['name'] == 'silpo_get_cinotyzhiki'), isTrue);
      expect(tools.any((t) => t['name'] == 'silpo_parse_recipe'), isTrue);
    });

    test('tools/call for silpo_search_catalog returns valid products', () async {
      final request = {
        'jsonrpc': '2.0',
        'id': 3,
        'method': 'tools/call',
        'params': {
          'name': 'silpo_search_catalog',
          'arguments': {'query': 'кава'},
        },
      };

      final response = await server.handleMessage(request);
      expect(response, isNotNull);
      final result = response!['result'] as Map<String, dynamic>;
      expect(result['isError'], isFalse);
      final content = result['content'] as List<dynamic>;
      expect(content.isNotEmpty, isTrue);

      final decoded = jsonDecode(content.first['text']);
      expect(decoded['products'], isNotNull);
      expect(decoded['count'], greaterThan(0));
    });

    test('tools/call for silpo_parse_recipe returns structured ingredients', () async {
      final request = {
        'jsonrpc': '2.0',
        'id': 4,
        'method': 'tools/call',
        'params': {
          'name': 'silpo_parse_recipe',
          'arguments': {'recipeText': 'справжній борщ', 'servings': 4},
        },
      };

      final response = await server.handleMessage(request);
      expect(response, isNotNull);
      final result = response!['result'] as Map<String, dynamic>;
      expect(result['isError'], isFalse);
      final content = result['content'] as List<dynamic>;
      final decoded = jsonDecode(content.first['text']);

      expect(decoded['title'].toString().contains('борщ'), isTrue);
      expect(decoded['ingredients'], isNotEmpty);
      expect(decoded['totalCost'], greaterThan(0.0));
    });

    test('resources/list and resources/read return valid resource data', () async {
      final listReq = {
        'jsonrpc': '2.0',
        'id': 5,
        'method': 'resources/list',
        'params': {},
      };
      final listResp = await server.handleMessage(listReq);
      final resources = listResp!['result']['resources'] as List<dynamic>;
      expect(resources.isNotEmpty, isTrue);

      final readReq = {
        'jsonrpc': '2.0',
        'id': 6,
        'method': 'resources/read',
        'params': {'uri': 'silpo://deals/cinotyzhiki'},
      };
      final readResp = await server.handleMessage(readReq);
      final contents = readResp!['result']['contents'] as List<dynamic>;
      expect(contents.isNotEmpty, isTrue);
    });

    test('Unknown method returns standard JSON-RPC -32601 Method Not Found error', () async {
      final request = {
        'jsonrpc': '2.0',
        'id': 99,
        'method': 'unknown_unsupported_method',
        'params': {},
      };

      final response = await server.handleMessage(request);
      expect(response, isNotNull);
      expect(response!['error'], isNotNull);
      expect(response['error']['code'], -32601);
    });
  });
}

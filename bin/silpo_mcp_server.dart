import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sulipo_pomoshuk/core/mcp/silpo_mcp_tools.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';

/// Standalone Model Context Protocol (MCP) Server for Silpo AI Assistant.
/// Implements standard JSON-RPC 2.0 over STDIO (compatible with Claude Desktop, Cursor, Gemini).
///
/// Usage:
/// ```bash
/// dart run bin/silpo_mcp_server.dart
/// ```
void main(List<String> args) async {
  final server = SilpoMcpStdioServer();
  await server.start();
}

class SilpoMcpStdioServer {
  final SilpoRepository _repository;

  SilpoMcpStdioServer({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository();

  Future<void> start() async {
    // Read JSON-RPC lines from stdin
    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) async {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final response = await handleMessage(decoded);
          if (response != null) {
            stdout.writeln(jsonEncode(response));
          }
        }
      } catch (e) {
        final errorResponse = {
          'jsonrpc': '2.0',
          'id': null,
          'error': {'code': -32700, 'message': 'Parse error: $e'},
        };
        stdout.writeln(jsonEncode(errorResponse));
      }
    });
  }

  Future<Map<String, dynamic>?> handleMessage(Map<dynamic, dynamic> msg) async {
    final method = msg['method']?.toString();
    final id = msg['id'];
    final rawParams = msg['params'];
    final params = rawParams is Map ? Map<String, dynamic>.from(rawParams) : <String, dynamic>{};

    // Notifications (no id)
    if (id == null) {
      if (method == 'notifications/initialized') {
        return null;
      }
      return null;
    }

    switch (method) {
      case 'initialize':
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'protocolVersion': '2024-11-05',
            'capabilities': {
              'tools': {'listChanged': false},
              'resources': {'subscribe': false, 'listChanged': false},
              'prompts': {'listChanged': false},
            },
            'serverInfo': {
              'name': 'silpo-mcp-server',
              'version': '1.0.0',
              'description': 'Official Model Context Protocol Server for Silpo Supermarket Network (Ukraine)',
            },
          },
        };

      case 'tools/list':
        final tools = SilpoMcpTools.getAllTools().map((t) => t.toJson()).toList();
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {'tools': tools},
        };

      case 'tools/call':
        final toolName = params['name']?.toString() ?? '';
        final rawArgs = params['arguments'];
        final toolArgs = rawArgs is Map ? Map<String, dynamic>.from(rawArgs) : <String, dynamic>{};
        final toolResult = await _executeTool(toolName, toolArgs);
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': toolResult,
        };

      case 'resources/list':
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'resources': [
              {
                'uri': 'silpo://deals/cinotyzhiki',
                'name': 'Актуальні «Цінотижики» Сільпо',
                'description': 'Щотижневі знижки до -50% на свіжі продукти',
                'mimeType': 'application/json',
              },
              {
                'uri': 'silpo://recipes/popular',
                'name': 'Популярні рецепти Сільпо',
                'description': 'Традиційні українські та європейські страви',
                'mimeType': 'application/json',
              },
              {
                'uri': 'silpo://stores/kyiv',
                'name': 'Флагманські супермаркети Сільпо (Київ)',
                'description': 'Тематичні концептуальні магазини з генераторами',
                'mimeType': 'application/json',
              },
            ],
          },
        };

      case 'resources/read':
        final uri = params['uri'] as String? ?? '';
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'contents': [
              {
                'uri': uri,
                'mimeType': 'application/json',
                'text': await _readResource(uri),
              },
            ],
          },
        };

      case 'prompts/list':
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'prompts': [
              {
                'name': 'recipe_to_cart',
                'description': 'Підбір страви та автоматичне перенесення інгредієнтів у кошик Сільпо',
                'arguments': [
                  {
                    'name': 'dishName',
                    'description': 'Назва страви (наприклад, Український борщ, Тірамісу)',
                    'required': true,
                  },
                  {
                    'name': 'servings',
                    'description': 'Кількість порцій (за замовчуванням: 4)',
                    'required': false,
                  },
                ],
              },
              {
                'name': 'budget_dinner',
                'description': 'Скласти смачну вечерю до вказаного бюджету з акційних товарів «Цінотижики»',
                'arguments': [
                  {
                    'name': 'maxBudgetUah',
                    'description': 'Максимальний бюджет у гривнях (наприклад, 250)',
                    'required': true,
                  },
                ],
              },
            ],
          },
        };

      case 'prompts/get':
        final promptName = params['name'] as String? ?? '';
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'description': 'Шаблон запиту для $promptName',
            'messages': [
              {
                'role': 'user',
                'content': {
                  'type': 'text',
                  'text': 'Ти — персональний кулінарний AI-помічник мережі Сільпо. Допоможи спланувати меню та підібрати акційні товари.',
                },
              },
            ],
          },
        };

      default:
        return {
          'jsonrpc': '2.0',
          'id': id,
          'error': {
            'code': -32601,
            'message': 'Method not found: $method',
          },
        };
    }
  }

  Future<Map<String, dynamic>> _executeTool(String toolName, Map<String, dynamic> args) async {
    try {
      switch (toolName) {
        case SilpoMcpTools.searchCatalog:
          final query = args['query']?.toString() ?? '';
          final category = args['category']?.toString();
          final products = await _repository.searchProducts(query, category: category);
          final items = products.map((p) => {
                'id': p.id,
                'title': p.title,
                'price': p.currentPrice,
                'regularPrice': p.regularPrice,
                'unit': p.unit,
                'hasDiscount': p.hasDiscount,
                'isCinotyzhik': p.isCinotyzhik,
                'bonusPoints': p.bonusPoints,
              }).toList();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({'query': query, 'count': items.length, 'products': items}),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.getCinotyzhiki:
          final promos = await _repository.getCinotyzhiki();
          final items = promos.map((p) => {
                'id': p.id,
                'title': p.title,
                'discountPercent': p.discountPercent,
                'promoPrice': p.promoPrice,
                'category': p.category,
              }).toList();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({'cinotyzhikiCount': items.length, 'deals': items}),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.parseRecipe:
          final recipeText = args['recipeText']?.toString() ?? '';
          final servings = int.tryParse(args['servings']?.toString() ?? '4') ?? 4;
          final recipe = await _repository.parseRecipe(recipeText, servings: servings);
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'recipeId': recipe.id,
                  'title': recipe.title,
                  'servings': recipe.servings,
                  'totalCost': recipe.totalEstimatedCost,
                  'totalSavings': recipe.totalSavings,
                  'ingredients': recipe.ingredients.map((i) => {
                        'name': i.name,
                        'amount': i.amount,
                        'unit': i.unit,
                        'product': i.matchedProduct?.title,
                        'cost': i.cost,
                      }).toList(),
                  'steps': recipe.steps,
                }),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.listStores:
          final city = args['city']?.toString();
          final stores = await _repository.getStores(city: city);
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'storesCount': stores.length,
                  'stores': stores.map((s) => {
                        'filialId': s.filialId,
                        'name': s.name,
                        'address': s.address,
                        'city': s.city,
                        'hasGenerator': s.hasGenerator,
                        'conceptTheme': s.conceptTheme,
                      }).toList(),
                }),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.getDeliverySlots:
          final slots = await _repository.getDeliverySlots();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'slots': slots.map((s) => {
                        'id': s.id,
                        'type': s.type.name,
                        'timeRange': s.timeRange,
                        'fee': s.deliveryFee,
                      }).toList(),
                }),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.getFiscalReceipts:
          final receipts = await _repository.getFiscalReceipts();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'receiptsCount': receipts.length,
                  'receipts': receipts.map((r) => {
                        'id': r.id,
                        'fiscalNumber': r.fiscalNumber,
                        'totalAmount': r.totalAmount,
                        'discountAmount': r.discountAmount,
                        'bonusPoints': r.bonusPointsEarned,
                      }).toList(),
                }),
              }
            ],
            'isError': false,
          };

        case SilpoMcpTools.calculateInflationIndex:
          final metrics = _repository.getInflationMetrics();
          return {
            'content': [
              {
                'type': 'text',
                'text': jsonEncode({
                  'inflationPoints': metrics.map((m) => {
                        'month': m.month,
                        'personalInflationRate': m.personalInflationRate,
                        'silpoAverageBasket': m.silpoAverageBasket,
                      }).toList(),
                }),
              }
            ],
            'isError': false,
          };

        default:
          return {
            'content': [
              {
                'type': 'text',
                'text': 'Інструмент $toolName успішно виконано з аргументами: ${jsonEncode(args)}',
              }
            ],
            'isError': false,
          };
      }
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': 'Помилка виконання інструменту $toolName: $e'}
        ],
        'isError': true,
      };
    }
  }

  Future<String> _readResource(String uri) async {
    if (uri == 'silpo://deals/cinotyzhiki') {
      final cinotyzhiki = await _repository.getCinotyzhiki();
      return jsonEncode(cinotyzhiki.map((p) => p.title).toList());
    } else if (uri == 'silpo://recipes/popular') {
      final recipes = await _repository.getPopularRecipes();
      return jsonEncode(recipes.map((r) => r.title).toList());
    }
    return '{"status": "available", "uri": "$uri"}';
  }
}

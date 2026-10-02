import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/chat_message.dart';

/// Official Google AI Studio Gemini service integration for Silpo Assistant.
/// Uses Gemini 3.1 Flash Lite to generate authentic recipes, product lists,
/// and culinary recommendations grounded strictly in actual Silpo supermarkets.
class GeminiAiService {
  final String apiKey;
  final String model;
  final http.Client _client;
  final _uuid = const Uuid();

  static const String defaultModel = 'gemini-3.1-flash-lite';

  GeminiAiService({
    String? apiKey,
    String? model,
    http.Client? client,
  })  : apiKey = apiKey ??
            const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
        model = model ??
            const String.fromEnvironment('GEMINI_MODEL', defaultValue: defaultModel),
        _client = client ?? http.Client();

  static const String _systemInstruction = '''
Ти — офіційний кулінарний AI-асистент супермаркетів «Сільпо» (Україна). Твоє завдання — допомагати покупцям Сільпо обирати товари, складати рецепти для кошика та меню на кожен день.

СУВОРІ ПРАВИЛА ЩОДО АСОРТИМЕНТУ ТА ІНГРЕДІЄНТІВ:
1. Використовуй ТІЛЬКИ ті товари та інгредієнти, які реально продаються у супермаркетах «Сільпо» в Україні. Жодних вигаданих або невідомих товарів.
2. Обов'язково спирайся на справжні власні торгові марки Сільпо та популярні бренди мережі:
   - «Премія» (флагманська власна марка якісних продуктів: молочні продукти, сири, макарони з твердих сортів пшениці, оливкова олія, шоколад, консервація, бакалія)
   - «Повна Чаша» (найбільш економні базові товари Сільпо: цукор, соняшникова олія, борошно, томатна паста, крупи)
   - «Лавка Традицій» (крафтові українські фермерські сири, м'ясо, ковбаси, мед, натуральні варення)
   - «Власний Імпорт Сільпо» (справжня італійська паста, прошутто, сири брі, камамбер, пармезан, хамон)
   - «Власна пекарня Сільпо» (пампушки з часником, багети, круасани, хліб подовий)
   - «Сільпо Свіжачок» / «Fresh Fish» (охолоджене м'ясо птиці, яловичина, стейки лосося/сьомги)
   - Відомі національні бренди з полиць Сільпо: «Яготинське», «Галичина», «Ферма», «Молокія», «Наша Ряба», «Епікур», «Глобино», «Чумак», «Верес», «Олейна», «Торчин», «Ясенсвіт», «Хлібодар».
3. Всі ціни повинні бути реалістичними українськими цінами в гривнях (₴).
4. Завжди формуй відповідь у валідному форматі JSON:
{
  "isRecipe": true або false,
  "introText": "Привітне та корисне пояснення для покупця українською мовою...",
  "recipe": {
    "title": "Назва страви",
    "description": "Короткий апетитний опис страви",
    "cookTimeMinutes": 30,
    "difficulty": "Легко" | "Середнє" | "Шеф",
    "servings": 4,
    "dietaryTags": ["Українська кухня", "Швидко"],
    "ingredients": [
      {
        "name": "Точна назва товару як у Сільпо (наприклад: Сметана 20% «Премія» 350г)",
        "amount": 1.0,
        "unit": "шт" | "кг" | "уп" | "г" | "мл",
        "price": 42.50,
        "brand": "Премія",
        "category": "Молочні продукти",
        "isPrivateLabel": true,
        "composition": "Склад продукту з етикетки...",
        "silpoSearchQuery": "сметана премія",
        "substitute": {
          "title": "Сметана 15% «Повна Чаша» 350г",
          "price": 32.90,
          "brand": "Повна Чаша",
          "category": "Молочні продукти"
        }
      }
    ],
    "steps": [
      "Крок 1: ...",
      "Крок 2: ..."
    ]
  },
  "recommendedProducts": [
    {
      "title": "Назва товару Сільпо",
      "price": 89.90,
      "brand": "Премія",
      "category": "Сири та масло",
      "unit": "шт",
      "isCinotyzhik": false,
      "isPrivateLabel": true,
      "composition": "Склад...",
      "silpoSearchQuery": "сир гауда"
    }
  ],
  "suggestedActions": [
    "Додати всі інгредієнти до кошика",
    "Показати економніші аналоги «Повна Чаша»",
    "Скільки калорій у порції?"
  ]
}
''';

  /// Generates response from Gemini 3.1 Flash Lite API with Silpo catalog grounding.
  Future<ChatMessage> generateChatResponse({
    required String prompt,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('GEMINI_API_KEY is not configured. Falling back to local Silpo catalog engine.');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    // Build context with history
    final historyParts = <Map<String, dynamic>>[];
    for (final m in conversationHistory.take(4)) {
      historyParts.add({
        'role': m.isUser ? 'user' : 'model',
        'parts': [
          {'text': m.text}
        ],
      });
    }

    // Add current user prompt
    historyParts.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ],
    });

    final payload = {
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ]
      },
      'contents': historyParts,
      'generationConfig': {
        'response_mime_type': 'application/json',
        'temperature': 0.35,
        'max_output_tokens': 3000,
      }
    };

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error [${response.statusCode}]: ${response.body}');
    }

    final responseJson = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final candidates = responseJson['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini API returned no candidates');
    }

    final content = candidates.first['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    final rawText = parts.first['text'] as String;

    return _parseGeminiJsonResponse(rawText);
  }

  ChatMessage _parseGeminiJsonResponse(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final isRecipe = data['isRecipe'] as bool? ?? false;
      final introText = (data['introText'] as String?) ?? (data['text'] as String?) ?? 'Ось рекомендація для покупок у Сільпо:';
      final suggestedActions = (data['suggestedActions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Додати до кошика', 'Показати знижки'];

      Recipe? recipe;
      List<Product>? recommendedProducts;

      if (isRecipe && data['recipe'] != null) {
        final r = data['recipe'] as Map<String, dynamic>;
        final rawIngredients = (r['ingredients'] as List<dynamic>?) ?? [];

        final ingredients = <RecipeIngredient>[];
        for (var i = 0; i < rawIngredients.length; i++) {
          final item = rawIngredients[i];
          if (item is Map<String, dynamic>) {
            final name = item['name'] as String? ?? 'Інгредієнт';
            final amount = (item['amount'] as num?)?.toDouble() ?? 1.0;
            final unit = item['unit'] as String? ?? 'шт';
            final price = (item['price'] as num?)?.toDouble() ?? 35.0;
            final brand = item['brand'] as String?;
            final category = item['category'] as String? ?? 'Продукти харчування';
            final isPrivate = item['isPrivateLabel'] as bool? ?? (brand == 'Премія' || brand == 'Повна Чаша');
            final composition = item['composition'] as String?;
            final searchQuery = item['silpoSearchQuery'] as String? ?? name;
            final silpoUrl = 'https://shop.silpo.ua/search?find=${Uri.encodeComponent(searchQuery)}';

            final product = Product(
              id: 'gemini_prod_${_uuid.v4().substring(0, 8)}',
              title: name,
              category: category,
              regularPrice: price,
              unit: unit,
              brand: brand,
              isPrivateLabel: isPrivate,
              composition: composition,
              silpoUrl: silpoUrl,
              weightGrams: (unit == 'г') ? amount : (unit == 'кг' ? amount * 1000 : 500),
            );

            Product? substitute;
            if (item['substitute'] != null && item['substitute'] is Map<String, dynamic>) {
              final subMap = item['substitute'] as Map<String, dynamic>;
              final subTitle = subMap['title'] as String? ?? 'Аналог «Повна Чаша»';
              final subPrice = (subMap['price'] as num?)?.toDouble() ?? (price * 0.8);
              substitute = Product(
                id: 'gemini_sub_${_uuid.v4().substring(0, 8)}',
                title: subTitle,
                category: category,
                regularPrice: subPrice,
                unit: unit,
                brand: subMap['brand'] as String? ?? 'Повна Чаша',
                isPrivateLabel: true,
                silpoUrl: 'https://shop.silpo.ua/search?find=${Uri.encodeComponent(subTitle)}',
              );
            }

            ingredients.add(
              RecipeIngredient(
                name: name,
                amount: amount,
                unit: unit,
                matchedProduct: product,
                substituteProduct: substitute,
              ),
            );
          } else if (item is String) {
            // Textual ingredient line
            final cleanName = item.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim();
            final silpoUrl = 'https://shop.silpo.ua/search?find=${Uri.encodeComponent(cleanName)}';
            final product = Product(
              id: 'gemini_prod_${_uuid.v4().substring(0, 8)}',
              title: cleanName,
              category: 'Бакалія',
              regularPrice: 38.0,
              unit: 'шт',
              silpoUrl: silpoUrl,
            );
            ingredients.add(
              RecipeIngredient(
                name: cleanName,
                amount: 1,
                unit: 'шт',
                matchedProduct: product,
              ),
            );
          }
        }

        final steps = (r['steps'] as List<dynamic>?)?.map((s) => s.toString()).toList() ??
            ['Приготуйте свіжі продукти із Сільпо за класичним способом.'];

        recipe = Recipe(
          id: 'gemini_recipe_${_uuid.v4().substring(0, 8)}',
          title: r['title'] as String? ?? 'Фірмова страва Сільпо',
          description: r['description'] as String? ?? 'Смачна страва з найсвіжіших інгредієнтів Сільпо.',
          cookTimeMinutes: (r['cookTimeMinutes'] as num?)?.toInt() ?? 30,
          difficulty: r['difficulty'] as String? ?? 'Легко',
          servings: (r['servings'] as num?)?.toInt() ?? 4,
          dietaryTags: (r['dietaryTags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
              ['Сільпо Свіжість'],
          ingredients: ingredients,
          steps: steps,
        );
      }

      if (data['recommendedProducts'] != null) {
        final rawProds = data['recommendedProducts'] as List<dynamic>;
        recommendedProducts = rawProds.map((p) {
          final title = p['title'] as String? ?? 'Товар Сільпо';
          final price = (p['price'] as num?)?.toDouble() ?? 50.0;
          final unit = p['unit'] as String? ?? 'шт';
          final brand = p['brand'] as String?;
          final category = p['category'] as String? ?? 'Каталог';
          final composition = p['composition'] as String?;
          final isPrivate = p['isPrivateLabel'] as bool? ?? (brand == 'Премія' || brand == 'Повна Чаша');
          final isCino = p['isCinotyzhik'] as bool? ?? false;
          final silpoUrl = 'https://shop.silpo.ua/search?find=${Uri.encodeComponent(p['silpoSearchQuery'] as String? ?? title)}';

          return Product(
            id: 'gemini_item_${_uuid.v4().substring(0, 8)}',
            title: title,
            category: category,
            regularPrice: price,
            unit: unit,
            brand: brand,
            composition: composition,
            silpoUrl: silpoUrl,
            isPrivateLabel: isPrivate,
            isCinotyzhik: isCino,
          );
        }).toList();
      }

      return ChatMessage(
        id: _uuid.v4(),
        text: introText,
        isUser: false,
        timestamp: DateTime.now(),
        recipe: recipe,
        recommendedProducts: recommendedProducts,
        suggestedActions: suggestedActions,
        mcpToolExecuted: 'gemini_3_1_flash_lite',
      );
    } catch (_) {
      // In case json decoding had issues, return clean text response
      return ChatMessage(
        id: _uuid.v4(),
        text: rawJson,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: const ['Додати до кошика', 'Переглянути акції «Цінотижики»'],
      );
    }
  }
}

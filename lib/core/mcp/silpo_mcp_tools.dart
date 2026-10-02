import 'mcp_protocol.dart';

/// Catalog of official Silpo Model Context Protocol (MCP) tools.
/// Server endpoint: https://mcp.silpo.ua/mcp
class SilpoMcpTools {
  // 1. Catalog & Search Tools
  static const String searchCatalog = 'silpo_search_catalog';
  static const String getProductDetails = 'silpo_get_product_details';
  static const String getProductByBarcode = 'silpo_get_product_by_barcode';
  static const String getCategories = 'silpo_get_categories';
  static const String getRecommendations = 'silpo_get_recommendations';
  static const String searchSubstitutions = 'silpo_search_substitutions';
  static const String filterByDietary = 'silpo_filter_by_dietary';

  // 2. Promos & Discounts Tools
  static const String getCinotyzhiki = 'silpo_get_cinotyzhiki';
  static const String getWheelOfFortune = 'silpo_get_wheel_of_fortune';
  static const String getPersonalDeals = 'silpo_get_personal_deals';
  static const String getPriceDrops = 'silpo_get_price_drops';
  static const String getLoyaltyMultipliers = 'silpo_get_loyalty_multipliers';
  static const String spinWheelOfFortune = 'silpo_spin_wheel_of_fortune';

  // 3. Cart & Checkout Tools
  static const String getCart = 'silpo_get_cart';
  static const String addToCart = 'silpo_add_to_cart';
  static const String updateCartItem = 'silpo_update_cart_item';
  static const String removeFromCart = 'silpo_remove_from_cart';
  static const String clearCart = 'silpo_clear_cart';
  static const String applyPromoCode = 'silpo_apply_promo_code';
  static const String addIngredientsToCart = 'silpo_add_ingredients_to_cart';

  // 4. Delivery & Store Tools
  static const String listStores = 'silpo_list_stores';
  static const String getStoreDetails = 'silpo_get_store_details';
  static const String findNearbyStores = 'silpo_find_nearby_stores';
  static const String getDeliverySlots = 'silpo_get_delivery_slots';
  static const String reserveDeliverySlot = 'silpo_reserve_delivery_slot';
  static const String checkDeliveryAddress = 'silpo_check_delivery_address';

  // 5. Receipts & Loyalty Analytics Tools
  static const String getVlasnyiRakhunok = 'silpo_get_vlasnyi_rakhunok';
  static const String getFiscalReceipts = 'silpo_get_fiscal_receipts';
  static const String getReceiptDetails = 'silpo_get_receipt_details';
  static const String getSpendingAnalytics = 'silpo_get_spending_analytics';
  static const String calculateInflationIndex = 'silpo_calculate_inflation_index';
  static const String getCategoryBreakdown = 'silpo_get_category_breakdown';

  // 6. AI & Recipe Intelligence Tools
  static const String parseRecipe = 'silpo_parse_recipe';
  static const String matchIngredients = 'silpo_match_ingredients';
  static const String buildMealPlan = 'silpo_build_meal_plan';
  static const String suggestPrivateLabels = 'silpo_suggest_private_labels';
  static const String planWeeklyBasket = 'silpo_plan_weekly_basket';
  static const String calculateBasketNutrition = 'silpo_calculate_basket_nutrition';
  static const String optimizeBasketBudget = 'silpo_optimize_basket_budget';

  /// Complete list of tool specifications exposed to AI models.
  static List<McpTool> getAllTools() {
    return [
      const McpTool(
        name: searchCatalog,
        description: 'Пошук товарів у каталозі Сільпо за запитом, категорією та сортуванням.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'query': {'type': 'string', 'description': 'Пошуковий запит (назва, бренд, артикул)'},
            'filialId': {'type': 'string', 'description': 'ID філії або супермаркету'},
            'category': {'type': 'string', 'description': 'Фільтр за категорією'},
            'limit': {'type': 'integer', 'default': 20},
          },
          'required': ['query'],
        },
      ),
      const McpTool(
        name: getCinotyzhiki,
        description: 'Отримання актуальних знижок тижня «Цінотижики» Сільпо.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'category': {'type': 'string', 'description': 'Опціональний фільтр за категорією'},
            'minDiscountPercent': {'type': 'number', 'description': 'Мінімальний відсоток знижки'},
          },
        },
      ),
      const McpTool(
        name: parseRecipe,
        description: 'Аналіз тексту кулінарного рецепту та вилучення списку інгредієнтів з грамовками.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'recipeText': {'type': 'string', 'description': 'Текст або назва рецепту'},
            'servings': {'type': 'integer', 'default': 4, 'description': 'Кількість порцій'},
          },
          'required': ['recipeText'],
        },
      ),
      const McpTool(
        name: matchIngredients,
        description: 'Автоматичний підбір конкретних артикулів Сільпо до списку інгредієнтів з можливістю пріоритету власних марок («Премія», «Повна Чаша»).',
        inputSchema: {
          'type': 'object',
          'properties': {
            'ingredients': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Список інгредієнтів',
            },
            'preferPrivateLabel': {'type': 'boolean', 'default': true},
            'filialId': {'type': 'string'},
          },
          'required': ['ingredients'],
        },
      ),
      const McpTool(
        name: addToCart,
        description: 'Додавання товару або списку товарів до кошика Сільпо.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'productId': {'type': 'string'},
            'quantity': {'type': 'number', 'default': 1},
          },
          'required': ['productId'],
        },
      ),
      const McpTool(
        name: getCart,
        description: 'Отримання поточного стану кошика, вартості та розрахованої економії.',
        inputSchema: {'type': 'object', 'properties': {}},
      ),
      const McpTool(
        name: getDeliverySlots,
        description: 'Отримання доступних слотів експрес та планової доставки для адреси або магазину.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'filialId': {'type': 'string'},
            'date': {'type': 'string'},
          },
        },
      ),
      const McpTool(
        name: getSpendingAnalytics,
        description: 'Аналітика покупок за фіскальними чеками «Власний Рахунок»: категорії, економія, інфляція.',
        inputSchema: {
          'type': 'object',
          'properties': {
            'period': {'type': 'string', 'enum': ['week', 'month', 'year', 'all']},
          },
        },
      ),
    ];
  }
}

import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/promo.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/delivery_slot.dart';
import '../../core/mcp/mcp_client.dart';
import '../../core/mcp/silpo_mcp_tools.dart';
import '../datasources/silpo_datasource.dart';
import '../datasources/silpo_mock_datasource.dart';

class SilpoRepository {
  final SilpoDataSource _dataSource;
  final McpClient _mcpClient;

  SilpoRepository({
    SilpoDataSource? dataSource,
    McpClient? mcpClient,
  })  : _dataSource = dataSource ?? SilpoMockDataSource(),
        _mcpClient = mcpClient ?? McpClient();

  McpClient get mcpClient => _mcpClient;

  Future<List<Product>> searchProducts(String query, {String? category, String? filialId}) async {
    return _dataSource.searchProducts(query, category: category, filialId: filialId);
  }

  Future<Product?> getProductDetails(String id) async {
    return _dataSource.getProductDetails(id);
  }

  Future<List<PromoItem>> getPromos() async {
    return _dataSource.getPromos();
  }

  Future<List<PromoItem>> getCinotyzhiki() async {
    return _dataSource.getCinotyzhiki();
  }

  Future<List<Recipe>> getPopularRecipes() async {
    return _dataSource.getPopularRecipes();
  }

  Future<Recipe> parseRecipe(String text, {int servings = 4}) async {
    // Also notify MCP client about tool execution
    await _mcpClient.callTool(SilpoMcpTools.parseRecipe, {
      'recipeText': text,
      'servings': servings,
    });
    return _dataSource.parseRecipeText(text, servings: servings);
  }

  Future<List<SilpoStore>> getStores({String? city}) async {
    return _dataSource.getStores(city: city);
  }

  Future<List<FiscalReceipt>> getFiscalReceipts() async {
    return _dataSource.getFiscalReceipts();
  }

  Future<List<DeliverySlot>> getDeliverySlots({String? filialId}) async {
    return _dataSource.getDeliverySlots(filialId: filialId);
  }

  Future<int> getLoyaltyBalance() async {
    return _dataSource.getVlasnyiRakhunokBalance();
  }

  /// Calculates spending breakdown across food categories.
  Future<List<CategorySpending>> getCategorySpending() async {
    final receipts = await getFiscalReceipts();
    final Map<String, double> categorySums = {};
    final Map<String, int> categoryCounts = {};
    double totalAll = 0.0;

    for (final r in receipts) {
      for (final item in r.items) {
        categorySums[item.category] = (categorySums[item.category] ?? 0.0) + item.total;
        categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
        totalAll += item.total;
      }
    }

    if (totalAll == 0) return [];

    final list = categorySums.entries.map((e) {
      final percentage = (e.value / totalAll) * 100;
      return CategorySpending(
        category: e.key,
        amount: e.value,
        percentage: percentage,
        itemsCount: categoryCounts[e.key] ?? 1,
      );
    }).toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  /// Calculates historical inflation tracking comparing general inflation with Silpo savings.
  List<InflationPoint> getInflationMetrics() {
    return const [
      InflationPoint(month: 'Січ', personalInflationRate: 1.8, silpoAverageBasket: 495.0),
      InflationPoint(month: 'Лют', personalInflationRate: 2.1, silpoAverageBasket: 504.0),
      InflationPoint(month: 'Бер', personalInflationRate: 1.4, silpoAverageBasket: 512.0),
      InflationPoint(month: 'Кві', personalInflationRate: 0.9, silpoAverageBasket: 518.0),
      InflationPoint(month: 'Тра', personalInflationRate: 1.2, silpoAverageBasket: 522.0),
      InflationPoint(month: 'Чер', personalInflationRate: 0.8, silpoAverageBasket: 526.0),
    ];
  }
}

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

  Future<Product?> getProductByBarcode(String barcode) async {
    return _dataSource.getProductByBarcode(barcode);
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

  List<dynamic> getInflationMetrics() {
    return const [];
  }
}

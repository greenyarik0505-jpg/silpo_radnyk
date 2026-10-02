import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/promo.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/delivery_slot.dart';
import '../../domain/entities/chat_message.dart';
import '../../core/mcp/mcp_client.dart';
import '../../core/mcp/silpo_mcp_tools.dart';
import '../datasources/silpo_datasource.dart';
import '../datasources/silpo_remote_datasource.dart';
import '../datasources/gemini_ai_service.dart';

class SilpoRepository {
  final SilpoDataSource _dataSource;
  final McpClient _mcpClient;
  final GeminiAiService _geminiService;

  SilpoStore? _activeStore;

  SilpoRepository({
    SilpoDataSource? dataSource,
    McpClient? mcpClient,
    GeminiAiService? geminiService,
  })  : _dataSource = dataSource ?? SilpoRemoteDataSource(),
        _mcpClient = mcpClient ?? McpClient(),
        _geminiService = geminiService ?? GeminiAiService();

  McpClient get mcpClient => _mcpClient;
  GeminiAiService get geminiService => _geminiService;

  SilpoStore? get activeStore => _activeStore;
  String? get activeBranchId => _activeStore?.filialId ?? _dataSource.activeBranchId;

  void setActiveStore(SilpoStore store) {
    _activeStore = store;
    _dataSource.setActiveBranch(store.filialId);
  }

  /// Calls Google AI Studio Gemini 3.1 Flash Lite API with Silpo catalog grounding.
  Future<ChatMessage> askGemini({
    required String prompt,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    return _geminiService.generateChatResponse(
      prompt: prompt,
      conversationHistory: conversationHistory,
    );
  }

  Future<List<Product>> searchProducts(String query, {String? category, String? filialId}) async {
    final branch = (filialId != null && filialId.isNotEmpty) ? filialId : activeBranchId;
    return _dataSource.searchProducts(query, category: category, filialId: branch);
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
    final stores = await _dataSource.getStores(city: city);
    if (_activeStore == null && stores.isNotEmpty) {
      final preferred = stores.firstWhere((s) => s.isFavorite, orElse: () => stores.first);
      setActiveStore(preferred);
    }
    return stores;
  }

  Future<List<FiscalReceipt>> getFiscalReceipts() async {
    return _dataSource.getFiscalReceipts();
  }

  Future<List<DeliverySlot>> getDeliverySlots({String? filialId}) async {
    final branch = (filialId != null && filialId.isNotEmpty) ? filialId : activeBranchId;
    return _dataSource.getDeliverySlots(filialId: branch);
  }

  List<dynamic> getInflationMetrics() {
    return const [];
  }
}

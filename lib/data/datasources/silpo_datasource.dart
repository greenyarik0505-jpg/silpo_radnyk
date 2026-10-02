import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/promo.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/delivery_slot.dart';

abstract class SilpoDataSource {
  Future<List<Product>> searchProducts(String query, {String? category, String? filialId});
  Future<Product?> getProductDetails(String id);
  Future<Product?> getProductByBarcode(String barcode);
  Future<List<PromoItem>> getPromos();
  Future<List<PromoItem>> getCinotyzhiki();
  Future<List<Recipe>> getPopularRecipes();
  Future<Recipe> parseRecipeText(String text, {int servings = 4});
  Future<List<SilpoStore>> getStores({String? city});
  Future<List<FiscalReceipt>> getFiscalReceipts();
  Future<List<DeliverySlot>> getDeliverySlots({String? filialId});
  void setActiveBranch(String branchId);
  String? get activeBranchId;
}

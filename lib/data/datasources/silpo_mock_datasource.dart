import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/promo.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/store.dart';
import '../../domain/entities/delivery_slot.dart';
import '../../domain/entities/silpo_boost.dart';
import 'silpo_datasource.dart';

class SilpoMockDataSource implements SilpoDataSource {
  static final Map<String, String> _barcodeToProductId = {
    '482000000001': 'p_borsch_sour_cream',
    '482000000002': 'p_coffee_lavazza',
    '482000000003': 'p_cheese_gouda',
    '482000000004': 'p_salmon_steak',
    '482000000005': 'p_borsch_pampushki',
    '482000000006': 'p_chocolate_dark',
    '482000000007': 'p_milk_galychyna',
    '482000000008': 'p_pasta_barilla',
    '482000000009': 'p_eggs_yasensvit',
    '482000000010': 'p_avocado_hass',
  };
  static final List<Product> _allProducts = [
    const Product(
      id: 'p_borsch_beef',
      title: 'Яловичина для бульйону охолоджена',
      category: 'М’ясо',
      regularPrice: 249.00,
      promoPrice: 219.00,
      unit: 'кг',
      brand: 'Сільпо Свіжачок',
      isCinotyzhik: true,
      rating: 4.8,
      bonusPoints: 22,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_borsch_beet',
      title: 'Буряк свіжий фермерський',
      category: 'Овочі та фрукти',
      regularPrice: 22.50,
      promoPrice: 17.90,
      unit: 'кг',
      brand: 'Фермерське Сільпо',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 3,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_borsch_cabbage',
      title: 'Капуста білокачанна свіжа',
      category: 'Овочі та фрукти',
      regularPrice: 28.00,
      promoPrice: null,
      unit: 'кг',
      brand: 'Сільпо',
      rating: 4.7,
      bonusPoints: 2,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_borsch_potato',
      title: 'Картопля молода добірна',
      category: 'Овочі та фрукти',
      regularPrice: 29.50,
      promoPrice: 24.90,
      unit: 'кг',
      brand: 'Сільпо',
      isCinotyzhik: false,
      rating: 4.6,
      bonusPoints: 3,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_borsch_paste',
      title: 'Томатна паста 25% «Повна Чаша» 70г',
      category: 'Бакалія',
      regularPrice: 14.50,
      promoPrice: 11.90,
      unit: 'шт',
      brand: 'Повна Чаша',
      isPrivateLabel: true,
      rating: 4.5,
      bonusPoints: 1,
      weightGrams: 70,
    ),
    const Product(
      id: 'p_borsch_sour_cream',
      title: 'Сметана 20% «Премія» 350г',
      category: 'Молочні продукти',
      regularPrice: 48.90,
      promoPrice: 39.90,
      unit: 'шт',
      brand: 'Премія',
      isCinotyzhik: true,
      isPrivateLabel: true,
      rating: 4.9,
      bonusPoints: 5,
      weightGrams: 350,
    ),
    const Product(
      id: 'p_borsch_pampushki',
      title: 'Пампушки з часником духмяні (Пекарня Сільпо)',
      category: 'Власна пекарня',
      regularPrice: 34.00,
      promoPrice: null,
      unit: 'уп',
      brand: 'Власна пекарня Сільпо',
      rating: 5.0,
      bonusPoints: 10,
      weightGrams: 200,
    ),
    // Tiramisu ingredients
    const Product(
      id: 'p_tira_mascarpone',
      title: 'Сир Маскарпоне 80% Casa Rinaldi 250г',
      category: 'Сири та масло',
      regularPrice: 145.00,
      promoPrice: 119.00,
      unit: 'шт',
      brand: 'Casa Rinaldi',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 15,
      weightGrams: 250,
    ),
    const Product(
      id: 'p_tira_savoiardi',
      title: 'Печиво Савоярді «Премія» 200г',
      category: 'Кондитерські вироби',
      regularPrice: 69.90,
      promoPrice: 54.90,
      unit: 'шт',
      brand: 'Премія',
      isPrivateLabel: true,
      rating: 4.8,
      bonusPoints: 6,
      weightGrams: 200,
    ),
    const Product(
      id: 'p_coffee_lavazza',
      title: 'Кава в зернах Lavazza Qualita Oro 250г',
      category: 'Кава та чай',
      regularPrice: 285.00,
      promoPrice: 179.00,
      unit: 'шт',
      brand: 'Lavazza',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 25,
      weightGrams: 250,
    ),
    // Keto & Fish
    const Product(
      id: 'p_salmon_steak',
      title: 'Стейк сьомги норвезької охолоджений',
      category: 'Риба та морепродукти',
      regularPrice: 549.00,
      promoPrice: 399.00,
      unit: 'кг',
      brand: 'Сільпо Fresh Fish',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 40,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_broccoli',
      title: 'Броколі свіжа добірна',
      category: 'Овочі та фрукти',
      regularPrice: 119.00,
      promoPrice: 89.00,
      unit: 'кг',
      brand: 'Сільпо',
      rating: 4.7,
      bonusPoints: 8,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_olive_oil',
      title: 'Олія оливкова Monini Extra Virgin Classico 500мл',
      category: 'Бакалія',
      regularPrice: 320.00,
      promoPrice: 259.00,
      unit: 'шт',
      brand: 'Monini',
      rating: 4.8,
      bonusPoints: 30,
      weightGrams: 500,
    ),
    const Product(
      id: 'p_cheese_gouda',
      title: 'Сир Гауда Holland Master 48%',
      category: 'Сири та масло',
      regularPrice: 420.00,
      promoPrice: 285.00,
      unit: 'кг',
      brand: 'Holland Master',
      isCinotyzhik: true,
      rating: 4.8,
      bonusPoints: 35,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_chicken_fillet',
      title: 'Філе куряче охолоджене «Сільпо Свіжачок»',
      category: 'М’ясо',
      regularPrice: 179.00,
      promoPrice: 154.90,
      unit: 'кг',
      brand: 'Сільпо Свіжачок',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 18,
      weightGrams: 1000,
    ),
    const Product(
      id: 'p_chocolate_dark',
      title: 'Шоколад чорний 70% какао «Премія» 100г',
      category: 'Кондитерські вироби',
      regularPrice: 48.00,
      promoPrice: 38.90,
      unit: 'шт',
      brand: 'Премія',
      isPrivateLabel: true,
      isCinotyzhik: true,
      rating: 4.8,
      bonusPoints: 5,
      weightGrams: 100,
    ),
    const Product(
      id: 'p_milk_galychyna',
      title: 'Молоко пастеризоване 2.5% «Галичина» 900г',
      category: 'Молочні продукти',
      regularPrice: 44.50,
      promoPrice: 36.90,
      unit: 'шт',
      brand: 'Галичина',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 4,
      weightGrams: 900,
    ),
    const Product(
      id: 'p_pasta_barilla',
      title: 'Макарони Barilla Spaghetti n.5 500г',
      category: 'Бакалія',
      regularPrice: 79.90,
      promoPrice: 59.90,
      unit: 'шт',
      brand: 'Barilla',
      isCinotyzhik: true,
      rating: 5.0,
      bonusPoints: 8,
      weightGrams: 500,
    ),
    const Product(
      id: 'p_pasta_premia',
      title: 'Спагеті з твердих сортів «Премія» 400г',
      category: 'Бакалія',
      regularPrice: 34.90,
      promoPrice: null,
      unit: 'шт',
      brand: 'Премія',
      isPrivateLabel: true,
      rating: 4.6,
      bonusPoints: 3,
      weightGrams: 400,
    ),
    const Product(
      id: 'p_eggs_yasensvit',
      title: 'Яйця курячі добірні С0 «Ясенсвіт» 10 шт',
      category: 'Яйця',
      regularPrice: 68.00,
      promoPrice: 56.90,
      unit: 'уп',
      brand: 'Ясенсвіт',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 6,
      weightGrams: 650,
    ),
    const Product(
      id: 'p_avocado_hass',
      title: 'Авокадо Хасс стигле Ready to Eat (2 шт)',
      category: 'Овочі та фрукти',
      regularPrice: 129.00,
      promoPrice: 99.00,
      unit: 'уп',
      brand: 'Власний імпорт Сільпо',
      isCinotyzhik: true,
      rating: 4.9,
      bonusPoints: 12,
      weightGrams: 300,
    ),
    const Product(
      id: 'p_cottage_cheese',
      title: 'Сир кисломолочний 9% «Премія» 350г',
      category: 'Молочні продукти',
      regularPrice: 64.00,
      promoPrice: 52.90,
      unit: 'шт',
      brand: 'Премія',
      isPrivateLabel: true,
      rating: 4.8,
      bonusPoints: 6,
      weightGrams: 350,
    ),
  ];

  @override
  Future<List<Product>> searchProducts(String query, {String? category, String? filialId}) async {
    final lower = query.trim().toLowerCase();
    return _allProducts.where((p) {
      final matchesQuery = lower.isEmpty ||
          p.title.toLowerCase().contains(lower) ||
          (p.brand != null && p.brand!.toLowerCase().contains(lower));
      final matchesCategory = category == null || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<Product?> getProductDetails(String id) async {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PromoItem>> getPromos() async {
    return [
      PromoItem(
        id: 'promo_1',
        title: '«Цінотижики»: Знижки до -45% на сири та каву',
        description: 'Спеціальні ціни на улюблені європейські сири та зернову каву преміум якості.',
        type: PromoType.cinotyzhik,
        discountPercent: 40,
        originalPrice: 285.00,
        promoPrice: 179.00,
        validUntil: DateTime.now().add(const Duration(days: 4)),
        category: 'Кава та сири',
      ),
      PromoItem(
        id: 'promo_2',
        title: 'Свіжий улов: Норвезький лосось -28%',
        description: 'Прямі поставки охолодженої червоної риби на рибний острів Сільпо.',
        type: PromoType.cinotyzhik,
        discountPercent: 28,
        originalPrice: 549.00,
        promoPrice: 399.00,
        validUntil: DateTime.now().add(const Duration(days: 3)),
        category: 'Риба',
      ),
      PromoItem(
        id: 'promo_3',
        title: 'Колесо Фортуни: х5 балобонусів на випічку',
        description: 'Крутіть колесо в додатку та отримуйте помножувач балів на круасани та хліб.',
        type: PromoType.wheelOfFortune,
        discountPercent: 15,
        validUntil: DateTime.now().add(const Duration(days: 6)),
        category: 'Пекарня',
        bonusMultiplier: 5,
      ),
      PromoItem(
        id: 'promo_4',
        title: 'Персональна знижка на улюблену молочку «Премія»',
        description: 'Знижка -20% на сметану, кефір та сир кисломолочний власної марки.',
        type: PromoType.personalDeal,
        discountPercent: 20,
        originalPrice: 48.90,
        promoPrice: 39.90,
        validUntil: DateTime.now().add(const Duration(days: 5)),
        category: 'Молочні продукти',
      ),
    ];
  }

  @override
  Future<List<PromoItem>> getCinotyzhiki() async {
    final promos = await getPromos();
    return promos.where((p) => p.type == PromoType.cinotyzhik).toList();
  }

  @override
  Future<List<Recipe>> getPopularRecipes() async {
    return [
      Recipe(
        id: 'recipe_borsch',
        title: 'Традиційний український борщ з пампушками',
        description: 'Ароматний червоний борщ на яловичому бульйоні зі свіжими пампушками з часниковим соусом.',
        cookTimeMinutes: 90,
        difficulty: 'Середнє',
        servings: 4,
        dietaryTags: ['Українська кухня', 'Ситне', 'Традиційне'],
        ingredients: [
          RecipeIngredient(
            name: 'Яловичина для бульйону',
            amount: 0.6,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_beef'),
          ),
          RecipeIngredient(
            name: 'Буряк свіжий',
            amount: 0.5,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_beet'),
          ),
          RecipeIngredient(
            name: 'Капуста білокачанна',
            amount: 0.5,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_cabbage'),
          ),
          RecipeIngredient(
            name: 'Картопля молода',
            amount: 0.5,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_potato'),
          ),
          RecipeIngredient(
            name: 'Томатна паста «Повна Чаша»',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_paste'),
          ),
          RecipeIngredient(
            name: 'Сметана 20% «Премія»',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_sour_cream'),
          ),
          RecipeIngredient(
            name: 'Пампушки з часником',
            amount: 1,
            unit: 'уп',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_pampushki'),
          ),
        ],
        steps: [
          'Зваріть насичений яловичий бульйон (близько 60-75 хвилин), знімаючи піну.',
          'Буряк натріть та злегка стушкуйте з томатною пастою «Повна Чаша» та краплею лимонного соку для яскравого кольору.',
          'У киплячий бульйон додайте нарізану картоплю, через 10 хвилин — нашатковану капусту.',
          'Додайте тушкований буряк та спеції за смаком, варіть ще 5-7 хвилин на слабкому вогні.',
          'Подавайте гарячим зі свіжою сметаною «Премія» та часниковими пампушками з власної пекарні!',
        ],
      ),
      Recipe(
        id: 'recipe_tiramisu',
        title: 'Класичний домашній Тірамісу',
        description: 'Ніжний італійський десерт на основі сиру Маскарпоне, печива Савоярді та ароматної свіжозвареної еспресо-кави.',
        cookTimeMinutes: 25,
        difficulty: 'Легко',
        servings: 6,
        dietaryTags: ['Десерт', 'Італійська кухня', 'Без випікання'],
        ingredients: [
          RecipeIngredient(
            name: 'Сир Маскарпоне Casa Rinaldi',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_tira_mascarpone'),
          ),
          RecipeIngredient(
            name: 'Печиво Савоярді «Премія»',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_tira_savoiardi'),
          ),
          RecipeIngredient(
            name: 'Кава в зернах Lavazza Oro',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_coffee_lavazza'),
          ),
        ],
        steps: [
          'Зваріть міцне еспресо з кави Lavazza та дайте йому охолонути до кімнатної температури.',
          'Збийте сир Маскарпоне з цукровою пудрою до повітряної шовковистої текстури.',
          'Занурюйте кожне печиво Савоярді в охолоджену каву на 1-2 секунди та викладайте у форму.',
          'Покрийте шаром крему з Маскарпоне, повторіть шар і посипте темним какао перед подачею.',
        ],
      ),
      Recipe(
        id: 'recipe_keto_salmon',
        title: 'Кето-вечеря: Стейк лосося на пару з броколі',
        description: 'Ідеально збалансована низьковуглеводна вечеря з високим вмістом Omega-3 та корисних жирів.',
        cookTimeMinutes: 20,
        difficulty: 'Легко',
        servings: 2,
        dietaryTags: ['Кето', 'Низьковуглеводне', 'Здорове харчування', 'Omega-3'],
        ingredients: [
          RecipeIngredient(
            name: 'Стейк сьомги норвезької',
            amount: 0.5,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_salmon_steak'),
          ),
          RecipeIngredient(
            name: 'Броколі свіжа',
            amount: 0.5,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_broccoli'),
          ),
          RecipeIngredient(
            name: 'Олія оливкова Monini Extra Virgin',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_olive_oil'),
          ),
        ],
        steps: [
          'Лосось натріть дрібкою морської солі та збризніть оливковою олією Extra Virgin.',
          'Броколі розберіть на суцвіття та приготуйте на пару протягом 6 хвилин до стану al dente.',
          'Стейк лосося обсмажте на гриль-пательні по 3-4 хвилини з кожного боку або запечіть при 180°C.',
        ],
      ),
      Recipe(
        id: 'recipe_pasta',
        title: 'Італійська паста Spaghetti al Pomodoro',
        description: 'Класична середземноморська паста з томатним соусом, базиліком та оливковою олією.',
        cookTimeMinutes: 15,
        difficulty: 'Легко',
        servings: 2,
        dietaryTags: ['Вегетаріанське', 'Швидко', 'Італійська кухня'],
        ingredients: [
          RecipeIngredient(
            name: 'Паста Спагеті',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_pasta_barilla'),
            substituteProduct: _allProducts.firstWhere((p) => p.id == 'p_pasta_premia'),
          ),
          RecipeIngredient(
            name: 'Томатна паста 25%',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_paste'),
          ),
          RecipeIngredient(
            name: 'Олія оливкова Extra Virgin',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_olive_oil'),
          ),
          RecipeIngredient(
            name: 'Сир Гауда тертий',
            amount: 0.2,
            unit: 'кг',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_cheese_gouda'),
          ),
        ],
        steps: [
          'Відваріть спагеті у підсоленій киплячій воді до стану al dente (близько 8 хвилин).',
          'На оливковій олії прогрійте томатну пасту з додаванням 50 мл води від пасти.',
          'З’єднайте пасту з соусом, посипте тертим сиром та свіжомеленим перцем.',
        ],
      ),
      Recipe(
        id: 'recipe_syrnyky',
        title: 'Ніжні домашні сирники зі сметаною',
        description: 'Ідеальний сніданок з ніжного кисломолочного сиру з хрусткою золотистою скоринкою.',
        cookTimeMinutes: 20,
        difficulty: 'Легко',
        servings: 3,
        dietaryTags: ['Сніданок', 'Вегетаріанське', 'Традиційне'],
        ingredients: [
          RecipeIngredient(
            name: 'Сир кисломолочний 9%',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_cottage_cheese'),
          ),
          RecipeIngredient(
            name: 'Яйця курячі С0',
            amount: 1,
            unit: 'уп',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_eggs_yasensvit'),
          ),
          RecipeIngredient(
            name: 'Сметана 20% «Премія»',
            amount: 1,
            unit: 'шт',
            matchedProduct: _allProducts.firstWhere((p) => p.id == 'p_borsch_sour_cream'),
          ),
        ],
        steps: [
          'Перетріть сир з яйцем та дрібкою солі до однорідності.',
          'Сформуйте акуратні сирники та обкачайте у невеликій кількості борошна.',
          'Обсмажте на середньому вогні по 3-4 хвилини з кожного боку до золотавої скоринки.',
          'Подавайте теплими з густою сметаною «Премія».',
        ],
      ),
    ];
  }

  @override
  Future<Recipe> parseRecipeText(String text, {int servings = 4}) async {
    final lower = text.toLowerCase();
    final recipes = await getPopularRecipes();

    Recipe matched;
    if (lower.contains('борщ') || lower.contains('буряк')) {
      matched = recipes.firstWhere((r) => r.id == 'recipe_borsch');
    } else if (lower.contains('тірамісу') || lower.contains('десерт') || lower.contains('савоярді')) {
      matched = recipes.firstWhere((r) => r.id == 'recipe_tiramisu');
    } else if (lower.contains('кето') || lower.contains('лосос') || lower.contains('сьомг')) {
      matched = recipes.firstWhere((r) => r.id == 'recipe_keto_salmon');
    } else if (lower.contains('паст') || lower.contains('спагет') || lower.contains('макарон')) {
      matched = recipes.firstWhere((r) => r.id == 'recipe_pasta');
    } else if (lower.contains('сирник') || lower.contains('сніданок')) {
      matched = recipes.firstWhere((r) => r.id == 'recipe_syrnyky');
    } else {
      matched = recipes.first;
    }

    return matched.scaleServings(servings);
  }

  @override
  Future<List<SilpoStore>> getStores({String? city}) async {
    final stores = [
      const SilpoStore(
        filialId: 'silpo_kyiv_gulliver',
        name: 'Сільпо в ТРЦ Gulliver',
        address: 'Спортивна площа, 1-А',
        city: 'Київ',
        workingHours: '08:00 - 23:00',
        latitude: 50.4385,
        longitude: 30.5230,
        conceptTheme: 'Музичний арт-простір',
        amenities: ['Власна пекарня', 'Feeltrd кава', 'Суші-бар', 'Крафтове пиво Beermaster'],
        hasGenerator: true,
        isFavorite: true,
        distanceKm: 0.8,
      ),
      const SilpoStore(
        filialId: 'silpo_kyiv_rivermall',
        name: 'Сільпо в ТРЦ River Mall',
        address: 'Дніпровська набережна, 12',
        city: 'Київ',
        workingHours: '08:00 - 22:30',
        latitude: 50.4048,
        longitude: 30.6133,
        conceptTheme: 'Мавка. Лісова пісня',
        amenities: ['Пекарня на дровах', 'Рибокоптильня', 'Піцерія', 'Кулінарія'],
        hasGenerator: true,
        distanceKm: 4.5,
      ),
      const SilpoStore(
        filialId: 'silpo_lviv_victoria',
        name: 'Сільпо в ТРЦ Victoria Gardens',
        address: 'вул. Кульпарківська, 226-А',
        city: 'Львів',
        workingHours: '08:00 - 22:00',
        latitude: 49.8077,
        longitude: 23.9782,
        conceptTheme: 'Стимпанк та наукова фантастика',
        amenities: ['Власна сироварня', 'Дров’яна піч', 'Винний бутік'],
        hasGenerator: true,
        distanceKm: 2.1,
      ),
      const SilpoStore(
        filialId: 'silpo_odesa_citycenter',
        name: 'Сільпо в ТРЦ City Center',
        address: 'просп. Небесної Сотні, 2',
        city: 'Одеса',
        workingHours: '08:00 - 22:00',
        latitude: 46.4258,
        longitude: 30.7042,
        conceptTheme: 'Вінтажний цирк',
        amenities: ['Морепродукти на льоду', 'Feeltrd кав’ярня', 'Свіжа випічка'],
        hasGenerator: true,
        distanceKm: 3.2,
      ),
    ];

    if (city != null) {
      return stores.where((s) => s.city.toLowerCase() == city.toLowerCase()).toList();
    }
    return stores;
  }

  @override
  Future<List<FiscalReceipt>> getFiscalReceipts() async {
    return [
      FiscalReceipt(
        id: 'rec_109284',
        fiscalNumber: 'ФЧ-98214-382910',
        dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        storeAddress: 'Київ, Спортивна пл., 1-А (ТРЦ Gulliver)',
        totalAmount: 432.80,
        discountAmount: 94.20,
        bonusPointsEarned: 86,
        paymentMethod: 'Apple Pay',
        items: const [
          ReceiptItem(
            name: 'Сир Гауда Holland Master 48%',
            quantity: 0.4,
            unit: 'кг',
            price: 285.00,
            total: 114.00,
            discountAmount: 54.00,
            category: 'Сири та масло',
          ),
          ReceiptItem(
            name: 'Кава в зернах Lavazza Oro 250г',
            quantity: 1,
            unit: 'шт',
            price: 179.00,
            total: 179.00,
            discountAmount: 106.00,
            category: 'Бакалія',
          ),
          ReceiptItem(
            name: 'Сметана 20% «Премія» 350г',
            quantity: 1,
            unit: 'шт',
            price: 39.90,
            total: 39.90,
            discountAmount: 9.00,
            category: 'Молочні продукти',
          ),
          ReceiptItem(
            name: 'Пампушки з часником',
            quantity: 2,
            unit: 'уп',
            price: 34.00,
            total: 68.00,
            discountAmount: 0.0,
            category: 'Власна пекарня',
          ),
          ReceiptItem(
            name: 'Пакет біорозкладний Сільпо',
            quantity: 1,
            unit: 'шт',
            price: 2.50,
            total: 2.50,
            discountAmount: 0.0,
            category: 'Супутні',
          ),
        ],
      ),
      FiscalReceipt(
        id: 'rec_108192',
        fiscalNumber: 'ФЧ-81920-192837',
        dateTime: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
        storeAddress: 'Київ, Спортивна пл., 1-А (ТРЦ Gulliver)',
        totalAmount: 588.00,
        discountAmount: 150.00,
        bonusPointsEarned: 118,
        paymentMethod: 'Власний Рахунок QR',
        items: const [
          ReceiptItem(
            name: 'Стейк сьомги норвезької',
            quantity: 1.2,
            unit: 'кг',
            price: 399.00,
            total: 478.80,
            discountAmount: 180.00,
            category: 'Риба та морепродукти',
          ),
          ReceiptItem(
            name: 'Броколі свіжа добірна',
            quantity: 0.9,
            unit: 'кг',
            price: 89.00,
            total: 80.10,
            discountAmount: 27.00,
            category: 'Овочі та фрукти',
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<DeliverySlot>> getDeliverySlots({String? filialId}) async {
    final now = DateTime.now();
    return [
      DeliverySlot(
        id: 'slot_express',
        type: DeliveryType.express,
        timeRange: '35 - 45 хвилин',
        date: now,
        deliveryFee: 49.00,
        description: 'Кур’єр виїжджає негайно з найближчого Сільпо',
      ),
      DeliverySlot(
        id: 'slot_sched_1',
        type: DeliveryType.scheduled,
        timeRange: '18:00 - 20:00',
        date: now,
        deliveryFee: 0.0, // Безкоштовно від 399 грн
        description: 'Зручний вечірній 2-годинний слот (Безкоштовно)',
      ),
      DeliverySlot(
        id: 'slot_sched_2',
        type: DeliveryType.scheduled,
        timeRange: '20:00 - 22:00',
        date: now,
        deliveryFee: 0.0,
        description: 'Пізній вечірній слот (Безкоштовно)',
      ),
      DeliverySlot(
        id: 'slot_pickup',
        type: DeliveryType.selfPickup,
        timeRange: 'Готово через 20 хв',
        date: now,
        deliveryFee: 0.0,
        description: 'Забрати самостійно на стійці самовивозу в супермаркеті',
      ),
    ];
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final clean = barcode.trim();
    final productId = _barcodeToProductId[clean];
    if (productId != null) {
      return getProductDetails(productId);
    }
    return getProductDetails(clean);
  }

  @override
  Future<int> getVlasnyiRakhunokBalance() async {
    return 1450; // 1450 балобонусів = 14.50 грн знижки
  }

  static final List<SilpoBoostCoupon> _boostCoupons = [
    SilpoBoostCoupon(
      id: 'boost_coffee_x3',
      title: 'Буст x3 на каву Feeltrd та зернову каву',
      category: 'Кава та чай',
      multiplier: 3.0,
      badgeText: 'x3 БАЛОЧОК',
      description: 'Потрійні бали «Власний Рахунок» на всю каву в зернах та гарячі напої Feeltrd.',
      isActivated: true,
      expiresAt: DateTime.now().add(const Duration(days: 6)),
      icon: Icons.coffee,
    ),
    SilpoBoostCoupon(
      id: 'boost_bakery_x5',
      title: 'Буст x5 на духмяну випічку Власної пекарні',
      category: 'Власна пекарня',
      multiplier: 5.0,
      badgeText: 'x5 БАЛОЧОК',
      description: 'П’ятикратні бали на круасани, багети, хліб та авторські пироги.',
      isActivated: false,
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      icon: Icons.bakery_dining,
    ),
    SilpoBoostCoupon(
      id: 'boost_meat_x2',
      title: 'Буст x2 на охолоджене м’ясо «Свіжачок»',
      category: 'М’ясо',
      multiplier: 2.0,
      badgeText: 'x2 БАЛОЧОК',
      description: 'Подвійне нарахування балів при купівлі свіжої телятини, яловичини та птиці.',
      isActivated: true,
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      icon: Icons.kebab_dining,
    ),
    SilpoBoostCoupon(
      id: 'boost_cheese_x3',
      title: 'Буст x3 на крафтові європейські сири',
      category: 'Сири та масло',
      multiplier: 3.0,
      badgeText: 'x3 БАЛОЧОК',
      description: 'Потрійні бали на пармезан, гауду, брі та сири власної сироварні.',
      isActivated: false,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      icon: Icons.lunch_dining,
    ),
    SilpoBoostCoupon(
      id: 'boost_receipt_1000',
      title: '+1000 балочок на чек від 500 грн',
      category: 'Усі товари',
      extraBonusPoints: 1000,
      badgeText: '+1000 БАЛІВ',
      description: 'Одноразовий супер-буст на 1000 балобонусів при загальній сумі чека від 500 ₴.',
      isActivated: false,
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      icon: Icons.stars,
    ),
  ];

  @override
  Future<List<SilpoBoostCoupon>> getBoostCoupons() async {
    return List.unmodifiable(_boostCoupons);
  }

  @override
  Future<bool> activateBoostCoupon(String couponId) async {
    final idx = _boostCoupons.indexWhere((c) => c.id == couponId);
    if (idx != -1) {
      final current = _boostCoupons[idx];
      _boostCoupons[idx] = current.copyWith(isActivated: !current.isActivated);
      return true;
    }
    return false;
  }

  @override
  Future<FiscalReceipt?> importFiscalReceiptByQr(String qrContent) async {
    final receipt = FiscalReceipt(
      id: 'rec_qr_${DateTime.now().millisecondsSinceEpoch}',
      fiscalNumber: 'ФЧ-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      dateTime: DateTime.now(),
      storeAddress: 'Київ, ТРЦ Gulliver (Вільнокаса QR)',
      totalAmount: 248.50,
      discountAmount: 42.00,
      bonusPointsEarned: 48,
      paymentMethod: 'Власний Рахунок QR',
      items: const [
        ReceiptItem(
          name: 'Сметана 20% «Премія» 350г',
          quantity: 1,
          unit: 'шт',
          price: 39.90,
          total: 39.90,
          discountAmount: 9.00,
          category: 'Молочні продукти',
        ),
        ReceiptItem(
          name: 'Шоколад чорний 70% «Премія» 100г',
          quantity: 2,
          unit: 'шт',
          price: 39.90,
          total: 79.80,
          discountAmount: 16.20,
          category: 'Кондитерські вироби',
        ),
        ReceiptItem(
          name: 'Пампушки з часником',
          quantity: 1,
          unit: 'уп',
          price: 34.00,
          total: 34.00,
          discountAmount: 0.0,
          category: 'Власна пекарня',
        ),
      ],
    );
    return receipt;
  }
}

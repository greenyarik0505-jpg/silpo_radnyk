# ⚡ Специфікація Silpo Model Context Protocol (MCP)

Офіційний сервер MCP мережі супермаркетів «Сільпо» реалізує відкритий протокол **Model Context Protocol (MCP)**, що дозволяє AI-моделям та агентам безпечно взаємодіяти з каталогом, кошиком, акціями та програмою лояльності «Власний Рахунок».

---

## 1. Підключення та авторизація

- **Базовий Endpoint**: `https://mcp.silpo.ua/mcp`
- **Протокол**: JSON-RPC 2.0 через `Streamable HTTP / Server-Sent Events (SSE)`
- **Аутентифікація**: OAuth 2.1 з розширенням PKCE (Proof Key for Code Exchange)
- **Заголовки**:
  ```http
  Content-Type: application/json
  Accept: application/json, text/event-stream
  Authorization: Bearer <access_token>
  X-Client-Platform: flutter-sulipo-pomoshuk
  ```

---

## 2. Каталог 39 інструментів Silpo MCP

### Група 1: Каталог та Пошук (Catalog & Search)
1. `silpo_search_catalog`: Пошук товарів за назвою, категорією, брендом та філією.
2. `silpo_get_product_details`: Отримання повних характеристик, КБЖВ, складу та сертифікатів.
3. `silpo_get_product_by_barcode`: Миттєвий пошук товару за штрихкодом (EAN-13).
4. `silpo_get_categories`: Дерево категорій Сільпо (Овочі, М'ясо, Сири, Пекарня тощо).
5. `silpo_get_recommendations`: Товарні рекомендації на базі історії замовлень.
6. `silpo_search_substitutions`: Підбір дешевших або якісніших аналогів.
7. `silpo_filter_by_dietary`: Фільтрація за дієтичними ознаками (веган, кето, без цукру, БГ).

### Група 2: Акції та Знижки (Promos & Discounts)
8. `silpo_get_cinotyzhiki`: Список актуальних знижок тижня «Цінотижики».
9. `silpo_get_wheel_of_fortune`: Доступні призи та обертання «Колеса Фортуни».
10. `silpo_spin_wheel_of_fortune`: Запуск щоденного обертання та нарахування призу.
11. `silpo_get_personal_deals`: Персональні купони та пропозиції в додатку.
12. `silpo_get_price_drops`: Список товарів зі значним зниженням ціни.
13. `silpo_get_loyalty_multipliers`: Категорії з підвищеним нарахуванням балів (х3, х5).

### Група 3: Кошик та Оформлення (Cart & Checkout)
14. `silpo_get_cart`: Отримання поточного кошика та розрахованої економії.
15. `silpo_add_to_cart`: Додавання товару із зазначенням кількості (шт/кг).
16. `silpo_update_cart_item`: Зміна кількості або видалення позиції.
17. `silpo_remove_from_cart`: Видалення конкретного товару.
18. `silpo_clear_cart`: Повне очищення кошика.
19. `silpo_apply_promo_code`: Застосування промокоду на знижку або безкоштовну доставку.
20. `silpo_add_ingredients_to_cart`: Масове додавання інгредієнтів рецепта в кошик.

### Група 4: Супермаркети та Доставка (Stores & Logistics)
21. `silpo_list_stores`: Список супермаркетів з координатами та концептами дизайну.
22. `silpo_get_store_details`: Детальна інформація про філію, сервіси, графік роботи.
23. `silpo_find_nearby_stores`: Пошук найближчих магазинів за геолокацією.
24. `silpo_get_delivery_slots`: Доступні слоти експрес (40 хв) та планової доставки.
25. `silpo_reserve_delivery_slot`: Тимчасове бронювання слота на час збірки.
26. `silpo_check_delivery_address`: Перевірка можливості доставки за вказаною адресою.

### Група 5: Чеки та Лояльність (Receipts & Analytics)
27. `silpo_get_vlasnyi_rakhunok`: Баланс балобонусів програми «Власний Рахунок».
28. `silpo_get_fiscal_receipts`: Отримання історії фіскальних чеків з деталізацією.
29. `silpo_get_receipt_details`: Розгорнутий склад чека за фіскальним номером.
30. `silpo_get_spending_analytics`: Агрегація витрат за категоріями та періодами.
31. `silpo_calculate_inflation_index`: Розрахунок персонального індексу продуктової інфляції.
32. `silpo_get_category_breakdown`: Розподіл витрат за категоріями у відсотках.

### Група 6: AI-кулінарія та Рецепти (AI Culinary Engine)
33. `silpo_parse_recipe`: Синтаксичний та семантичний розбір рецепта на інгредієнти.
34. `silpo_match_ingredients`: Зіставлення інгредієнтів з каталогом та марками Сільпо.
35. `silpo_build_meal_plan`: Побудова меню на день/тиждень за бюджетом та калоражем.
36. `silpo_suggest_private_labels`: Пріоритизація марок «Премія» та «Повна Чаша».
37. `silpo_plan_weekly_basket`: Формування регулярного кошика автопоповнення.
38. `silpo_calculate_basket_nutrition`: Підрахунок калорійності та КБЖВ обраного кошика.
39. `silpo_optimize_basket_budget`: Оптимізація кошика під задану максимальну суму.

---

## 3. Приклад виклику через JSON-RPC 2.0

### Запит (tools/call):
```json
{
  "jsonrpc": "2.0",
  "id": 101,
  "method": "tools/call",
  "params": {
    "name": "silpo_parse_recipe",
    "arguments": {
      "recipeText": "Український борщ на яловичині з квасолею та сметаною",
      "servings": 4
    }
  }
}
```

### Відповідь (result):
```json
{
  "jsonrpc": "2.0",
  "id": 101,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Рецепт успішно розпізнано: 7 обов'язкових інгредієнтів зіставлено з товарами Сільпо на суму 342.50 грн (економія 48.00 грн за акціями)."
      }
    ],
    "isError": false
  }
}
```

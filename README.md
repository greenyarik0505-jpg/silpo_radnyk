# 🍊 Сільпо Помічник (Silpo Shopping Assistant)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart&logoColor=white)
![AI Assistant](https://img.shields.io/badge/AI%20Assistant-Silpo%20Catalog-FF6A00?logo=sparkles&logoColor=white)
![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-blue)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Made in Ukraine](https://img.shields.io/badge/Made%20in-Ukraine%20🇺🇦-FFD700?labelColor=0057B7)

**Зручний та чесний мобільний помічник для покупців «Сільпо»: AI-Шеф для підбору продуктів під страви, перегляд складу та прямі посилання на товари на silpo.ua, актуальні акції «Цінотижики», список покупок та пошук супермаркетів Сільпо з генераторами ⚡**

[Можливості](#-можливості-додатку) •
[Склад товарів та посилання](#-перегляд-складу-та-посилання-на-silpoua) •
[Швидкий старт](#-швидкий-старт) •
[English Summary](#-english-summary)

---

</div>

## 💡 Про проєкт

**«Сільпо Помічник»** — це кросплатформний додаток на Flutter, створений для комфортних щоденних покупок у мережі супермаркетів «Сільпо».

Жодних вигаданих гейміфікацій чи непотрібних функцій — лише те, що дійсно потрібно покупцеві:
1. Запитати в AI рецепт і отримати точний перелік продуктів з каталогу Сільпо.
2. Натиснути на будь-який товар, щоб переглянути його **повний склад та інгредієнти**, отримати **пряме посилання на silpo.ua**, а для страв — побачити продукти, з яких їх готувати, також із посиланнями на Сільпо.
3. Переглядати справжні щотижневі знижки **«Цінотижики»**.
4. Знаходити найближчі супермаркети Сільпо з фільтрами за наявністю **генератора (працюють під час блекаутів ⚡)**, **власної пекарні** та **кав'ярні Feeltrd**.

---

## ✨ Можливості додатку

### 1. 🍲 AI-Шеф & Рецепти під бюджет
* **Підбір продуктів під будь-яку страву**: напишіть *"Борщ на 4 порції"*, *"Паста Карбонара"* чи *"Легка вечеря до 200 грн"*, і AI-асистент підбере необхідні позиції з каталогу Сільпо.
* **Масштабування порцій (- / +)**: зміна кількості порцій в один дотик з автоматичним перерахунком ваги інгредієнтів та суми.
* **Розумні заміни (Smart Swap)**: підказки вигідних альтернатив власних марок Сільпо (*«Премія»*, *«Повна Чаша»*) для економії бюджету.
* **В 1 клік до списку**: додавання всіх продуктів для страви у список покупок однією кнопкою.

### 2. 🔍 Перегляд складу та прямі посилання на silpo.ua
Натисніть на будь-який товар або інгредієнт, щоб відкрити інформаційну картку:
* **📋 Повний склад**: детальний перелік інгредієнтів продукту з етикетки.
* **🥗 З чого приготувати (товари в Сільпо)**: якщо це готова страва, випічка чи напівфабрикат — розкладка на окремі продукти з цінами та **прямими посиланнями на Сільпо** для кожного з них.
* **🔗 Офіційне посилання на silpo.ua**: прямий лінк на сторінку товару в інтернет-магазині Сільпо з можливістю швидкого копіювання або переходу.

### 3. 🏷️ Актуальні акції «Цінотижики»
* Щотижневий акційний каталог із реальними знижками до -50%.
* Зручна фільтрація за категоріями: М'ясо, Овочі та фрукти, Сири, Кава, Випічка, Риба.
* Наочний таймер кількості днів до завершення акції.

### 4. 🛒 Зручний список покупок
* Швидкий підрахунок загальної вартості кошика та суми зекономлених грошей.
* Керування кількістю кожного товару (+/-), видалення або повне очищення.

### 5. 🏪 Пошук супермаркетів «Сільпо» поруч
* Пошук магазинів за адресою або містом (Київ, Львів, Одеса, Дніпро, Харків).
* **Спеціальні фільтри сервісів**:
  * ⚡ **З генератором** — супермаркети, що безперебійно працюють під час відключень електрики.
  * 🥐 **Власна пекарня** — гарячий свіжий хліб, багети та круасани.
  * ☕ **Кав'ярня Feeltrd** — авторська спешелті кава всередині магазину.
* Відображення концептуальних тем арт-магазинів (*«Мавка»*, *«Стимпанк»*, *«Вінтажний цирк»*) та графіку роботи.

### 6. 📱 «Вільнокаса» — сканер у магазині
* Скануйте штрих-код товару (EAN-13) камерою прямо біля полиці в магазині, щоб дізнатися ціну, наявність знижки та додати його у свій список.

---

## 🚀 Швидкий старт

### Вимоги
* Встановлений [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.10`, рекомендовано `3.24+`).
* Dart SDK `>= 3.0`.

### 1. Клонування репозиторію
```bash
git clone https://github.com/your-username/sulipo_pomoshuk.git
cd sulipo_pomoshuk
```

### 2. Завантаження залежностей
```bash
flutter pub get
```

### 3. Запуск додатку
```bash
# Мобільний додаток (Android / iOS):
flutter run

# Веб-версія:
flutter run -d chrome

# Настільна версія Windows:
flutter run -d windows
```

### 4. Тестування та перевірка коду
```bash
# Статичний аналіз коду (0 зауважень):
flutter analyze

# Запуск автоматичних тестів:
flutter test
```

---

## 🏛 Архітектура додатку

* **`lib/domain/`**: Сутності предметної області (`Product`, `ProductIngredientItem`, `Recipe`, `PromoItem`, `SilpoStore`).
* **`lib/data/`**: Репозиторій та джерело даних Сільпо з реальними артикулами, складами, посиланнями та штрих-кодами EAN-13.
* **`lib/presentation/`**:
  * `screens/`: AI-чат, Акції та Цінотижики, Список покупок, Супермаркети Сільпо, Вільнокаса.
  * `widgets/`: `ProductDetailsSheet` (склад, посилання на Сільпо, складові страви), `ProductCard`, `PromoCard`.
  * `viewmodels/`: чисте керування станом (MVVM) без сторонніх надмірностей.

---

## 🌐 English Summary

### Silpo Shopping Assistant (`sulipo_pomoshuk`)
A practical, user-focused **Flutter** application for shoppers at **Silpo** supermarkets in Ukraine.

### Core Features:
1. **AI Chef & Recipe Meal Planner**: Transforms any dish or idea into a precise grocery list with portion adjustments and affordable private-label swaps (*«Премія»*, *«Повна Чаша»*).
2. **Product Ingredients & Direct Silpo Links**: Tap any product to view its complete composition/ingredients label, direct web link to `silpo.ua`, and for cooked dishes/sets — the breakdown of raw ingredients with their individual Silpo store links.
3. **Weekly Deals («Tsinotyzhiki»)**: Browse active promotions with verified price reductions and category filters.
4. **Shopping Basket**: Clean item checklist with real-time budget and discount calculation.
5. **Silpo Stores Finder with Power Generator Filters ⚡**: Find stores that remain open during blackouts thanks to backup generators, plus filters for in-store bakeries and Feeltrd cafes.
6. **«Vilnokasa» Barcode Scanner**: Scan barcodes right in the aisles to check prices and add to your list.

---

## 📄 Ліцензія

Проєкт розповсюджується під ліцензією [MIT](LICENSE).  
Створено для зручних і свідомих покупок у «Сільпо»! 🍊🇺🇦

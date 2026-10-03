import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sulipo_pomoshuk/data/repositories/silpo_repository.dart';
import 'package:sulipo_pomoshuk/presentation/screens/stores_screen.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/mcp_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/store_viewmodel.dart';
import 'package:sulipo_pomoshuk/presentation/viewmodels/cart_viewmodel.dart';

void main() {
  group('StoresScreen UI & Absence of Obsolete Filters Tests', () {
    late SilpoRepository repository;
    late StoreViewModel storeViewModel;
    late McpViewModel mcpViewModel;
    late CartViewModel cartViewModel;

    setUp(() {
      repository = SilpoRepository();
      storeViewModel = StoreViewModel(repository: repository);
      mcpViewModel = McpViewModel(repository: repository);
      cartViewModel = CartViewModel(repository: repository);
    });

    testWidgets('StoresScreen renders search, cities, and NO deleted service chips', (tester) async {
      await storeViewModel.loadStores();

      await tester.pumpWidget(
        MaterialApp(
          home: StoresScreen(
            storeViewModel: storeViewModel,
            mcpViewModel: mcpViewModel,
            cartViewModel: cartViewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify search input exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Пошук серед 460+ супермаркетів'), findsOneWidget);

      // 2. Verify City chips exist
      expect(find.widgetWithText(ChoiceChip, 'Всі міста'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Київ'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Львів'), findsOneWidget);

      // 3. Verify deleted service filter chips are completely absent from filter area
      // (The top horizontal filter chip row has been deleted as requested)
      expect(find.widgetWithText(ChoiceChip, 'З генератором'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Власна пекарня'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, "Кав'ярня Feeltrd"), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Зарядка EV'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Аптека'), findsNothing);

      // 4. Verify store cards are rendered
      expect(find.textContaining('Gulliver'), findsWidgets);
    });

    testWidgets('City filter selection updates displayed stores', (tester) async {
      await storeViewModel.loadStores();

      await tester.pumpWidget(
        MaterialApp(
          home: StoresScreen(
            storeViewModel: storeViewModel,
            mcpViewModel: mcpViewModel,
            cartViewModel: cartViewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Львів' chip
      await tester.tap(find.text('Львів'));
      await tester.pumpAndSettle();

      // Verify that all visible stores belong to Lviv
      expect(storeViewModel.selectedCity, 'Львів');
      for (final store in storeViewModel.stores) {
        expect(store.city, 'Львів');
      }
    });

    testWidgets('Search query filters stores and clear button resets', (tester) async {
      await storeViewModel.loadStores();

      await tester.pumpWidget(
        MaterialApp(
          home: StoresScreen(
            storeViewModel: storeViewModel,
            mcpViewModel: mcpViewModel,
            cartViewModel: cartViewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Мавка');
      await tester.pumpAndSettle();

      expect(storeViewModel.stores.every((s) =>
        s.name.contains('Мавка') ||
        (s.conceptTheme != null && s.conceptTheme!.contains('Мавка'))), isTrue);

      // Tap clear icon button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(storeViewModel.stores.length, greaterThan(1));
    });

    testWidgets('Tapping store opens details bottom sheet with phone and working hours', (tester) async {
      await storeViewModel.loadStores();

      await tester.pumpWidget(
        MaterialApp(
          home: StoresScreen(
            storeViewModel: storeViewModel,
            mcpViewModel: mcpViewModel,
            cartViewModel: cartViewModel,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first store card
      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verify details bottom sheet contents
      expect(find.textContaining('Послуги та сервіси супермаркету'), findsNothing);
      expect(find.textContaining('0 800 301 707'), findsOneWidget);
      expect(find.textContaining('Графік роботи:'), findsOneWidget);
    });
  });
}

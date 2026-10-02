import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'data/repositories/silpo_repository.dart';
import 'presentation/viewmodels/chat_viewmodel.dart';
import 'presentation/viewmodels/promo_viewmodel.dart';
import 'presentation/viewmodels/cart_viewmodel.dart';
import 'presentation/viewmodels/store_viewmodel.dart';
import 'presentation/viewmodels/mcp_viewmodel.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Root repository instance with Silpo data & search services
  final repository = SilpoRepository();

  // ViewModels
  final chatViewModel = ChatViewModel(repository: repository);
  final promoViewModel = PromoViewModel(repository: repository);
  final cartViewModel = CartViewModel(repository: repository);
  final storeViewModel = StoreViewModel(repository: repository);
  final mcpViewModel = McpViewModel(repository: repository);

  runApp(
    SilpoAssistantApp(
      chatViewModel: chatViewModel,
      promoViewModel: promoViewModel,
      cartViewModel: cartViewModel,
      storeViewModel: storeViewModel,
      mcpViewModel: mcpViewModel,
    ),
  );
}

class SilpoAssistantApp extends StatelessWidget {
  final ChatViewModel chatViewModel;
  final PromoViewModel promoViewModel;
  final CartViewModel cartViewModel;
  final StoreViewModel storeViewModel;
  final McpViewModel mcpViewModel;

  const SilpoAssistantApp({
    super.key,
    required this.chatViewModel,
    required this.promoViewModel,
    required this.cartViewModel,
    required this.storeViewModel,
    required this.mcpViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: MainNavigationScreen(
        chatViewModel: chatViewModel,
        promoViewModel: promoViewModel,
        cartViewModel: cartViewModel,
        storeViewModel: storeViewModel,
        mcpViewModel: mcpViewModel,
      ),
    );
  }
}

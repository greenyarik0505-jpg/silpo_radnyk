import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/promo_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/store_viewmodel.dart';
import '../viewmodels/mcp_viewmodel.dart';
import 'chat_screen.dart';
import 'promo_screen.dart';
import 'cart_screen.dart';
import 'stores_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ChatViewModel chatViewModel;
  final PromoViewModel promoViewModel;
  final CartViewModel cartViewModel;
  final StoreViewModel storeViewModel;
  final McpViewModel mcpViewModel;

  const MainNavigationScreen({
    super.key,
    required this.chatViewModel,
    required this.promoViewModel,
    required this.cartViewModel,
    required this.storeViewModel,
    required this.mcpViewModel,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cartViewModel,
      builder: (context, _) {
        final screens = [
          ChatScreen(
            chatViewModel: widget.chatViewModel,
            cartViewModel: widget.cartViewModel,
          ),
          PromoScreen(
            promoViewModel: widget.promoViewModel,
            cartViewModel: widget.cartViewModel,
          ),
          CartScreen(
            cartViewModel: widget.cartViewModel,
            onNavigateToAi: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          StoresScreen(
            storeViewModel: widget.storeViewModel,
            mcpViewModel: widget.mcpViewModel,
            cartViewModel: widget.cartViewModel,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome, color: AppColors.silpoOrange),
                label: AppStrings.tabAiChat,
              ),
              const NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon: Icon(Icons.local_offer, color: AppColors.silpoOrange),
                label: AppStrings.tabPromos,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: widget.cartViewModel.itemCount > 0,
                  label: Text('${widget.cartViewModel.itemCount}'),
                  backgroundColor: AppColors.silpoOrange,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: widget.cartViewModel.itemCount > 0,
                  label: Text('${widget.cartViewModel.itemCount}'),
                  backgroundColor: AppColors.silpoOrange,
                  child: const Icon(Icons.shopping_bag, color: AppColors.silpoOrange),
                ),
                label: AppStrings.tabCart,
              ),
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront, color: AppColors.silpoOrange),
                label: AppStrings.tabStores,
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/recipe.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/store_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/product_details_sheet.dart';

class ChatScreen extends StatefulWidget {
  final ChatViewModel chatViewModel;
  final CartViewModel cartViewModel;
  final StoreViewModel? storeViewModel;
  final VoidCallback? onSelectStore;

  const ChatScreen({
    super.key,
    required this.chatViewModel,
    required this.cartViewModel,
    this.storeViewModel,
    this.onSelectStore,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _lastMessageCount = widget.chatViewModel.messages.length;
    widget.chatViewModel.addListener(_onChatUpdated);
  }

  @override
  void dispose() {
    widget.chatViewModel.removeListener(_onChatUpdated);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChatUpdated() {
    if (widget.chatViewModel.messages.length != _lastMessageCount || widget.chatViewModel.isTyping) {
      _lastMessageCount = widget.chatViewModel.messages.length;
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.chatViewModel,
      builder: (context, _) {
        final activeStore = widget.storeViewModel?.selectedStore;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.silpoOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.silpoOrange, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: widget.onSelectStore,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.tabAiChat,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          activeStore != null
                              ? '📍 ${activeStore.name} • AI-Шеф'
                              : 'AI-Шеф & Рецепти в кошик • Gemini 3.1',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.silpoOrange, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              ListenableBuilder(
                listenable: widget.cartViewModel,
                builder: (context, _) {
                  final count = widget.cartViewModel.itemCount;
                  final total = widget.cartViewModel.totalPrice;
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.silpoOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_cart_outlined, size: 16, color: AppColors.silpoOrange),
                        const SizedBox(width: 4),
                        Text(
                          '$count шт • ${total.toStringAsFixed(0)} ₴',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.silpoOrange,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                tooltip: 'Очистити діалог',
                onPressed: widget.chatViewModel.clearHistory,
              ),
            ],
          ),
          body: Column(
            children: [
              // Message list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: widget.chatViewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.chatViewModel.messages[index];
                    return _buildMessageItem(message, isDark);
                  },
                ),
              ),

              if (widget.chatViewModel.isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.silpoOrange),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'AI Шеф аналізує каталог Сільпо...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // Bottom input area
              _buildInputArea(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isDark) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.silpoOrange, AppColors.silpoOrangeDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.silpoOrange.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MCP Tool Badge
            if (message.mcpToolExecuted != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: AppColors.silpoYellow),
                    const SizedBox(width: 4),
                    Text(
                      'MCP: ${message.mcpToolExecuted}',
                      style: const TextStyle(fontSize: 11, color: AppColors.silpoYellow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // Message Bubble
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.silpoNavy.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),

            // Recipe Card if included
            if (message.recipe != null) ...[
              const SizedBox(height: 10),
              _buildRecipeCard(message.id, message.recipe!, isDark),
            ],

            // Recommended Products carousel if included
            if (message.recommendedProducts != null && message.recommendedProducts!.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 285,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.recommendedProducts!.length,
                  itemBuilder: (context, pIndex) {
                    final product = message.recommendedProducts![pIndex];
                    return SizedBox(
                      width: 185,
                      child: ProductCard(
                        product: product,
                        onTap: () => ProductDetailsSheet.show(context, product, widget.cartViewModel),
                        onAddToCart: () {
                          widget.cartViewModel.addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Додано: ${product.title} • ${product.currentPrice.toStringAsFixed(2)} ₴'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],

            // Suggested Action Chips
            if (message.suggestedActions != null && message.suggestedActions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.suggestedActions!.map((action) {
                  return ActionChip(
                    label: Text(action, style: const TextStyle(fontSize: 12)),
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.silpoOrangeLight,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      widget.chatViewModel.sendMessage(action);
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(String messageId, Recipe recipe, bool isDark) {
    return Card(
      color: isDark ? AppColors.darkSurface : const Color(0xFFFFF9F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.silpoOrange, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppColors.silpoOrange, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoBadge(Icons.timer_outlined, '${recipe.cookTimeMinutes} хв'),
                const SizedBox(width: 8),
                _buildInfoBadge(Icons.speed, recipe.difficulty),
                const Spacer(),
                // Portion Stepper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.silpoOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: recipe.servings > 1
                            ? () => widget.chatViewModel.updateRecipeServings(messageId, recipe.servings - 1)
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.remove, size: 16, color: AppColors.silpoOrange),
                        ),
                      ),
                      Text(
                        '${recipe.servings} порції',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.silpoOrange),
                      ),
                      InkWell(
                        onTap: recipe.servings < 12
                            ? () => widget.chatViewModel.updateRecipeServings(messageId, recipe.servings + 1)
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Icon(Icons.add, size: 16, color: AppColors.silpoOrange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Інгредієнти та товари Сільпо:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.asMap().entries.map((entry) {
              final idx = entry.key;
              final ing = entry.value;
              final prod = ing.substituteProduct ?? ing.matchedProduct;
              final sub = ing.substituteProduct;
              final displayPrice = ing.cost > 0 ? ing.cost : (prod?.currentPrice ?? 35.0);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: prod != null
                                ? () => ProductDetailsSheet.show(context, prod, widget.cartViewModel)
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${ing.name} (${ing.amount} ${ing.unit})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    decoration: prod != null ? TextDecoration.underline : null,
                                    decorationColor: AppColors.silpoOrange,
                                  ),
                                ),
                                if (prod != null)
                                  Text(
                                    '${prod.title} • ${displayPrice.toStringAsFixed(2)} ₴',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.silpoOrange.withValues(alpha: 0.15),
                            foregroundColor: AppColors.silpoOrange,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                          label: Text(
                            '+ ${displayPrice.toStringAsFixed(0)} ₴',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (prod != null) {
                              widget.cartViewModel.addProduct(prod);
                            } else {
                              widget.cartViewModel.addProduct(
                                Product(
                                  id: 'ing_${recipe.id}_$idx',
                                  title: ing.name,
                                  category: 'Інгредієнти',
                                  regularPrice: displayPrice,
                                  unit: ing.unit,
                                  weightGrams: ing.amount,
                                ),
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Додано до кошика: ${ing.name} • ${displayPrice.toStringAsFixed(2)} ₴'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (sub != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 4),
                        child: InkWell(
                          onTap: () => widget.chatViewModel.toggleSubstitute(messageId, idx),
                          child: Text(
                            '🔄 Замінити на ${sub.title} (${sub.currentPrice.toStringAsFixed(2)} ₴)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.silpoOrange,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Орієнтовно:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      '${recipe.totalEstimatedCost.toStringAsFixed(2)} ₴',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.silpoOrange),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text('Додати все • ${recipe.totalEstimatedCost.toStringAsFixed(0)} ₴'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.silpoOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    widget.cartViewModel.addRecipeIngredients(recipe);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Всі інгредієнти для "${recipe.title}" додано в кошик! (${recipe.totalEstimatedCost.toStringAsFixed(2)} ₴)'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.silpoOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.silpoOrange),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.silpoOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: AppStrings.aiInputPlaceholder,
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.silpoOrange, width: 2),
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    widget.chatViewModel.sendMessage(val);
                    _textController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.silpoOrange, AppColors.silpoOrangeDark],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.send_rounded),
                onPressed: () {
                  final text = _textController.text;
                  if (text.trim().isNotEmpty) {
                    widget.chatViewModel.sendMessage(text);
                    _textController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/recipe.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/product_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatViewModel chatViewModel;
  final CartViewModel cartViewModel;

  const ChatScreen({
    super.key,
    required this.chatViewModel,
    required this.cartViewModel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        _scrollToBottom();
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tabAiChat,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'AI Recipe & Cart Engine • Silpo MCP',
                      style: TextStyle(fontSize: 11, color: AppColors.silpoOrange, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
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
          decoration: const BoxDecoration(
            color: AppColors.silpoOrange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
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
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),

            // Recipe Card if included
            if (message.recipe != null) ...[
              const SizedBox(height: 10),
              _buildRecipeCard(message.recipe!, isDark),
            ],

            // Recommended Products carousel if included
            if (message.recommendedProducts != null && message.recommendedProducts!.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.recommendedProducts!.length,
                  itemBuilder: (context, pIndex) {
                    final product = message.recommendedProducts![pIndex];
                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        product: product,
                        onAddToCart: () {
                          widget.cartViewModel.addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Додано: ${product.title}'),
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

  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
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
                const SizedBox(width: 10),
                _buildInfoBadge(Icons.people_outline, '${recipe.servings} порції'),
                const SizedBox(width: 10),
                _buildInfoBadge(Icons.speed, recipe.difficulty),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Інгредієнти та товари Сільпо:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ing) {
              final prod = ing.substituteProduct ?? ing.matchedProduct;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${ing.name} (${ing.amount} ${ing.unit})',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (prod != null)
                      Text(
                        '${prod.currentPrice.toStringAsFixed(2)} ₴',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.silpoOrange),
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
                  label: const Text('Додати все до кошика'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.silpoOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    widget.cartViewModel.addRecipeIngredients(recipe);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Всі інгредієнти для "${recipe.title}" додано в кошик!'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: AppStrings.aiInputPlaceholder,
                  isDense: true,
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
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: AppColors.silpoOrange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.send_rounded),
              onPressed: () {
                final text = _textController.text;
                if (text.trim().isNotEmpty) {
                  widget.chatViewModel.sendMessage(text);
                  _textController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

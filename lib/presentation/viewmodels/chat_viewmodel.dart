import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/repositories/silpo_repository.dart';
import '../../core/constants/app_strings.dart';
import '../../core/mcp/silpo_mcp_tools.dart';

/// ViewModel orchestrating AI culinary conversations, recipe parsing and smart substitutions.
class ChatViewModel extends ChangeNotifier {
  final SilpoRepository _repository;
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  ChatViewModel({SilpoRepository? repository})
      : _repository = repository ?? SilpoRepository() {
    _initGreeting();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void _initGreeting() {
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: AppStrings.aiGreeting,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: const [
          AppStrings.quickPromptBorsch,
          AppStrings.quickPromptTiramisu,
          AppStrings.quickPromptKeto,
          AppStrings.quickPromptPriceDrop,
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      ChatMessage aiMsg;
      try {
        // 1. Primary engine: Google AI Studio Gemini 3.1 Flash Lite with Silpo catalogue grounding
        aiMsg = await _repository.askGemini(
          prompt: trimmed,
          conversationHistory: _messages.where((m) => m != userMsg).toList(),
        );
      } catch (e) {
        // 2. Resilient fallback: Local Silpo repository engine (in case of offline/network errors)
        aiMsg = await _fallbackLocalResponse(trimmed);
      }
      _messages.add(aiMsg);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<ChatMessage> _fallbackLocalResponse(String trimmed) async {
    final lower = trimmed.toLowerCase();

    if (lower.contains('борщ') ||
        lower.contains('тірамісу') ||
        lower.contains('десерт') ||
        lower.contains('кето') ||
        lower.contains('вечер') ||
        lower.contains('рецепт') ||
        lower.contains('сирник') ||
        lower.contains('паст')) {
      // Recipe understanding flow
      final parsedRecipe = await _repository.parseRecipe(trimmed);
      return ChatMessage(
        id: _uuid.v4(),
        text: 'Ось підібраний рецепт "${parsedRecipe.title}" з точним списком необхідних товарів у Сільпо!',
        isUser: false,
        timestamp: DateTime.now(),
        recipe: parsedRecipe,
        mcpToolExecuted: SilpoMcpTools.parseRecipe,
        suggestedActions: [
          'Показати акційні аналоги',
          'Скільки калорій у порції?',
          'Додати до списку покупок',
        ],
      );
    } else if (lower.contains('подешевшало') ||
        lower.contains('знижк') ||
        lower.contains('акці') ||
        lower.contains('цінотижик')) {
      // Promos flow
      final cinotyzhiki = await _repository.getCinotyzhiki();
      final products = await _repository.searchProducts('');
      final discounted = products.where((p) => p.hasDiscount).take(3).toList();

      final summary = cinotyzhiki.map((p) => '• ${p.title}').join('\n');
      return ChatMessage(
        id: _uuid.v4(),
        text: 'Цього тижня у «Цінотижиках» Сільпо діють суперціни:\n\n$summary\n\nЯ знайшов найвигідніші пропозиції для вас:',
        isUser: false,
        timestamp: DateTime.now(),
        recommendedProducts: discounted,
        mcpToolExecuted: SilpoMcpTools.getCinotyzhiki,
        suggestedActions: [
          'Додати сир до кошика',
          'Які акції на вино?',
          'Показати всі «Цінотижики»',
        ],
      );
    } else {
      // General catalog search flow
      final searchResults = await _repository.searchProducts(trimmed);
      if (searchResults.isNotEmpty) {
        return ChatMessage(
          id: _uuid.v4(),
          text: 'Знайшов у каталозі Сільпо такі товари за запитом "$trimmed":',
          isUser: false,
          timestamp: DateTime.now(),
          recommendedProducts: searchResults.take(4).toList(),
          mcpToolExecuted: SilpoMcpTools.searchCatalog,
        );
      } else {
        return ChatMessage(
          id: _uuid.v4(),
          text: 'Я можу допомогти скласти меню на будь-який день, розібрати рецепт на інгредієнти або підібрати найсмачніші акційні товари Сільпо. Спробуйте запитати, наприклад:\n• "Що приготувати на вечерю до 250 грн?"\n• "Які акції на лосось та авокадо?"',
          isUser: false,
          timestamp: DateTime.now(),
          suggestedActions: const [
            AppStrings.quickPromptBorsch,
            AppStrings.quickPromptTiramisu,
          ],
        );
      }
    }
  }

  /// Dynamically updates the servings for a recipe attached to a chat message.
  void updateRecipeServings(String messageId, int newServings) {
    if (newServings < 1 || newServings > 12) return;
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = _messages[index];
      if (msg.recipe != null) {
        final scaled = msg.recipe!.scaleServings(newServings);
        _messages[index] = msg.copyWith(recipe: scaled);
        notifyListeners();
      }
    }
  }

  /// Toggles an ingredient substitute in a recipe message between standard and private label.
  void toggleSubstitute(String messageId, int ingredientIndex) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = _messages[index];
      if (msg.recipe != null) {
        final updatedRecipe = msg.recipe!.withToggledSubstitute(ingredientIndex);
        _messages[index] = msg.copyWith(recipe: updatedRecipe);
        notifyListeners();
      }
    }
  }

  void clearHistory() {
    _messages.clear();
    _initGreeting();
    notifyListeners();
  }
}

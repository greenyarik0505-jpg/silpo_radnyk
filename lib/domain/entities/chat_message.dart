import 'product.dart';
import 'recipe.dart';

/// Message model for conversational AI Chef and Silpo MCP Assistant.
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Recipe? recipe;
  final List<Product>? recommendedProducts;
  final String? mcpToolExecuted;
  final List<String>? suggestedActions;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recipe,
    this.recommendedProducts,
    this.mcpToolExecuted,
    this.suggestedActions,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    Recipe? recipe,
    List<Product>? recommendedProducts,
    String? mcpToolExecuted,
    List<String>? suggestedActions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      recipe: recipe ?? this.recipe,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      mcpToolExecuted: mcpToolExecuted ?? this.mcpToolExecuted,
      suggestedActions: suggestedActions ?? this.suggestedActions,
    );
  }
}

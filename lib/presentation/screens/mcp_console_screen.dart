import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/mcp/mcp_protocol.dart';
import '../viewmodels/mcp_viewmodel.dart';

class McpConsoleScreen extends StatefulWidget {
  final McpViewModel mcpViewModel;

  const McpConsoleScreen({
    super.key,
    required this.mcpViewModel,
  });

  @override
  State<McpConsoleScreen> createState() => _McpConsoleScreenState();
}

class _McpConsoleScreenState extends State<McpConsoleScreen> {
  McpTool? _selectedTool;
  final TextEditingController _argsController = TextEditingController(text: '{"query": "сир"}');

  @override
  void initState() {
    super.initState();
    if (widget.mcpViewModel.tools.isNotEmpty) {
      _selectedTool = widget.mcpViewModel.tools.first;
    }
  }

  @override
  void dispose() {
    _argsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.mcpViewModel,
      builder: (context, _) {
        if (_selectedTool == null && widget.mcpViewModel.tools.isNotEmpty) {
          _selectedTool = widget.mcpViewModel.tools.first;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.mcpConsoleTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Оновити інструменти',
                onPressed: widget.mcpViewModel.refreshTools,
              ),
              IconButton(
                icon: const Icon(Icons.cleaning_services_outlined),
                tooltip: 'Очистити логи',
                onPressed: widget.mcpViewModel.clearLogs,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Server status card
              Card(
                color: isDark ? AppColors.darkCard : const Color(0xFF1E293B),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Silpo MCP Endpoint (Active)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.silpoOrange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'JSON-RPC 2.0',
                              style: TextStyle(color: AppColors.silpoOrange, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mcpViewModel.endpoint,
                        style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Доступно інструментів MCP: ${widget.mcpViewModel.tools.length} | Аутентифікація: OAuth 2.1 PKCE / Streamable HTTP',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tool Selector & Execution Panel
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Тестування виклику інструменту (tools/call):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),

                      // Dropdown
                      DropdownButtonFormField<McpTool>(
                        initialValue: _selectedTool,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Оберіть MCP Tool',
                          isDense: true,
                        ),
                        items: widget.mcpViewModel.tools.map((t) {
                          return DropdownMenuItem<McpTool>(
                            value: t,
                            child: Text(t.name, style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
                          );
                        }).toList(),
                        onChanged: (tool) {
                          setState(() {
                            _selectedTool = tool;
                            if (tool != null) {
                              _updateDefaultArgs(tool.name);
                            }
                          });
                        },
                      ),

                      if (_selectedTool != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _selectedTool!.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _argsController,
                          maxLines: 3,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                          decoration: const InputDecoration(
                            labelText: 'Аргументи виклику (JSON)',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: widget.mcpViewModel.isExecutingTool
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.play_arrow, size: 18),
                            label: const Text('Виконати виклик інструменту'),
                            onPressed: widget.mcpViewModel.isExecutingTool
                                ? null
                                : () {
                                    Map<String, dynamic> parsedArgs = {};
                                    final raw = _argsController.text.trim();
                                    if (raw.isNotEmpty && raw != '{}') {
                                      try {
                                        final decoded = jsonDecode(raw);
                                        if (decoded is! Map<String, dynamic>) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Помилка: Аргументи повинні бути коректним JSON-об’єктом { ... }'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        parsedArgs = decoded;
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Помилка синтаксису JSON: перевірте валідність лапок та дужок ($e)'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                    }
                                    widget.mcpViewModel.executeTool(_selectedTool!.name, parsedArgs);
                                  },
                          ),
                        ),
                      ],

                      if (widget.mcpViewModel.lastResult != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Результат (MCP Content):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.copy, size: 14),
                              label: const Text('Копіювати', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Результат MCP скопійовано!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.silpoOrange.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            widget.mcpViewModel.lastResult!,
                            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Live Logs Console
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Журнал обміну повідомленнями (JSON-RPC Log):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '${widget.mcpViewModel.logs.length} подій',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.mcpViewModel.logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Поки немає зареєстрованих запитів MCP',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              )
                            : ListView.builder(
                                itemCount: widget.mcpViewModel.logs.length,
                                itemBuilder: (context, idx) {
                                  final entry = widget.mcpViewModel.logs[idx];
                                  final isReq = entry.contains('->');
                                  final isErr = entry.contains('<!');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      entry,
                                      style: TextStyle(
                                        color: isErr
                                            ? const Color(0xFFF87171)
                                            : (isReq ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80)),
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _updateDefaultArgs(String toolName) {
    if (toolName.contains('search')) {
      _argsController.text = '{"query": "сир Гауда", "limit": 10}';
    } else if (toolName.contains('recipe')) {
      _argsController.text = '{"recipeText": "Український борщ", "servings": 4}';
    } else if (toolName.contains('cart')) {
      _argsController.text = '{"productId": "p_borsch_beef", "quantity": 1}';
    } else if (toolName.contains('delivery')) {
      _argsController.text = '{"filialId": "silpo_kyiv_gulliver"}';
    } else if (toolName.contains('store')) {
      _argsController.text = '{"city": "Київ"}';
    } else if (toolName.contains('receipt') || toolName.contains('fiscal')) {
      _argsController.text = '{"limit": 5}';
    } else if (toolName.contains('inflation')) {
      _argsController.text = '{"periodMonths": 6}';
    } else if (toolName.contains('boost')) {
      _argsController.text = '{"couponId": "boost_coffee_x3"}';
    } else {
      _argsController.text = '{}';
    }
  }
}

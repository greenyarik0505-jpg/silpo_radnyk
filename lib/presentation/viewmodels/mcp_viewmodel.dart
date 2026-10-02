import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/mcp/mcp_client.dart';
import '../../core/mcp/mcp_protocol.dart';
import '../../data/repositories/silpo_repository.dart';

/// ViewModel managing the Model Context Protocol (MCP) diagnostics and tool execution engine.
class McpViewModel extends ChangeNotifier {
  final McpClient _mcpClient;
  StreamSubscription<String>? _logSubscription;

  List<McpTool> _tools = [];
  final List<String> _logs = [];
  bool _isLoading = false;
  String? _lastResult;
  bool _isExecutingTool = false;

  McpViewModel({SilpoRepository? repository, McpClient? mcpClient})
      : _mcpClient = mcpClient ?? repository?.mcpClient ?? McpClient() {
    _initLogs();
    refreshTools();
  }

  List<McpTool> get tools => _tools;
  List<String> get logs => List.unmodifiable(_logs);
  bool get isLoading => _isLoading;
  bool get isExecutingTool => _isExecutingTool;
  String? get lastResult => _lastResult;
  String get endpoint => _mcpClient.endpoint;

  void _initLogs() {
    _logs.addAll(_mcpClient.logHistory);
    _logSubscription = _mcpClient.logStream.listen((logEntry) {
      _logs.add(logEntry);
      notifyListeners();
    });
  }

  Future<void> refreshTools() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tools = await _mcpClient.listTools();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> executeTool(String toolName, Map<String, dynamic> args) async {
    _isExecutingTool = true;
    _lastResult = null;
    notifyListeners();

    try {
      final res = await _mcpClient.callTool(toolName, args);
      _lastResult = res.content.map((c) => c.text).join('\n');
    } catch (e) {
      _lastResult = 'Помилка виклику інструменту: $e';
    } finally {
      _isExecutingTool = false;
      notifyListeners();
    }
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }
}

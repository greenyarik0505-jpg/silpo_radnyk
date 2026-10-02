/// Standard Model Context Protocol (MCP) JSON-RPC 2.0 message structures.
class McpRequest {
  final String jsonrpc;
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  const McpRequest({
    this.jsonrpc = '2.0',
    required this.id,
    required this.method,
    this.params,
  });

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    'method': method,
    if (params != null) 'params': params,
  };

  factory McpRequest.fromJson(Map<String, dynamic> json) => McpRequest(
    jsonrpc: json['jsonrpc'] as String? ?? '2.0',
    id: json['id'],
    method: json['method'] as String,
    params: json['params'] != null ? Map<String, dynamic>.from(json['params'] as Map) : null,
  );
}

class McpResponse {
  final String jsonrpc;
  final dynamic id;
  final dynamic result;
  final McpError? error;

  const McpResponse({
    this.jsonrpc = '2.0',
    required this.id,
    this.result,
    this.error,
  });

  bool get isSuccess => error == null;

  Map<String, dynamic> toJson() => {
    'jsonrpc': jsonrpc,
    'id': id,
    if (result != null) 'result': result,
    if (error != null) 'error': error!.toJson(),
  };

  factory McpResponse.fromJson(Map<String, dynamic> json) => McpResponse(
    jsonrpc: json['jsonrpc'] as String? ?? '2.0',
    id: json['id'],
    result: json['result'],
    error: json['error'] != null ? McpError.fromJson(Map<String, dynamic>.from(json['error'] as Map)) : null,
  );
}

class McpError {
  final int code;
  final String message;
  final dynamic data;

  const McpError({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    if (data != null) 'data': data,
  };

  factory McpError.fromJson(Map<String, dynamic> json) => McpError(
    code: json['code'] as int,
    message: json['message'] as String,
    data: json['data'],
  );
}

class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  const McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'inputSchema': inputSchema,
  };

  factory McpTool.fromJson(Map<String, dynamic> json) => McpTool(
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    inputSchema: json['inputSchema'] != null ? Map<String, dynamic>.from(json['inputSchema'] as Map) : {},
  );
}

class McpToolCall {
  final String name;
  final Map<String, dynamic> arguments;

  const McpToolCall({
    required this.name,
    required this.arguments,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'arguments': arguments,
  };

  factory McpToolCall.fromJson(Map<String, dynamic> json) => McpToolCall(
    name: json['name'] as String,
    arguments: json['arguments'] != null ? Map<String, dynamic>.from(json['arguments'] as Map) : {},
  );
}

class McpToolResult {
  final List<McpContent> content;
  final bool isError;

  const McpToolResult({
    required this.content,
    this.isError = false,
  });

  Map<String, dynamic> toJson() => {
    'content': content.map((c) => c.toJson()).toList(),
    'isError': isError,
  };

  factory McpToolResult.fromJson(Map<String, dynamic> json) => McpToolResult(
    content: (json['content'] as List<dynamic>?)
            ?.map((e) => McpContent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [],
    isError: json['isError'] as bool? ?? false,
  );
}

class McpContent {
  final String type;
  final String text;

  const McpContent({
    this.type = 'text',
    required this.text,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
  };

  factory McpContent.fromJson(Map<String, dynamic> json) => McpContent(
    type: json['type'] as String? ?? 'text',
    text: json['text'] as String? ?? '',
  );
}

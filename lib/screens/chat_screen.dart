// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт для работы с системными сервисами (буфер обмена)
import 'package:flutter/services.dart';
// Импорт для работы с провайдерами состояния
import 'package:provider/provider.dart';
// Импорт для работы со шрифтами Google
import 'package:google_fonts/google_fonts.dart';
// Импорт провайдера чата
import '../providers/chat_provider.dart';
// Импорт модели сообщения
import '../models/message.dart';
// Импорт для генерации пароля
import 'dart:math';

// Виджет для обработки ошибок в UI
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          debugPrint('Error in ErrorBoundary: $error');
          debugPrint('Stack trace: $stackTrace');
          return Container(
            padding: const EdgeInsets.all(12),
            color: Colors.red,
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        }
      },
    );
  }
}

// Виджет для отображения отдельного сообщения в чате
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final List<ChatMessage> messages;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.messages,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xFF1A73E8)
                  : const Color(0xFF424242),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              message.cleanContent,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 13,
                locale: const Locale('ru', 'RU'),
              ),
            ),
          ),
          if (message.tokens != null || message.cost != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.tokens != null)
                    Text(
                      'Токенов: ${message.tokens}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  if (message.tokens != null && message.cost != null)
                    const SizedBox(width: 8),
                  if (message.cost != null)
                    Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        final isVsetgpt =
                            chatProvider.baseUrl?.contains('vsetgpt.ru') ==
                                true;
                        return Text(
                          message.cost! < 0.001
                              ? isVsetgpt
                                  ? 'Стоимость: <0.001₽'
                                  : 'Стоимость: <\$0.001'
                              : isVsetgpt
                                  ? 'Стоимость: ${message.cost!.toStringAsFixed(3)}₽'
                                  : 'Стоимость: \$${message.cost!.toStringAsFixed(3)}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    color: Colors.white54,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    onPressed: () {
                      final textToCopy = message.isUser
                          ? message.cleanContent
                          : '${messages[index - 1].cleanContent}\n\n${message.cleanContent}';
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Текст скопирован',
                              style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'Копировать текст',
                  ),
                  const Spacer()
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// виджет для ввода пароля
class _PasswordInput extends StatefulWidget {
  final Function(String) onSubmitted;
  final void Function() onClearKey;

  const _PasswordInput({required this.onSubmitted, required this.onClearKey});

  @override
  __PasswordInputState createState() => __PasswordInputState();
}

// состояние виджета для ввода пароля
class __PasswordInputState extends State<_PasswordInput> {
  // контролер текстового поля
  final _controller = TextEditingController();
  // флаг, указывающий заполнено ли текстовое поле
  bool _isComposing = false;
  // текст ошибки
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // метод отправки пароля
  void _handleSubmitted(String password) async {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });

    try {
      await widget.onSubmitted(password);
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    }
  }

  // метод удаление существующего ключа
  void _handleClearKey() {
    widget.onClearKey();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextField(
              controller: _controller,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'Введите пароль...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                errorText: _errorText,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Row(
            spacing: 16,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 106, 181, 216)),
                onPressed: _isComposing
                    ? () => _handleSubmitted(_controller.text)
                    : null,
                child: const Text('Submit'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 106, 216, 115)),
                onPressed: _handleClearKey,
                child: const Text('New key'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// виджет для ввода ключа api
class _AuthInput extends StatefulWidget {
  final Function(String, String) onSubmitted;
  final Function(String) onValidation;

  const _AuthInput({required this.onSubmitted, required this.onValidation});

  @override
  _AuthInputState createState() => _AuthInputState();
}

// состояние виджета для ввода ключа api
class _AuthInputState extends State<_AuthInput> {
  // Контроллер для управления текстовым полем
  final _controller = TextEditingController();
  // Флаг, указывающий, вводится ли сейчас сообщение
  bool _isComposing = false;
  // сгенерированный пароль
  String _password = '';
  // текст ошибки
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // сохранения ключа с паролем в базу данных
  void _handleSubmitted(String key, String password) async {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    try {
      await widget.onSubmitted(key, password);
      setState(() {
        _errorText = '';
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    }
  }

  // генерация пароля
  void _handleCreatePassword(String key) async {
    try {
      await widget.onValidation(key);

      var rng = Random();
      String password = '';

      for (var i = 0; i < 4; i++) {
        password = '$password${rng.nextInt(10)}';
      }

      setState(() {
        _password = password;
      });
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      // поле для ввода ключа
      if (_password.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 5),
                child: TextField(
                  controller: _controller,
                  onChanged: (String text) {
                    // валидация ключа
                    if (text.length > 9) {
                      if (text.startsWith('sk-or-v1') |
                          text.startsWith('sk-or-vv')) {
                        setState(() {
                          _isComposing = text.trim().isNotEmpty;
                          _errorText = null;
                        });
                      } else {
                        setState(() {
                          _errorText = 'Неверный ключ';
                        });
                      }
                    } else {
                      setState(() {
                        _isComposing = false;
                        _errorText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Введите API-KEY...',
                    hintStyle:
                        const TextStyle(color: Colors.white54, fontSize: 13),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    errorText: _errorText,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 106, 181, 216)),
                    onPressed: _isComposing
                        ? () => _handleCreatePassword(_controller.text)
                        : null,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        );
        // показываем пользователю сгенерированный пароль
      } else {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            children: [
              Text('Ваш пароль: $_password'),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 106, 181, 216)),
                    onPressed: () =>
                        _handleSubmitted(_controller.text, _password),
                    child: const Text('Ok'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    });
  }
}

// Виджет для ввода сообщений
class _MessageInput extends StatefulWidget {
  final void Function(String) onSubmitted;

  const _MessageInput({required this.onSubmitted});

  @override
  _MessageInputState createState() => _MessageInputState();
}

// Состояние виджета ввода сообщений
class _MessageInputState extends State<_MessageInput> {
  // Контроллер для управления текстовым полем
  final _controller = TextEditingController();
  // Флаг, указывающий, вводится ли сейчас сообщение
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    widget.onSubmitted(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: const InputDecoration(
                hintText: 'Введите сообщение...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, size: 20),
            color: _isComposing ? Colors.blue : Colors.grey,
            onPressed:
                _isComposing ? () => _handleSubmitted(_controller.text) : null,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

// Основной экран чата
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatprovider, child) {
      if (chatprovider.api == null) {
        return ErrorBoundary(
          child: Scaffold(
            backgroundColor: const Color(0xFF1E1E1E),
            body: SafeArea(
              child: Expanded(
                child: _buildInputAuth(context),
              ),
            ),
          ),
        );
      } else {
        return ErrorBoundary(
          child: Scaffold(
            backgroundColor: const Color(0xFF1E1E1E),
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  _buildInputArea(context),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  // Построение верхней панели приложения
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF262626),
      toolbarHeight: 48,
      title: Row(
        children: [
          _buildModelSelector(context),
          const Spacer(),
          _buildBalanceDisplay(context),
          _buildMenuButton(context),
        ],
      ),
    );
  }

  // Построение выпадающего списка для выбора модели
  Widget _buildModelSelector(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: DropdownButton<String>(
            value: chatProvider.currentModel,
            hint: const Text(
              'Выберите модель',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            dropdownColor: const Color(0xFF333333),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            isExpanded: true,
            underline: Container(
              height: 1,
              color: Colors.blue,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                chatProvider.setCurrentModel(newValue);
              }
            },
            items: chatProvider.availableModels
                .map<DropdownMenuItem<String>>((Map<String, dynamic> model) {
              return DropdownMenuItem<String>(
                value: model['id'],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model['name'] ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Tooltip(
                          message: 'Входные токены',
                          child: const Icon(Icons.arrow_upward, size: 12),
                        ),
                        Text(
                          chatProvider.formatPricing(
                              double.tryParse(model['pricing']?['prompt']) ??
                                  0.0),
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Генерация',
                          child: const Icon(Icons.arrow_downward, size: 12),
                        ),
                        Text(
                          chatProvider.formatPricing(double.tryParse(
                                  model['pricing']?['completion']) ??
                              0.0),
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Контекст',
                          child: const Icon(Icons.memory, size: 12),
                        ),
                        Text(
                          ' ${model['context_length'] ?? '0'}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Отображение текущего баланса пользователя
  Widget _buildBalanceDisplay(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Row(
            children: [
              Icon(Icons.credit_card, size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                chatProvider.balance,
                style: const TextStyle(
                  color: Color(0xFF33CC33),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Построение кнопки меню с дополнительными опциями
  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 16),
      color: const Color(0xFF333333),
      onSelected: (String choice) async {
        final chatProvider = context.read<ChatProvider>();
        switch (choice) {
          case 'export':
            final path = await chatProvider.exportMessagesAsJson();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('История сохранена в: $path',
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green,
                ),
              );
            }
            break;
          case 'logs':
            final path = await chatProvider.exportLogs();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Логи сохранены в: $path',
                      style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green,
                ),
              );
            }
            break;
          case 'clear':
            _showClearHistoryDialog(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'export',
          height: 40,
          child: Text('Экспорт истории',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const PopupMenuItem<String>(
          value: 'logs',
          height: 40,
          child: Text('Скачать логи',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const PopupMenuItem<String>(
          value: 'clear',
          height: 40,
          child: Text('Очистить историю',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }

  // Построение списка сообщений чата
  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          reverse: false,
          itemCount: chatProvider.messages.length,
          itemBuilder: (context, index) {
            final message = chatProvider.messages[index];
            return _MessageBubble(
              message: message,
              messages: chatProvider.messages,
              index: index,
            );
          },
        );
      },
    );
  }

  // Построение области ввода сообщений
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      color: const Color(0xFF262626),
      child: Row(
        children: [
          Expanded(
            child: _MessageInput(
              onSubmitted: (String text) {
                if (text.trim().isNotEmpty) {
                  context.read<ChatProvider>().sendMessage(text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // виджет аутентификации (ввод ключа или ввод пароля)
  Widget _buildInputAuth(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        color: const Color(0xFF262626),
        width: 768,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            context.read<ChatProvider>().isApiKeyDB
                ? Text('Введите пароль')
                : Text('Введите api-key'),
            context.read<ChatProvider>().isApiKeyDB
                ? _PasswordInput(
                    onSubmitted: (String password) async {
                      await context.read<ChatProvider>().getApiKey(password);
                    },
                    onClearKey: () {
                      context.read<ChatProvider>().clearApikey();
                    },
                  )
                : _AuthInput(
                    onSubmitted: (String key, String password) async {
                      if (key.trim().isNotEmpty & password.trim().isNotEmpty) {
                        // await context.read<ChatProvider>().validationKey();
                        try {
                          await context
                              .read<ChatProvider>()
                              .saveApiKey(key, password);
                        } catch (e) {
                          rethrow;
                        }
                      }
                    },
                    onValidation: (String key) async {
                      await context.read<ChatProvider>().validationKey(key);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Построение панели с кнопками действий
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      color: const Color(0xFF262626),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.save,
            label: 'Сохранить',
            color: const Color(0xFF1A73E8),
            onPressed: () async {
              final path =
                  await context.read<ChatProvider>().exportMessagesAsJson();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('История сохранена в: $path',
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            context: context,
            icon: Icons.analytics,
            label: 'Аналитика',
            color: const Color(0xFF33CC33),
            onPressed: () => _showAnalyticsDialog(context),
          ),
          _buildActionButton(
            context: context,
            icon: Icons.delete,
            label: 'Очистить',
            color: const Color(0xFFCC3333),
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
    );
  }

  // Создание отдельной кнопки действия с заданными параметрами
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
        ),
      ),
    );
  }

  // Отображение диалога с аналитикой использования чата
  void _showAnalyticsDialog(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Статистика',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Всего сообщений: ${chatProvider.messages.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Баланс: ${chatProvider.balance}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Использование по моделям:',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...chatProvider.messages
                    .fold<Map<String, Map<String, dynamic>>>(
                      {},
                      (map, msg) {
                        if (msg.modelId != null) {
                          if (!map.containsKey(msg.modelId)) {
                            map[msg.modelId!] = {
                              'count': 0,
                              'tokens': 0,
                              'cost': 0.0,
                            };
                          }
                          map[msg.modelId]!['count'] =
                              map[msg.modelId]!['count']! + 1;
                          if (msg.tokens != null) {
                            map[msg.modelId]!['tokens'] =
                                map[msg.modelId]!['tokens']! + msg.tokens!;
                          }
                          if (msg.cost != null) {
                            map[msg.modelId]!['cost'] =
                                map[msg.modelId]!['cost']! + msg.cost!;
                          }
                        }
                        return map;
                      },
                    )
                    .entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Сообщений: ${entry.value['count']}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              if (entry.value['tokens'] > 0) ...[
                                Text(
                                  'Токенов: ${entry.value['tokens']}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                Consumer<ChatProvider>(
                                  builder: (context, chatProvider, child) {
                                    final isVsetgpt = chatProvider.baseUrl
                                            ?.contains('vsetgpt.ru') ==
                                        true;
                                    return Text(
                                      isVsetgpt
                                          ? 'Стоимость: ${entry.value['cost'] < 1e-8 ? '0.0' : entry.value['cost'].toStringAsFixed(8)}₽'
                                          : 'Стоимость: \$${entry.value['cost'] < 1e-8 ? '0.0' : entry.value['cost'].toStringAsFixed(8)}',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть', style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  // Отображение диалога подтверждения очистки истории
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF333333),
          title: const Text(
            'Очистить историю',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          content: const Text(
            'Вы уверены? Это действие нельзя отменить.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatProvider>().clearHistory();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Очистить',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rethink/screens/genai_screen.dart';
import 'package:rethink/services/chat_api.dart';
import 'package:rethink/services/chat_history_service.dart';
import 'package:rethink/models/history.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  final TextEditingController _searchController = TextEditingController();
  List<History> _filteredHistories = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredHistories = [];
      });
    } else {
      setState(() {
        _isSearching = true;
      });
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    final historyService = Provider.of<ChatHistoryService>(
      context,
      listen: false,
    );
    try {
      final results = await historyService.searchHistories(query);
      if (mounted) {
        setState(() {
          _filteredHistories = results;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  void _loadChatHistory(History history) {
    final chatApi = Provider.of<ChatApi>(context, listen: false);
    chatApi.loadChatHistory(history);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded chat from ${_getFormattedDate(history)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getFormattedDate(History history) {
    final historyService = Provider.of<ChatHistoryService>(
      context,
      listen: false,
    );
    return historyService.getFormattedDate(history);
  }

  String _getHistoryTitle(History history) {
    final historyService = Provider.of<ChatHistoryService>(
      context,
      listen: false,
    );
    return historyService.getHistoryTitle(history);
  }

  Future<void> _deleteHistory(History history) async {
    final historyService = Provider.of<ChatHistoryService>(
      context,
      listen: false,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && history.id != null) {
      await historyService.deleteHistory(history.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final historyService = Provider.of<ChatHistoryService>(
      context,
      listen: false,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all chat history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await historyService.clearAllHistories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All chat history cleared')),
        );
      }
    }
  }

  void _startNewChat() {
    final chatApi = Provider.of<ChatApi>(context, listen: false);
    chatApi.clearMessages();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.zero,
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/rethink.png',
                height: 25,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),

          // Action buttons
          ListTile(
            title: const Text('New Chat'),
            onTap: _startNewChat,
            leading: const Icon(Icons.add),
          ),

          ListTile(
            title: AnimatedTextKit(
              totalRepeatCount: 1,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GenAIScreen()),
                );
              },
              animatedTexts: [
                ColorizeAnimatedText(
                  speed: const Duration(milliseconds: 500),
                  'Generative AI',
                  textStyle: const TextStyle(fontSize: 16),
                  colors: [
                    Theme.of(context).colorScheme.onSecondary,
                    Colors.purple,
                    Colors.blue,
                    Theme.of(context).colorScheme.onSecondary,
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenAIScreen()),
              );
            },
            leading: const Icon(Icons.auto_awesome),
          ),

          // Auto-save toggle
          Consumer<ChatApi>(
            builder: (context, chatApi, child) {
              return SwitchListTile(
                title: const Text('Incognito'),
                value: !chatApi.autoSaveEnabled,
                onChanged: (value) {
                  chatApi.setAutoSave(!chatApi.autoSaveEnabled);
                },
                secondary: Icon(Icons.visibility_off_outlined),
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surface.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Chat history list
          Expanded(
            child: Consumer<ChatHistoryService>(
              builder: (context, historyService, child) {
                if (historyService.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final historiesToShow = _isSearching
                    ? _filteredHistories
                    : historyService.histories;

                if (historiesToShow.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _isSearching ? 'No chats found' : 'No chat history yet',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondary.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: historiesToShow.length,
                  itemBuilder: (context, index) {
                    final history = historiesToShow[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.5),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        title: Text(
                          _getHistoryTitle(history),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getFormattedDate(history),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${history.messages.length} msgs',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'delete':
                                await _deleteHistory(history);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        onTap: () => _loadChatHistory(history),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Clear all history button
          Consumer<ChatHistoryService>(
            builder: (context, historyService, child) {
              if (historyService.histories.isEmpty)
                return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _clearAllHistory,
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

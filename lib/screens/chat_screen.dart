import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rethink/components/nav_drawer.dart';
import 'package:rethink/services/chat_api.dart';
import 'package:rethink/components/chat_message.dart';
import 'package:rethink/components/model_selector.dart';
import 'package:rethink/constants/app_constants.dart';
import 'package:rethink/models/ai_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  AIModel _currentModel = AppConstants.availableModels.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-save when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final chatApi = Provider.of<ChatApi>(context, listen: false);
      if (chatApi.hasUnsavedChanges()) {
        chatApi.saveCurrentChat();
      }
    }
  }

  Future<void> _showSaveDialog() async {
    final chatApi = Provider.of<ChatApi>(context, listen: false);

    if (!chatApi.hasUnsavedChanges()) {
      chatApi.startNewChat();
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Current Chat?'),
        content: const Text(
          'You have unsaved changes. Would you like to save this conversation before starting a new chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Don\'t Save'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await chatApi.saveCurrentChat();
    }

    chatApi.startNewChat();
  }

  // String _getAppBarTitle(ChatApi chatApi) {
  //   if (chatApi.currentHistoryId != null) {
  //     return chatApi.getCurrentChatSummary();
  //   }
  //   return 'New Chat';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Consumer<ChatApi>(
                builder: (context, chatApi, child) {
                  return Row(
                    children: [
                      Image.asset(
                        'assets/rethink.png',
                        height: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      // const SizedBox(width: 8),
                      // Expanded(
                      //   child: Text(
                      //     _getAppBarTitle(chatApi),
                      //     style: const TextStyle(fontSize: 16),
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                      if (chatApi.hasUnsavedChanges())
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        actions: [
          // Model selector
          FilledButton.tonalIcon(
            onPressed: () => showModalBottomSheet(
              showDragHandle: true,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              context: context,
              builder: (context) => ModelSelector(
                currentModel: _currentModel,
                onModelSelected: (model) {
                  setState(() {
                    _currentModel = model;
                  });
                },
              ),
            ),
            label: Text(_currentModel.name.split(' ').first),
            icon: const Icon(Icons.arrow_drop_down),
          ),

          // New chat button
          IconButton(
            onPressed: _showSaveDialog,
            icon: const Icon(Icons.add),
            tooltip: 'New Chat',
          ),
        ],
      ),
      drawer: const NavDrawer(),
      body: Builder(
        builder: (context) {
          return GestureDetector(
            onHorizontalDragStart: (details) =>
                Scaffold.of(context).openDrawer(),
            child: Consumer<ChatApi>(
              builder: (context, state, child) {
                return Column(
                  children: [
                    // // Chat status indicator
                    // if (state.currentHistoryId != null ||
                    //     state.hasUnsavedChanges())
                    //   Container(
                    //     width: double.infinity,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 4,
                    //     ),
                    //     color: Theme.of(
                    //       context,
                    //     ).colorScheme.secondary.withOpacity(0.3),
                    //     child: Row(
                    //       children: [
                    //         Icon(
                    //           state.currentHistoryId != null
                    //               ? Icons.history
                    //               : Icons.edit,
                    //           size: 16,
                    //           color: Theme.of(
                    //             context,
                    //           ).colorScheme.onSecondary.withOpacity(0.7),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         Expanded(
                    //           child: Text(
                    //             state.currentHistoryId != null
                    //                 ? 'Loaded chat • ${state.messages.length} messages'
                    //                 : 'New chat • ${state.messages.length} messages',
                    //             style: TextStyle(
                    //               fontSize: 12,
                    //               color: Theme.of(
                    //                 context,
                    //               ).colorScheme.onSecondary.withOpacity(0.7),
                    //             ),
                    //           ),
                    //         ),
                    //         if (state.hasUnsavedChanges())
                    //           Row(
                    //             children: [
                    //               Icon(
                    //                 Icons.circle,
                    //                 size: 8,
                    //                 color: Colors.orange,
                    //               ),
                    //               const SizedBox(width: 4),
                    //               Text(
                    //                 'Unsaved',
                    //                 style: TextStyle(
                    //                   fontSize: 10,
                    //                   color: Colors.orange.shade700,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         if (!state.autoSaveEnabled)
                    //           Padding(
                    //             padding: const EdgeInsets.only(left: 8),
                    //             child: Icon(
                    //               Icons.save_outlined,
                    //               size: 14,
                    //               color: Colors.grey,
                    //             ),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    Expanded(
                      child: state.messages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Start a conversation',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 30,
                                    ),
                                    child: Text(
                                      'Feel free to ask me anything!',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Quick action buttons
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    direction: Axis.vertical,
                                    children: AppConstants.suggestionPrompts
                                        .map((prompt) {
                                          return ActionChip(
                                            label: Text(
                                              prompt,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            onPressed: () {
                                              state.messageController.text =
                                                  prompt;
                                              state.sendMessage(
                                                model: _currentModel.id,
                                              );
                                            },
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            side: BorderSide.none,
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: state.scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                return ChatMessageWidget(
                                  message: state.messages[index],
                                );
                              },
                            ),
                    ),

                    // Loading indicator
                    if (state.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                ColorizeAnimatedText(
                                  'Thinking',
                                  textStyle: const TextStyle(fontSize: 16),
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context).colorScheme.onPrimary,
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Input area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              controller: state.messageController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                hintText: 'Type a message',
                                suffixIcon:
                                    state.messageController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          state.messageController.clear();
                                          setState(
                                            () {},
                                          ); // Refresh to hide clear button
                                        },
                                      )
                                    : null,
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) =>
                                  state.sendMessage(model: _currentModel.id),
                              enabled: !state.isLoading,
                              onChanged: (value) {
                                // Trigger rebuild to show/hide clear button
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Send button
                          IconButton(
                            onPressed:
                                state.isLoading ||
                                    state.messageController.text.trim().isEmpty
                                ? null
                                : () => state.sendMessage(
                                    model: _currentModel.id,
                                  ),
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              color:
                                  state.isLoading ||
                                      state.messageController.text
                                          .trim()
                                          .isEmpty
                                  ? Colors.grey
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),

                          // // Manual save button (when auto-save is off)
                          // if (!state.autoSaveEnabled &&
                          //     state.messages.isNotEmpty)
                          //   IconButton(
                          //     onPressed: () async {
                          //       await state.saveCurrentChat();
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         const SnackBar(
                          //           content: Text('Chat saved'),
                          //           duration: Duration(seconds: 2),
                          //         ),
                          //       );
                          //     },
                          //     icon: Icon(
                          //       state.hasUnsavedChanges()
                          //           ? Icons.save
                          //           : Icons.save_outlined,
                          //       color: state.hasUnsavedChanges()
                          //           ? Colors.orange
                          //           : Colors.grey,
                          //     ),
                          //     tooltip: 'Save Chat',
                          //   ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

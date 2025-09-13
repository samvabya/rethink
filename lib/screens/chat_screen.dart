import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _ChatScreenState extends State<ChatScreen> {
  AIModel _currentModel = AppConstants.availableModels.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Image.asset(
            'assets/rethink.png',
            height: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
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
            label: Text(_currentModel.provider),
            icon: const Icon(Icons.arrow_drop_down),
          ),
          IconButton(
            onPressed: () {
              Provider.of<ChatApi>(context, listen: false).clearMessages();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(title: Text('Item 1'), onTap: () {}),
            ListTile(title: Text('Item 2'), onTap: () {}),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragStart: (details) => Scaffold.of(context).openDrawer(),
        child: Consumer<ChatApi>(
          builder: (context, state, child) {
            return Column(
              children: [
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Start a conversation',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 30,
                                ),
                                child: Text(
                                  'Feel free to ask me anything!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
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
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Thinking...'),
                      ],
                    ),
                  ),
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
                            fillColor: Theme.of(context).colorScheme.surface,
                            hintText: 'Type a message',
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) =>
                              state.sendMessage(model: _currentModel.id),
                          enabled: !state.isLoading,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: state.isLoading
                            ? null
                            : () => state.sendMessage(model: _currentModel.id),
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rethink/services/chat_api.dart';
import 'package:rethink/screens/chat_screen.dart';
import 'package:rethink/services/image_api.dart';
import 'package:rethink/services/chat_history_service.dart';
import 'package:rethink/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatHistoryService>(
          create: (_) => ChatHistoryService()..initialize(),
        ),
        ChangeNotifierProvider<ChatApi>(
          create: (_) => ChatApi(),
        ),
        ChangeNotifierProvider<ImageGeneratorProvider>(
          create: (_) => ImageGeneratorProvider(),
        ),
      ],
      child: Consumer2<ChatApi, ChatHistoryService>(
        builder: (context, chatApi, historyService, child) {
          // Set up the save callback when providers are available
          chatApi.setSaveCallback(() async {
            if (chatApi.messages.isNotEmpty) {
              if (chatApi.currentHistoryId != null) {
                // Update existing chat
                await historyService.updateChatSession(
                  chatApi.currentHistoryId!,
                  chatApi.messages,
                );
              } else {
                // Save new chat
                final historyId = await historyService.saveChatSession(chatApi.messages);
                if (historyId != null) {
                  chatApi.updateCurrentHistoryId(historyId);
                }
              }
            }
          });

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
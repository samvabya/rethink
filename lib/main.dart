import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rethink/services/chat_api.dart';
import 'package:rethink/screens/chat_screen.dart';
import 'package:rethink/services/image_api.dart';
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
        ChangeNotifierProvider<ChatApi>(create: (_) => ChatApi()),
        ChangeNotifierProvider<ImageGeneratorProvider>(
          create: (_) => ImageGeneratorProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        home: ChatScreen(),
      ),
    );
  }
}

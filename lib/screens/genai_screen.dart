import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rethink/components/generated_image.dart';
import 'package:rethink/components/loading_indicator.dart';
import 'package:rethink/components/prompt_input.dart';
import 'package:rethink/services/image_api.dart';

class GenAIScreen extends StatelessWidget {
  const GenAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageGeneratorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Row(
                children: [
                  Image.asset(
                    'assets/reth.png',
                    height: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.clear),
                  const SizedBox(width: 8),
                  AnimatedTextKit(
                    totalRepeatCount: 1,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        speed: Duration(milliseconds: 500),
                        'Gen AI',
                        textStyle: const TextStyle(fontSize: 20),
                        colors: [
                          Theme.of(context).colorScheme.onSecondary,
                          Colors.purple,
                          Colors.blue,
                          Theme.of(context).colorScheme.onSecondary,
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (imageProvider.isLoading)
                    const LoadingIndicator()
                  else if (imageProvider.generatedImageBytes != null)
                    const GeneratedImage()
                  else
                    AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Text(
                          'Describe your image',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const PromptInput(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rethink/services/image_api.dart';

class PromptInput extends StatefulWidget {
  const PromptInput({Key? key}) : super(key: key);

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageGeneratorProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: TextField(
            controller: _promptController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'A magical Disney-inspired castle...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _promptController.clear();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: imageProvider.isLoading
                ? null
                : () {
                    if (_promptController.text.isNotEmpty) {
                      imageProvider.generateImage(_promptController.text);
                      FocusScope.of(context).unfocus();
                    }
                  },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

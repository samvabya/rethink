import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:rethink/services/image_api.dart';
import 'package:share_plus/share_plus.dart';

class GeneratedImage extends StatelessWidget {
  const GeneratedImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageGeneratorProvider>(context);
    final imageBytes = imageProvider.generatedImageBytes;

    if (imageBytes == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your generated image',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: const Color(0xFF2A2A2A),
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionButton(
              icon: Icons.download_outlined,
              label: 'Save',
              onPressed: () async {
                try {
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/reimage.png');
                  await file.writeAsBytes(imageBytes);

                  final success = await GallerySaver.saveImage(file.path);

                  if (success == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image saved to gallery'),
                        backgroundColor: Color(0xFF6C63FF),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save image: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(width: 16),
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onPressed: () async {
                try {
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/reimage.png');
                  await file.writeAsBytes(imageBytes);

                  await Share.shareXFiles([XFile(file.path)]);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to share image: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(width: 16),
            _ActionButton(
              icon: Icons.refresh_outlined,
              label: 'New',
              onPressed: () {
                imageProvider.reset();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

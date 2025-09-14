import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Lottie.network(
            'https://lottie.host/a0212015-627a-4317-845d-3d3965c6a655/zjlY7kbx3E.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Creating your masterpiece...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

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
            'https://assets10.lottiefiles.com/packages/lf20_rwq6ciql.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'Creating your masterpiece...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

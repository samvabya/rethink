import 'package:flutter/material.dart';
import '../models/ai_model.dart';
import '../constants/app_constants.dart';

class ModelSelector extends StatelessWidget {
  final AIModel currentModel;
  final Function(AIModel) onModelSelected;

  const ModelSelector({
    super.key,
    required this.currentModel,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [_buildModelSelectionSection(context)],
      ),
    );
  }

  Widget _buildModelSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppConstants.availableModels.length}+ ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                    TextSpan(
                      text: 'Ai Models',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildModelGroups(context),
      ],
    );
  }

  Widget _buildModelGroups(BuildContext context) {
    // Group models by provider
    final modelsByProvider = <String, List<AIModel>>{};

    for (final model in AppConstants.availableModels) {
      if (!modelsByProvider.containsKey(model.provider)) {
        modelsByProvider[model.provider] = [];
      }
      modelsByProvider[model.provider]!.add(model);
    }

    return Column(
      children: modelsByProvider.entries.map((entry) {
        return _buildProviderSection(context, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildProviderSection(
    BuildContext context,
    String provider,
    List<AIModel> models,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(
            provider,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
        ...models.map((model) => _buildModelTile(context, model)),
      ],
    );
  }

  Widget _buildModelTile(BuildContext context, AIModel model) {
    return RadioListTile<AIModel>(
      title: Text(
        model.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.provider,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (model.isPlus)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Plus',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
        ],
      ),
      value: model,
      groupValue: currentModel,
      onChanged: (value) {
        if (value != null) {
          onModelSelected(value);
          Navigator.of(context).pop();
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }
}

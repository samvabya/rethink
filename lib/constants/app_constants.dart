import '../models/ai_model.dart';

class AppConstants {
  static const String appName = 'Reprompt';
  static const String openRouterBaseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String envKeyOpenRouter = 'OPENROUTER_API_KEY';

  static const List<AIModel> availableModels = [
    AIModel(
      id: 'openai/gpt-4o-mini-2024-07-18',
      name: 'OpenAI GPT-4o Mini',
      provider: 'OpenAI',
      isPlus: false,
    ),
    AIModel(
      id: 'google/gemma-3n-e4b-it:free',
      name: 'Google Gemma 3n E4B IT',
      provider: 'Google',
      isPlus: false,
    ),
    AIModel(
      id: 'google/gemini-2.0-flash-exp:free',
      name: 'Gemini 2.0 Flash',
      provider: 'Google',
      isPlus: false,
    ),
    AIModel(
      id: 'meta-llama/llama-3.2-3b-instruct:free',
      name: 'Meta Llama 3.2 3B Instruct',
      provider: 'Meta',
      isPlus: false,
    ),
    AIModel(
      id: 'deepseek/deepseek-r1:free',
      name: 'DeepSeek: R1',
      provider: 'DeepSeek',
      isPlus: true,
    ),
    AIModel(
      id: 'deepseek/deepseek-chat:free',
      name: 'DeepSeek V3',
      provider: 'DeepSeek',
      isPlus: false,
    ),
    AIModel(
      id: 'mistralai/devstral-small:free',
      name: 'Mistral: Devstral Small',
      provider: 'Mistral',
      isPlus: false,
    ),
    AIModel(
      id: 'microsoft/phi-4-reasoning:free',
      name: 'Microsoft: Phi 4 Reasoning',
      provider: 'Microsoft',
      isPlus: true,
    ),
    AIModel(
      id: 'qwen/qwen3-30b-a3b:free',
      name: 'Qwen3 30B A3B',
      provider: 'Qwen',
      isPlus: false,
    ),
  ];

  static const List<String> suggestionPrompts = [
    'Tell me a joke',
    'Write a poem about nature',
    'Explain quantum computing',
    'Give me a recipe idea',
  ];
}


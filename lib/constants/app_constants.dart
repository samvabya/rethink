import '../models/ai_model.dart';

class AppConstants {
  static const String appName = 'Reprompt';
  static const String openRouterBaseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String envKeyOpenRouter = 'OPENROUTER_API_KEY';

  static const List<AIModel> availableModels = [
    AIModel(
      id: 'meta-llama/llama-3.2-3b-instruct:free',
      name: 'Meta Llama 3.2 3B Instruct',
      provider: 'Meta',
      isPlus: false,
    ),
    AIModel(
      id: 'openai/gpt-oss-120b:free',
      name: 'OpenAI GPT-120B',
      provider: 'OpenAI',
      isPlus: false,
    ),
    AIModel(
      id: 'google/gemini-2.0-flash-exp:free',
      name: 'Gemini 2.0 Flash',
      provider: 'Google',
      isPlus: false,
    ),
    AIModel(
      id: 'google/gemma-3n-e2b-it:free',
      name: 'Google Gemma 3n E2B It',
      provider: 'Google',
      isPlus: true,
    ),
    AIModel(
      id: 'deepseek/deepseek-chat-v3.1:free',
      name: 'DeepSeek V3.1',
      provider: 'DeepSeek',
      isPlus: false,
    ),
    AIModel(
      id: 'deepseek/deepseek-r1:free',
      name: 'DeepSeek R1',
      provider: 'DeepSeek',
      isPlus: true,
    ),
    AIModel(
      id: 'nvidia/nemotron-nano-9b-v2:free',
      name: 'Nemotron Nano 9B V2',
      provider: 'Nvidia',
      isPlus: true,
    ),
    AIModel(
      id: 'mistralai/mistral-small-3.2-24b-instruct:free',
      name: 'Mistral Devstral Small',
      provider: 'Mistral',
      isPlus: false,
    ),
    AIModel(
      id: 'microsoft/phi-4-reasoning:free',
      name: 'Microsoft Phi 4 Reasoning',
      provider: 'Microsoft',
      isPlus: true,
    ),
    AIModel(
      id: 'qwen/qwen3-30b-a3b:free',
      name: 'Qwen 3 30B A3B',
      provider: 'Qwen',
      isPlus: true,
    ),
    AIModel(
      id: 'agentica-org/deepcoder-14b-preview:free',
      name: 'DeepCoder 14B Preview',
      provider: 'Agentica',
      isPlus: true,
    ),
    AIModel(
      id: 'tencent/hunyuan-a13b-instruct:free',
      name: 'Hunyuan A13B Instruct',
      provider: 'Tencent',
      isPlus: true,
    ),
  ];

  static const List<String> suggestionPrompts = [
    'Tell me a joke',
    'Write a poem about nature',
    'Give me a recipe idea',
  ];
}

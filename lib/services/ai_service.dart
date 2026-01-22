import 'dart:convert';
import 'package:flexplan/models/micro_task.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  final GenerativeModel _model;

  AIService(String apiKey)
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are an elite productivity coach and goal strategist. Your specialty is the SMART (Specific, Measurable, Achievable, Relevant, Time-bound) framework. '
          'Your objective is to transform vague ambitions into a sequence of daily, bite-sized micro-tasks. '
          'Rules for tasks: '
          '1. Each task must be actionable and take less than 30 minutes. '
          '2. The sequence must show logical progression (introductory tasks first, increasing in difficulty). '
          '3. Provide specific examples or "how-to" hints within the description when possible. '
          '4. Ensure every single day has a unique, meaningful task. '
          'Respond ONLY with a valid JSON array matching the provided schema.',
        ),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.array(
            items: Schema.object(
              properties: {
                'description': Schema.string(
                  description:
                      'A specific, actionable instruction. Example: "Watch a 10-min tutorial on Flutter State Management" instead of "Learn state management".',
                ),
                'day': Schema.integer(description: 'The day index (1-based).'),
              },
              requiredProperties: ['description', 'day'],
            ),
          ),
        ),
      );

  Future<List<MicroTask>> generateTasks(
    String goalTitle,
    String goalDescription,
    int durationDays,
  ) async {
    final prompt =
        '''
    User's Primary Goal: "$goalTitle"
    Context/Details: "$goalDescription"
    Plan Duration: $durationDays days
    
    Strategy: Create a high-momentum plan. 
    Days 1-2: Low barrier to entry to build habit.
    Middle days: Core learning/execution.
    Final days: Review, assessment, or milestone completion.
    
    Requirement: Generate exactly $durationDays tasks.
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response.text == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(response.text!);
      final List<MicroTask> tasks = [];
      final now = DateTime.now();

      for (var item in jsonList) {
        tasks.add(
          MicroTask(
            description: item['description'],
            scheduledDate: now.add(Duration(days: (item['day'] as int) - 1)),
          ),
        );
      }
      return tasks;
    } catch (e) {
      debugPrint('Error parsing AI response: $e');
      return [];
    }
  }
}

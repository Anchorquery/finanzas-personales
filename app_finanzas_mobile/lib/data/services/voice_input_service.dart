import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:langchain_core/chat_models.dart' as lc;
import 'package:langchain_core/prompts.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Result of parsing free-form Spanish/English voice transcription.
class ParsedVoiceTransaction {
  ParsedVoiceTransaction({
    required this.amount,
    required this.type,
    this.concept,
    this.categoryHint,
    this.dateIso,
  });

  final double amount;
  final String type; // 'income' | 'expense'
  final String? concept;
  final String? categoryHint;
  final String? dateIso;

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'type': type,
        'concept': concept,
        'category': categoryHint,
        'date': dateIso,
      };
}

/// Captures voice, transcribes locally, then asks Gemini to extract
/// structured transaction fields.
class VoiceInputService extends GetxService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  final isAvailable = false.obs;
  final isListening = false.obs;
  final transcript = ''.obs;
  final lastError = ''.obs;

  Future<bool> ensureInitialized() async {
    if (isAvailable.value) return true;
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (e) {
        lastError.value = e.errorMsg;
        isListening.value = false;
      },
    );
    isAvailable.value = ok;
    return ok;
  }

  Future<void> start({String localeId = 'es_ES'}) async {
    if (!await ensureInitialized()) return;
    transcript.value = '';
    lastError.value = '';
    isListening.value = true;
    await _speech.listen(
      onResult: (r) => transcript.value = r.recognizedWords,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stop() async {
    if (_speech.isListening) await _speech.stop();
    isListening.value = false;
  }

  /// Uses Gemini to extract structured fields from free-form text.
  /// Returns null on parse failure.
  Future<ParsedVoiceTransaction?> parseWithGemini({
    required String apiKey,
    required String text,
    String? model,
  }) async {
    if (text.trim().isEmpty) return null;

    final chat = ChatGoogleGenerativeAI(
      apiKey: apiKey,
      defaultOptions: ChatGoogleGenerativeAIOptions(
        model: model ?? 'gemini-2.5-flash',
        temperature: 0,
        responseMimeType: 'application/json',
      ),
    );

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final prompt = PromptValue.chat([
      lc.ChatMessage.system(
        'Extrae datos de una transacción financiera desde texto en español o inglés. '
        'Hoy es $today. Devuelve SOLO JSON con campos: '
        'amount (number, positive), type ("income"|"expense"), '
        'concept (string short, optional), category (string, optional, una de: '
        'Comida, Transporte, Entretenimiento, Salud, Educación, Hogar, Ropa, '
        'Tecnología, Servicios, Salario, Otros), date (YYYY-MM-DD, optional, '
        'default hoy). Si el texto no contiene monto válido, devuelve {"amount":0}.',
      ),
      lc.ChatMessage.humanText(text),
    ]);

    try {
      final result = await chat.invoke(prompt).timeout(
            const Duration(seconds: 20),
          );
      final raw = result.output.content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      if (amount <= 0) return null;
      return ParsedVoiceTransaction(
        amount: amount,
        type: (data['type'] as String?) ?? 'expense',
        concept: data['concept'] as String?,
        categoryHint: data['category'] as String?,
        dateIso: data['date'] as String?,
      );
    } catch (e) {
      lastError.value = 'Parse: $e';
      return null;
    }
  }
}

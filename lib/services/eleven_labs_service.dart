import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const String _apiKey = 'sk_c782ab4a95466757480108592b65243e48b657be04056339'; // Store this securely
  
  // Default voice IDs - you can change these or make them configurable
  static const Map<String, String> voiceIds = {
    'Rachel': 'SOYHLrjzK2X1ezoPC6cr',
    'Drew': 'jsCqWAovK2LkecY7zXl4',
    'Clyde': '2EiwWnXFnvU5JabPnv8n',
    'Adam': 'pNInz6obpgDQGcFmaJgB',
  };

  // Cache for storing synthesized audio
  final Map<String, List<int>> _audioCache = {};
  String _selectedVoiceId = voiceIds['Rachel']!;

  void setVoice(String voiceId) {
    _selectedVoiceId = voiceId;
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> voices = json.decode(response.body)['voices'];
        return voices.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load voices');
    } catch (e) {
      debugPrint('Error getting voices: $e');
      return [];
    }
  }

  Future<List<int>?> synthesizeText({
    required String text,
    required String cacheKey,
    double stability = 0.5,
    double similarityBoost = 0.5,
  }) async {
    // Check cache first
    if (_audioCache.containsKey(cacheKey)) {
      return _audioCache[cacheKey];
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/text-to-speech/$_selectedVoiceId'),
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'text': text,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': stability,
            'similarity_boost': similarityBoost,
          },
        }),
      );

      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;
        // Cache the result
        _audioCache[cacheKey] = audioData;
        return audioData;
      }
      throw Exception('Failed to synthesize speech');
    } catch (e) {
      debugPrint('Error synthesizing speech: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getVoiceSettings(String voiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/voices/$voiceId/settings'),
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to get voice settings');
    } catch (e) {
      debugPrint('Error getting voice settings: $e');
      return {};
    }
  }

  // Clear cache for a specific page
  void clearPageCache(String pageKey) {
    _audioCache.remove(pageKey);
  }

  // Clear entire cache
  void clearCache() {
    _audioCache.clear();
  }

  // Get estimated character count for cost calculation
  int getEstimatedCharacterCount(String text) {
    return text.length;
  }

  // Calculate estimated cost (based on Eleven Labs pricing)
  double calculateEstimatedCost(int characterCount) {
    // Current pricing: $1 per 100,000 characters
    return (characterCount / 100000) * 1.0;
  }
} 
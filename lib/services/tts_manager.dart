import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'eleven_labs_service.dart';

class TTSManager {
  final ElevenLabsService _elevenLabsService;
  AudioPlayer? _audioPlayer;
  
  // Queue for managing pages to be read
  final Queue<Map<String, dynamic>> _pageQueue = Queue<Map<String, dynamic>>();
  bool _isProcessing = false;
  bool _isInitialized = false;
  
  // Current state
  bool _isPlaying = false;
  int _currentPage = 1;
  String _currentText = '';
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  
  // Stream controllers
  final _playingStateController = StreamController<bool>.broadcast();
  final _progressController = StreamController<Duration>.broadcast();
  final _currentPageController = StreamController<int>.broadcast();
  
  Stream<bool> get playingState => _playingStateController.stream;
  Stream<Duration> get progress => _progressController.stream;
  Stream<int> get currentPage => _currentPageController.stream;
  
  TTSManager() : _elevenLabsService = ElevenLabsService() {
    _initAudioPlayer();
  }
  
  Future<void> _initAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      await _setupAudioPlayer();
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
      // Try to reinitialize after a delay
      await Future.delayed(const Duration(seconds: 1));
      _initAudioPlayer();
    }
  }
  
  Future<void> _setupAudioPlayer() async {
    if (_audioPlayer == null) return;
    
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      ));
      
      _audioPlayer!.positionStream.listen((position) {
        _progressController.add(position);
      });
      
      _audioPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error setting up audio player: $e');
    }
  }
  
  Future<void> startReading({
    required String text,
    required int pageNumber,
    required String voiceId,
  }) async {
    if (_audioPlayer == null) {
      await _initAudioPlayer();
    }
    
    _currentPage = pageNumber;
    _currentText = text;
    _elevenLabsService.setVoice(voiceId);
    
    // Calculate estimated cost
    final charCount = _elevenLabsService.getEstimatedCharacterCount(text);
    final cost = _elevenLabsService.calculateEstimatedCost(charCount);
    
    debugPrint('Estimated cost for page $pageNumber: \$$cost');
    
    // Add to queue
    _pageQueue.add({
      'text': text,
      'page': pageNumber,
      'cacheKey': 'page_$pageNumber',
    });
    
    if (!_isProcessing) {
      await _processQueue();
    }
  }
  
  Future<void> _processQueue() async {
    if (_pageQueue.isEmpty) {
      _isProcessing = false;
      return;
    }
    
    _isProcessing = true;
    final page = _pageQueue.first;
    
    try {
      final audioData = await _elevenLabsService.synthesizeText(
        text: page['text'],
        cacheKey: page['cacheKey'],
      );
      
      if (audioData != null) {
        await _playAudio(audioData);
        _pageQueue.removeFirst();
      }
    } catch (e) {
      debugPrint('Error processing TTS: $e');
      rethrow; // Propagate error to handle in UI
    }
  }
  
  Future<void> _playAudio(List<int> audioData) async {
    if (_audioPlayer == null) return;
    
    try {
      final audioBytes = Uint8List.fromList(audioData);
      final audioSource = BytesAudioSource(audioBytes);
      
      await _audioPlayer!.setAudioSource(audioSource);
      await _audioPlayer!.play();
      _isPlaying = true;
      _playingStateController.add(true);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _isPlaying = false;
      _playingStateController.add(false);
    }
  }
  
  Future<void> _playNext() async {
    if (_pageQueue.isNotEmpty) {
      _processQueue();
    } else {
      _isPlaying = false;
      _playingStateController.add(false);
    }
  }
  
  Future<void> pause() async {
    await _audioPlayer?.pause();
    _isPlaying = false;
    _playingStateController.add(false);
  }
  
  Future<void> resume() async {
    await _audioPlayer?.play();
    _isPlaying = true;
    _playingStateController.add(true);
  }
  
  Future<void> stop() async {
    await _audioPlayer?.stop();
    _pageQueue.clear();
    _isPlaying = false;
    _playingStateController.add(false);
  }
  
  Future<void> seekTo(Duration position) async {
    await _audioPlayer?.seek(position);
  }
  
  Future<void> skipForward() async {
    if (_audioPlayer == null) return;
    final position = _audioPlayer!.position;
    await seekTo(position + const Duration(seconds: 10));
  }
  
  Future<void> skipBackward() async {
    if (_audioPlayer == null) return;
    final position = _audioPlayer!.position;
    await seekTo(position - const Duration(seconds: 10));
  }
  
  void dispose() {
    _audioPlayer?.dispose();
    _playingStateController.close();
    _progressController.close();
    _currentPageController.close();
  }
  
  void reset() {
    _isInitialized = false;
    _pageQueue.clear();
    _isProcessing = false;
    _isPlaying = false;
    _audioPlayer?.stop();
  }
}

class BytesAudioSource extends StreamAudioSource {
  final Uint8List _buffer;
  
  BytesAudioSource(this._buffer);
  
  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.length;
    
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.sublist(start, end)),
      contentType: 'audio/mp3',
    );
  }
  
  @override
  Future<void> close() async {
    // No resources to release
  }
} 
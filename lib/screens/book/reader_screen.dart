import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../utils/constants.dart';
import 'dart:ui';
import 'note_editor_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:lottie/lottie.dart';
import '../../services/tts_manager.dart';
import '../../services/eleven_labs_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class Note {
  final String content;
  final int pageNumber;
  final DateTime timestamp;
  final String? highlight;
  final Color color;

  Note({
    required this.content,
    required this.pageNumber,
    required this.timestamp,
    this.highlight,
    this.color = Colors.yellow,
  });
}

// Add this class before the ReaderScreen class
class SmoothScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

class ReaderScreen extends StatefulWidget {
  final String pdfPath;
  final String bookTitle;
  final String authorName;
  final String coverImageUrl;

  const ReaderScreen({
    Key? key,
    required this.pdfPath,
    required this.bookTitle,
    required this.authorName,
    this.coverImageUrl = '',
  }) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> with SingleTickerProviderStateMixin {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  bool _isBookmarked = false;
  bool _showControls = true;
  bool _isLoading = true;

  final ValueNotifier<double> _currentPage = ValueNotifier<double>(1);
  final ValueNotifier<double> _totalPages = ValueNotifier<double>(0);

  late AnimationController _fadeController;

  int _selectedDesign = 0;

  Color _tintColor = Colors.transparent;
  bool _isNightMode = false;
  double _fontSize = 1.0;

  Offset? _tapPosition;
  DateTime? _lastTapTime;
  bool _isDragging = false;

  Timer? _autoHideTimer;

  bool _isTTSPlaying = false;
  bool _showTTSControls = false;

  bool _showNotesPanel = false;

  final List<Note> _notes = [];
  final TextEditingController _noteController = TextEditingController();
  String? _selectedHighlight;
  Color _noteColor = Colors.yellow;

  late PageController _noteCardController;

  bool get isDesktopLayout => MediaQuery.of(context).size.width >= 1024;

  bool _showTintPanel = false;
  final List<Map<String, dynamic>> _predefinedTints = [
    {'name': 'None', 'color': Colors.transparent},
    {'name': 'Sepia', 'color': Colors.brown.withOpacity(0.1)},
    {'name': 'Warm', 'color': Colors.orange.withOpacity(0.1)},
    {'name': 'Cool', 'color': Colors.blue.withOpacity(0.1)},
    {'name': 'Green', 'color': Colors.green.withOpacity(0.1)},
    {'name': 'Gray', 'color': Colors.grey.withOpacity(0.1)},
  ];

  bool _showTTSPanel = false;
  double _speechRate = 1.0;
  String _selectedVoice = 'Default';
  final List<String> _availableVoices = ['Default', 'Male', 'Female', 'Natural'];
  double _pitch = 1.0;
  int _currentParagraph = 0;
  bool _isAutoScroll = false;

  bool _showFontPanel = false;
  double _lineHeight = 1.5;
  double _letterSpacing = 0.0;
  String _selectedFont = 'Urbanist';
  final List<String> _availableFonts = [
    'Urbanist',
    'Roboto',
    'Open Sans',
    'Lato',
    'Merriweather',
    'Playfair Display'
  ];

  // Add TTSManager
  late TTSManager _ttsManager;

  // Add this property at the top of the class
  Timer? _selectionTimer;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _ttsManager = TTSManager();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    _autoHideControls();
    _noteCardController = PageController(viewportFraction: 0.85);

    // Listen to TTS state changes
    _ttsManager.playingState.listen((isPlaying) {
      setState(() {
        _isTTSPlaying = isPlaying;
      });
    });
  }

  void _autoHideControls() {
    _autoHideTimer?.cancel();
    
    _autoHideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) {
        _hideControls();
      }
    });
  }

  @override
  void dispose() {
    _selectionTimer?.cancel();
    _ttsManager.dispose();
    _autoHideTimer?.cancel();
    _pdfViewerController.dispose();
    _fadeController.dispose();
    _currentPage.dispose();
    _totalPages.dispose();
    _noteController.dispose();
    _noteCardController.dispose();
    super.dispose();
  }

  void _hideControls() {
    if (mounted && _showControls) {
      setState(() {
        _showControls = false;
      });
      _fadeController.forward();
    }
  }

  void _toggleControls() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
      });
      if (_showControls) {
        _fadeController.reverse();
        _autoHideControls();
      } else {
        _fadeController.forward();
        _autoHideTimer?.cancel();
      }
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    HapticFeedback.lightImpact();
  }

  void _showReadingSettings() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
        decoration: BoxDecoration(
          color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reading Settings',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isNightMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickSettingButton(
                  icon: Icons.brightness_6,
                  label: 'Brightness',
                  onTap: () {
                    Navigator.pop(context);
                    _showNoteEditor();
                  },
                ),
                _buildQuickSettingButton(
                  icon: Icons.color_lens,
                  label: 'Tint',
                  onTap: () {
                    Navigator.pop(context);
                    _showColorPicker();
                  },
                ),
                _buildQuickSettingButton(
                  icon: Icons.text_fields,
                  label: 'Font',
                  onTap: () {
                    Navigator.pop(context);
                    _showFontSettings();
                  },
                ),
                _buildQuickSettingButton(
                  icon: Icons.nights_stay,
                  label: 'Night Mode',
                  onTap: () {
                    setState(() => _isNightMode = !_isNightMode);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteEditor() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Note',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                maxLines: 5,
                style: GoogleFonts.urbanist(
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your note here...',
                  hintStyle: GoogleFonts.urbanist(
                    color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isNightMode ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.urbanist(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      // TODO: Save note logic here
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Save',
                      style: GoogleFonts.urbanist(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    if (isDesktopLayout) {
      setState(() => _showTintPanel = true);
    } else {
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page Tint',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTintOption(Colors.transparent, 'None'),
                  _buildTintOption(Colors.amber.withOpacity(0.2), 'Warm'),
                  _buildTintOption(Colors.blue.withOpacity(0.2), 'Cool'),
                  _buildTintOption(Colors.green.withOpacity(0.2), 'Green'),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTintOption(Color color, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _tintColor = color;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: _tintColor == color ? AppColors.primary : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: _isNightMode ? Colors.white : Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSettings() {
    if (isDesktopLayout) {
      setState(() => _showFontPanel = true);
    } else {
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Font Settings',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFontButton(1.0, 'Medium'),
                  _buildFontButton(1.2, 'Large'),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildFontButton(double size, String label) {
    bool isSelected = _fontSize == size;
    
    return InkWell(
      onTap: () {
        setState(() {
          _fontSize = size;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            color:
                isSelected ? Colors.white : (_isNightMode ? Colors.white : Colors.black),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayControls(double opacity) {
    return IgnorePointer(
      ignoring: opacity == 0.0,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.bookTitle,
                    style: GoogleFonts.urbanist(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: Colors.black,
                onPressed: () {
                  // Implement more options
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (_tapPosition == null || _lastTapTime == null || _isDragging) return;

    final currentTime = DateTime.now();
    final tapDuration = currentTime.difference(_lastTapTime!);
    
    // Only handle tap if it's a quick tap and not a drag
    if (tapDuration.inMilliseconds < 200) {
      _toggleControls();
    }
    
    _tapPosition = null;
    _lastTapTime = null;
  }

  // Add this method to find the first content page
  Future<int> _findFirstContentPage() async {
    int firstPage = 1;
    bool foundContent = false;

    while (!foundContent && firstPage <= _totalPages.value.toInt()) {
      final text = await _extractPageText(firstPage);
      if (text != null) {
        // Skip pages with very little text (likely cover, TOC, etc.)
        // and pages that mostly contain common front matter words
        if (text.length > 100 && !_isFrontMatter(text)) {
          foundContent = true;
          break;
        }
      }
      firstPage++;
    }

    return firstPage;
  }

  bool _isFrontMatter(String text) {
    final lowerText = text.toLowerCase();
    final frontMatterWords = [
      'contents',
      'copyright',
      'dedication',
      'acknowledgments',
      'preface',
      'introduction',
      'table of contents',
      'all rights reserved',
    ];

    int frontMatterCount = 0;
    for (final word in frontMatterWords) {
      if (lowerText.contains(word)) {
        frontMatterCount++;
      }
    }

    // If the page contains multiple front matter indicators, it's likely not content
    return frontMatterCount >= 2;
  }

  // Update the text extraction method
  Future<String?> _extractPageText(int pageNumber) async {
    try {
      final ByteData data = await rootBundle.load(widget.pdfPath);
      final bytes = data.buffer.asUint8List();
      final document = PdfDocument(inputBytes: bytes);

      final page = document.pages[pageNumber - 1];
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText(
        startPageIndex: pageNumber - 1,
        endPageIndex: pageNumber - 1,
      );

      // Clean up the text
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim(); // Remove extra whitespace
      text = text.replaceAll(RegExp(r'[^\x20-\x7E\n]'), ''); // Remove non-printable characters

      document.dispose();
      return text;
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return null;
    }
  }

  // Update the TTS play handler
  void _handleTTSPlay() async {
    try {
      if (_ttsManager.isPlaying) {
        _ttsManager.pause();
        setState(() {
          _isTTSPlaying = false;
        });
        return;
      }

      setState(() => _isTTSPlaying = true);

      int currentPageNumber = _currentPage.value.toInt();

      if (!_ttsManager.isInitialized) {
        currentPageNumber = await _findFirstContentPage();
        if (currentPageNumber != _currentPage.value.toInt()) {
          _pdfViewerController.jumpToPage(currentPageNumber);
        }
      }

      final text = await _extractPageText(currentPageNumber);
      if (text != null && text.isNotEmpty) {
        final charCount = text.length;
        final cost = (charCount / 100000) * 1.0;

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Starting TTS for page $currentPageNumber (Est. cost: \$${cost.toStringAsFixed(3)})',
              style: GoogleFonts.urbanist(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await _ttsManager.startReading(
          text: text,
          pageNumber: currentPageNumber,
          voiceId: ElevenLabsService.voiceIds['Rachel']!,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No readable text found on page $currentPageNumber',
              style: GoogleFonts.urbanist(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isTTSPlaying = false);
      }
    } catch (e) {
      debugPrint('Error in TTS: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error starting TTS: ${e.toString()}',
            style: GoogleFonts.urbanist(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isTTSPlaying = false);
    }
  }

  void _handleTTSSkipForward() {
    _ttsManager.skipForward();
  }

  void _handleTTSSkipBackward() {
    _ttsManager.skipBackward();
  }

  void _handleTTSNextPage() {
    if (_currentPage.value < _totalPages.value) {
      final nextPage = _currentPage.value.toInt() + 1;
      _pdfViewerController.jumpToPage(nextPage);
      _handleTTSPlay(); // Start playing the next page
    }
  }

  void _handleTTSPreviousPage() {
    if (_currentPage.value > 1) {
      final prevPage = _currentPage.value.toInt() - 1;
      _pdfViewerController.jumpToPage(prevPage);
      _handleTTSPlay(); // Start playing the previous page
    }
  }

  // Update the TTS controls UI
  Widget _buildTTSControls() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _showControls ? Offset.zero : const Offset(0, 1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isNightMode ? Colors.white24 : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous),
              color: _isNightMode ? Colors.white : Colors.black,
              onPressed: _handleTTSPreviousPage,
            ),
            IconButton(
              icon: const Icon(Icons.replay_10),
              color: _isNightMode ? Colors.white : Colors.black,
              onPressed: _handleTTSSkipBackward,
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: _isLoading && _isTTSPlaying
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      _isTTSPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: _handleTTSPlay,
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              color: _isNightMode ? Colors.white : Colors.black,
              onPressed: _handleTTSSkipForward,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              color: _isNightMode ? Colors.white : Colors.black,
              onPressed: _handleTTSNextPage,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTTS() {
    if (isDesktopLayout) {
      setState(() => _showTTSPanel = true);
    } else {
      setState(() {
        _showTTSControls = !_showTTSControls;
        if (!_showTTSControls) {
          _ttsManager.reset(); // Reset TTS when closing controls
        }
        _showControls = true; // Keep bottom controls visible
      });
      HapticFeedback.lightImpact();
    }
  }

  Widget NotesPanel({
    required String bookTitle,
    required int currentPage,
    required VoidCallback onClose,
  }) {
    final pageNotes = _notes.where((note) => note.pageNumber == currentPage).toList();
    
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Semi-transparent background
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // Floating Notes Cards
          if (pageNotes.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              height: 200,
              child: PageView.builder(
                controller: _noteCardController,
                itemCount: pageNotes.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final note = pageNotes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Transform.scale(
                      scale: 0.9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: note.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(
                                Icons.format_quote,
                                size: 100,
                                color: note.color.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: note.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Note ${index + 1}',
                                        style: GoogleFonts.urbanist(
                                          color: _isNightMode ? Colors.white70 : Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () {
                                          setState(() => _notes.remove(note));
                                          HapticFeedback.lightImpact();
                                        },
                                        color: Colors.red.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Text(
                                      note.content,
                                      style: GoogleFonts.urbanist(
                                        color: _isNightMode ? Colors.white : Colors.black,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Notes Input Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45, // Made panel taller
              decoration: BoxDecoration(
                color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView( // Wrap Column in SingleChildScrollView for safety
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Row(
                        children: [
                          Text(
                            'Add Note',
                            style: GoogleFonts.urbanist(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _isNightMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Page $currentPage',
                              style: GoogleFonts.urbanist(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                            color: _isNightMode ? Colors.white70 : Colors.black54,
                          ),
                        ],
                      ),
                    ),

                    // Note Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: (_isNightMode ? Colors.white12 : Colors.black.withOpacity(0.03)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _noteController,
                          maxLines: 3,
                          style: GoogleFonts.urbanist(
                            color: _isNightMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add a note for this page...',
                            hintStyle: GoogleFonts.urbanist(
                              color: (_isNightMode ? Colors.white60 : Colors.black45),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Color Picker
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          for (Color color in [
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.pink,
                            Colors.purple,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: InkWell(
                                onTap: () => setState(() => _noteColor = color),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(_noteColor == color ? 1 : 0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _noteColor == color 
                                          ? Colors.white 
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Save Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_noteController.text.isNotEmpty) {
                              setState(() {
                                _notes.add(Note(
                                  content: _noteController.text,
                                  pageNumber: currentPage,
                                  timestamp: DateTime.now(),
                                  color: _noteColor,
                                  highlight: _selectedHighlight,
                                ));
                                _noteController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save Note',
                            style: GoogleFonts.urbanist(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to handle highlighted text TTS
  void _handleHighlightedTextTTS(String selectedText) async {
    if (selectedText.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (_ttsManager.isPlaying) {
        _ttsManager.pause();
        setState(() {
          _isTTSPlaying = false;
          _isLoading = false;
        });
        return;
      }

      final charCount = selectedText.length;
      final cost = (charCount / 100000) * 1.0;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Starting TTS for selected text (Est. cost: \$${cost.toStringAsFixed(3)})',
            style: GoogleFonts.urbanist(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      await _ttsManager.startReading(
        text: selectedText,
        pageNumber: _currentPage.value.toInt(),
        voiceId: ElevenLabsService.voiceIds['Rachel']!,
      );

      if (!mounted) return;
      setState(() {
        _isTTSPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in TTS: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error starting TTS: ${e.toString()}',
            style: GoogleFonts.urbanist(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  // Add this method to handle text selection with debounce
  void _handleTextSelection(PdfTextSelectionChangedDetails details) {
    if (details.selectedText == null || details.selectedText!.isEmpty) {
      return;
    }

    // Delay showing our custom menu to prevent conflict with system menu
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          details.globalSelectedRegion!.topLeft,
          details.globalSelectedRegion!.bottomRight,
        ),
        Offset.zero & overlay.size,
      );

      showMenu(
        context: context,
        position: position,
        color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.95),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(
          minWidth: 150,
          maxWidth: 250,
        ),
        items: [
          PopupMenuItem(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Listen',
                  style: GoogleFonts.urbanist(
                    color: _isNightMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            onTap: () => Future(() => _handleHighlightedTextTTS(details.selectedText!)),
          ),
          PopupMenuItem(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.note_add,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Note',
                  style: GoogleFonts.urbanist(
                    color: _isNightMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            onTap: () => Future(() => setState(() {
                  _selectedHighlight = details.selectedText;
                  _showNotesPanel = true;
                })),
          ),
        ],
      );
    });
  }

  // Update the PDF viewer to use the new handler
  Widget _buildPdfViewer() {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.orange.withOpacity(0.3),
          selectionHandleColor: Colors.orange,
        ),
      ),
      child: SfPdfViewerTheme(
        data: SfPdfViewerThemeData(
          backgroundColor: _isNightMode ? Colors.black87 : Colors.white,
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _tintColor.withOpacity(0.1),
            BlendMode.srcATop,
          ),
          child: Transform.scale(
            scale: _fontSize,
            alignment: Alignment.topCenter,
            child: ScrollConfiguration(
              behavior: SmoothScrollBehavior(),
              child: SfPdfViewer.asset(
                widget.pdfPath,
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                enableTextSelection: true,
                onTextSelectionChanged: _handleTextSelection,
                scrollDirection: PdfScrollDirection.vertical,
                canShowScrollHead: false,
                pageSpacing: 8,
                pageLayoutMode: PdfPageLayoutMode.single,
                enableDoubleTapZooming: true,
                maxZoomLevel: 3,
                enableDocumentLinkAnnotation: true,
                interactionMode: PdfInteractionMode.selection,
                onDocumentLoaded: (details) {
                  _totalPages.value = details.document.pages.count.toDouble();
                  setState(() => _isLoading = false);
                },
                onPageChanged: (details) {
                  _currentPage.value = details.newPageNumber.toDouble();
                  if (_showControls) {
                    setState(() => _showControls = false);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.urbanist(
              color: _isNightMode ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: _isNightMode ? Brightness.light : Brightness.dark,
        systemNavigationBarIconBrightness: _isNightMode ? Brightness.light : Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          color: _isNightMode ? Colors.black : Colors.white,
          child: isDesktopLayout ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
            border: Border(
              right: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Column(
            children: [
              // Book Info Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    if (widget.coverImageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.coverImageUrl,
                          height: 180,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      widget.bookTitle,
                      style: GoogleFonts.urbanist(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isNightMode ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.authorName,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Quick Settings
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildDesktopQuickSetting(
                      icon: Icons.note_add,
                      label: 'Notes',
                      onTap: () => setState(() => _showNotesPanel = true),
                    ),
                    _buildDesktopQuickSetting(
                      icon: Icons.color_lens,
                      label: 'Page Tint',
                      onTap: _showColorPicker,
                    ),
                    _buildDesktopQuickSetting(
                      icon: Icons.text_fields,
                      label: 'Font',
                      onTap: _showFontSettings,
                    ),
                    _buildDesktopQuickSetting(
                      icon: Icons.record_voice_over,
                      label: 'Text to Speech',
                      onTap: _toggleTTS,
                    ),
                    _buildDesktopQuickSetting(
                      icon: _isNightMode ? Icons.wb_sunny : Icons.nights_stay,
                      label: _isNightMode ? 'Light Mode' : 'Dark Mode',
                      onTap: () => setState(() => _isNightMode = !_isNightMode),
                    ),
                  ],
                ),
              ),
              // Bottom Navigation
              Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                child: Column(
                  children: [
                    _buildPageSlider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (_currentPage.value > 1) {
                              _pdfViewerController.previousPage();
                            }
                          },
                          color: _isNightMode ? Colors.white70 : Colors.black54,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Page ${_currentPage.value.toInt()} of ${_totalPages.value.toInt()}',
                            style: GoogleFonts.urbanist(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            if (_currentPage.value < _totalPages.value) {
                              _pdfViewerController.nextPage();
                            }
                          },
                          color: _isNightMode ? Colors.white70 : Colors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // PDF Viewer with Notes and Tint Panel
        Expanded(
          child: Row(
            children: [
              // PDF Viewer
              Expanded(
                flex: (_showNotesPanel || _showTintPanel || _showTTSPanel || _showFontPanel) ? 3 : 1,
                child: Stack(
                  children: [
                    _buildPdfViewer(),
                    if (_isLoading)
                      _buildLoadingIndicator(),
                  ],
                ),
              ),
              // Desktop Notes Panel
              if (_showNotesPanel)
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                    border: Border(
                      left: BorderSide(
                        color: _isNightMode ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                  child: _buildDesktopNotesPanel(),
                ),
              // Desktop Tint Panel
              if (_showTintPanel)
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                    border: Border(
                      left: BorderSide(
                        color: _isNightMode ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                  child: _buildDesktopTintPanel(),
                ),
              // Desktop TTS Panel
              if (_showTTSPanel)
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                    border: Border(
                      left: BorderSide(
                        color: _isNightMode ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                  child: _buildDesktopTTSPanel(),
                ),
              // Desktop Font Panel
              if (_showFontPanel)
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                    border: Border(
                      left: BorderSide(
                        color: _isNightMode ? Colors.white24 : Colors.black12,
                      ),
                    ),
                  ),
                  child: _buildDesktopFontPanel(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopNotesPanel() {
    final currentPageNotes =
        _notes.where((note) => note.pageNumber == _currentPage.value.toInt()).toList();
    
    return Column(
      children: [
        // Notes Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
            border: Border(
              bottom: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notes',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showNotesPanel = false),
                color: _isNightMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
        
        // Notes List and Input
        Expanded(
          child: Column(
            children: [
              // Existing Notes
              Expanded(
                child: currentPageNotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 48,
                              color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notes for this page',
                              style: GoogleFonts.urbanist(
                                color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentPageNotes.length,
                        itemBuilder: (context, index) {
                          final note = currentPageNotes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: note.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: note.color.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: note.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Note ${index + 1}',
                                        style: GoogleFonts.urbanist(
                                          color: note.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${note.timestamp.hour}:${note.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: GoogleFonts.urbanist(
                                          color: (_isNightMode ? Colors.white : Colors.black)
                                              .withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20),
                                        onPressed: () {
                                          setState(() => _notes.remove(note));
                                          HapticFeedback.lightImpact();
                                        },
                                        color: Colors.red.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                                if (note.highlight != null)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: note.color.withOpacity(0.1),
                                      border: Border(
                                        top: BorderSide(
                                          color: note.color.withOpacity(0.3),
                                        ),
                                        bottom: BorderSide(
                                          color: note.color.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      note.highlight!,
                                      style: GoogleFonts.urbanist(
                                        color: (_isNightMode ? Colors.white : Colors.black)
                                            .withOpacity(0.7),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    note.content,
                                    style: GoogleFonts.urbanist(
                                      color: _isNightMode ? Colors.white : Colors.black,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              // Note Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
                  border: Border(
                    top: BorderSide(
                      color: _isNightMode ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Color Selection
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (Color color in [
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.pink,
                            Colors.purple,
                          ])
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _noteColor = color),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _noteColor == color ? color : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Note Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: (_isNightMode ? Colors.white12 : Colors.black.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: GoogleFonts.urbanist(
                          color: _isNightMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add a note...',
                          hintStyle: GoogleFonts.urbanist(
                            color: (_isNightMode ? Colors.white60 : Colors.black45),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_noteController.text.isNotEmpty) {
                            setState(() {
                              _notes.add(Note(
                                content: _noteController.text,
                                pageNumber: _currentPage.value.toInt(),
                                timestamp: DateTime.now(),
                                color: _noteColor,
                                highlight: _selectedHighlight,
                              ));
                              _noteController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Note',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTintPanel() {
    return Column(
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
            border: Border(
              bottom: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page Tint',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showTintPanel = false),
                color: _isNightMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),

        // Tint Options
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Predefined Tints
              Text(
                'Predefined Tints',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _predefinedTints.map((tint) {
                  final bool isSelected = _tintColor == tint['color'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _tintColor = tint['color'] as Color;
                      });
                    },
            child: Column(
              children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: tint['color'] as Color,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tint['name'] as String,
                          style: GoogleFonts.urbanist(
                            color: _isNightMode ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Custom Tint Opacity
              Text(
                'Tint Opacity',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.1),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _tintColor.opacity,
                  min: 0.0,
                  max: 0.3,
                  onChanged: (value) {
                    setState(() {
                      _tintColor = _tintColor.withOpacity(value);
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _tintColor = Colors.transparent;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reset Tint',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTTSPanel() {
    return Column(
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
            border: Border(
              bottom: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Text to Speech',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showTTSPanel = false),
                color: _isNightMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),

        // TTS Controls
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Play Controls
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (_isNightMode ? Colors.white12 : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: _handleTTSPreviousPage,
                      color: _isNightMode ? Colors.white70 : Colors.black54,
                      iconSize: 32,
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: _handleTTSSkipBackward,
                      color: _isNightMode ? Colors.white70 : Colors.black54,
                      iconSize: 32,
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading && _isTTSPlaying
                          ? Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _isTTSPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              onPressed: _handleTTSPlay,
                              color: Colors.white,
                            ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: _handleTTSSkipForward,
                      color: _isNightMode ? Colors.white70 : Colors.black54,
                      iconSize: 32,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: _handleTTSNextPage,
                      color: _isNightMode ? Colors.white70 : Colors.black54,
                      iconSize: 32,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Voice Selection
              Text(
                'ElevenLabs Voice',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose from premium AI voices',
                style: GoogleFonts.urbanist(
                  color: _isNightMode ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ElevenLabsService.voiceIds.entries.map((entry) {
                  final bool isSelected = _selectedVoice == entry.key;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedVoice = entry.key);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (_isNightMode ? Colors.white24 : Colors.black12),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 20,
                            color: isSelected ? AppColors.primary : (_isNightMode ? Colors.white70 : Colors.black54),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: GoogleFonts.urbanist(
                              color: isSelected ? AppColors.primary : (_isNightMode ? Colors.white : Colors.black),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Auto-scroll Toggle
              SwitchListTile(
                title: Text(
                  'Auto-scroll Pages',
                  style: GoogleFonts.urbanist(
                    color: _isNightMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Automatically move to the next page while reading',
                  style: GoogleFonts.urbanist(
                    color: (_isNightMode ? Colors.white60 : Colors.black45),
                    fontSize: 14,
                  ),
                ),
                value: _isAutoScroll,
                onChanged: (value) {
                  setState(() => _isAutoScroll = value);
                },
                activeColor: AppColors.primary,
              ),

              const SizedBox(height: 32),

              // Cost Estimation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ElevenLabs API Usage',
                          style: GoogleFonts.urbanist(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cost is approximately \$0.01 per 1,000 characters. The actual cost may vary based on the selected voice and text length.',
                      style: GoogleFonts.urbanist(
                        color: _isNightMode ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedVoice = 'Rachel';
                      _isAutoScroll = false;
                      _ttsManager.reset();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reset TTS Settings',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFontPanel() {
    return Column(
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.98),
            border: Border(
              bottom: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Settings',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showFontPanel = false),
                color: _isNightMode ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),

        // Font Options
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Font Size
              Text(
                'Font Size',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_fontSize > 0.8) {
                        setState(() => _fontSize -= 0.1);
                      }
                    },
                    color: _isNightMode ? Colors.white70 : Colors.black54,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.1),
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _fontSize,
                        min: 0.8,
                        max: 2.0,
                        onChanged: (value) {
                          setState(() => _fontSize = value);
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_fontSize < 2.0) {
                        setState(() => _fontSize += 0.1);
                      }
                    },
                    color: _isNightMode ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
              Text(
                'Preview Size: ${(_fontSize * 100).toInt()}%',
                style: GoogleFonts.urbanist(
                  color: _isNightMode ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Font Family
              Text(
                'Font Family',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableFonts.map((font) {
                  final bool isSelected = _selectedFont == font;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedFont = font);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (_isNightMode ? Colors.white24 : Colors.black12),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Aa',
                        style: GoogleFonts.getFont(
                          font,
                          color: isSelected ? AppColors.primary : (_isNightMode ? Colors.white : Colors.black),
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Line Height
              Text(
                'Line Height',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.1),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _lineHeight,
                  min: 1.0,
                  max: 2.0,
                  onChanged: (value) {
                    setState(() => _lineHeight = value);
                  },
                ),
              ),
              Text(
                'Line Height: ${_lineHeight.toStringAsFixed(1)}',
                style: GoogleFonts.urbanist(
                  color: _isNightMode ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Letter Spacing
              Text(
                'Letter Spacing',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.1),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _letterSpacing,
                  min: -1.0,
                  max: 3.0,
                  onChanged: (value) {
                    setState(() => _letterSpacing = value);
                  },
                ),
              ),
              Text(
                'Letter Spacing: ${_letterSpacing.toStringAsFixed(1)}',
                style: GoogleFonts.urbanist(
                  color: _isNightMode ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fontSize = 1.0;
                      _selectedFont = 'Urbanist';
                      _lineHeight = 1.5;
                      _letterSpacing = 0.0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reset Font Settings',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopQuickSetting({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: _isNightMode ? Colors.white70 : Colors.black54,
      ),
      title: Text(
        label,
        style: GoogleFonts.urbanist(
          color: _isNightMode ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildPdfViewer(),
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleControls,
            behavior: HitTestBehavior.translucent,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: _showControls ? Offset.zero : const Offset(0, -1),
            child: _buildTopBar(),
          ),
        ),
        if (_showTTSControls)
          Positioned(
            bottom: _showControls 
              ? MediaQuery.of(context).padding.bottom + 160
              : MediaQuery.of(context).padding.bottom + 100,
            left: 16,
            right: 16,
            child: _buildTTSControls(),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: _showControls ? Offset.zero : const Offset(0, 1),
            child: _buildBottomControls(),
          ),
        ),
        if (_showNotesPanel)
          NotesPanel(
            bookTitle: widget.bookTitle,
            currentPage: _currentPage.value.toInt(),
            onClose: () => setState(() => _showNotesPanel = false),
          ),
        if (_isLoading) _buildLoadingIndicator(),
      ],
    );
  }

  Widget _buildTopBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 100 + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: _isNightMode ? Colors.white : Colors.black,
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.bookTitle,
                      style: GoogleFonts.urbanist(
                        color: _isNightMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.authorName,
                      style: GoogleFonts.urbanist(
                        color: (_isNightMode ? Colors.white : Colors.black).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isNightMode ? Icons.wb_sunny : Icons.nights_stay),
                color: _isNightMode ? Colors.white : Colors.black,
                onPressed: () => setState(() => _isNightMode = !_isNightMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomPadding),
          decoration: BoxDecoration(
            color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: _isNightMode ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildPageSlider(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickSettingButton(
                      icon: Icons.note_add,
                      label: 'Notes',
                      onTap: () => setState(() => _showNotesPanel = true),
                    ),
                    _buildQuickSettingButton(
                      icon: Icons.color_lens,
                      label: 'Tint',
                      onTap: () => _showColorPicker(),
                    ),
                    _buildQuickSettingButton(
                      icon: Icons.text_fields,
                      label: 'Font',
                      onTap: () => _showFontSettings(),
                    ),
                    _buildQuickSettingButton(
                      icon: Icons.record_voice_over,
                      label: 'Listen',
                      onTap: _toggleTTS,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageNumber(ValueNotifier<double> valueNotifier) {
    return ValueListenableBuilder<double>(
      valueListenable: valueNotifier,
      builder: (context, value, _) {
        return Text(
          '${value.toInt()}',
          style: GoogleFonts.urbanist(
            color: _isNightMode ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildQuickSettingButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.urbanist(
            color: _isNightMode ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Visibility(
      visible: _isLoading && !_isTTSPlaying,
      child: Container(
        color: (_isNightMode ? Colors.black : Colors.white).withOpacity(0.9),
        child: Center(
          child: SizedBox(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/book_loading.json',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Text(
                    'Loading Book...',
                    style: GoogleFonts.urbanist(
                      color: Colors.black45,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPageNumber(_currentPage),
          ),
          Expanded(
            child: _totalPages.value > 0
                ? SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor:
                          (_isNightMode ? Colors.white : Colors.black).withOpacity(0.1),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _currentPage.value,
                      min: 1,
                      max: _totalPages.value,
                      onChanged: (value) {
                        _currentPage.value = value;
                        _pdfViewerController.jumpToPage(value.toInt());
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildPageNumber(_totalPages),
          ),
        ],
      ),
    );
  }
}

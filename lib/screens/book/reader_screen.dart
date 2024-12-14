import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../../utils/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _autoHideControls();
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        _hideControls();
      }
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _fadeController.dispose();
    _currentPage.dispose();
    _totalPages.dispose();
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

  void _showControlsTemporarily() {
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      _fadeController.reverse();
      _autoHideControls();
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
      }
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    HapticFeedback.lightImpact();
  }

  void _showTextSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Settings',
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTextSizeButton(0.8, 'A-'),
                _buildTextSizeButton(1.0, 'A'),
                _buildTextSizeButton(1.2, 'A+'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeButton(double scale, String label) {
    return ElevatedButton(
      onPressed: () {
        // Implement text size change if needed
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.urbanist(
          fontSize: 16 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
      child: Stack(
        children: [
          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.font_download_outlined),
                    color: Colors.white,
                    onPressed: _showTextSettings,
                  ),
                ],
              ),
            ),
          ),

          // Right side actions
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildActionButton(
                  icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Bookmark',
                  color: _isBookmarked ? AppColors.primary : Colors.white,
                  onTap: _toggleBookmark,
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  icon: Icons.text_fields_rounded,
                  label: 'Font',
                  onTap: _showTextSettings,
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  icon: Icons.format_list_bulleted,
                  label: 'Chapters',
                  onTap: () {
                    // Implement chapters list functionality
                  },
                ),
                const SizedBox(height: 24),
                _buildActionButton(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () {
                    // Implement search functionality
                  },
                ),
              ],
            ),
          ),

          // Bottom info
          Positioned(
            left: 16,
            right: 72,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bookTitle,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.authorName,
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: _currentPage,
                  builder: (context, page, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _totalPages,
                      builder: (context, total, __) {
                        return Text(
                          'Page ${page.toInt()} of ${total.toInt()}',
                          style: GoogleFonts.urbanist(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double overlayOpacity = _showControls ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Wrap SfPdfViewer with SfPdfViewerTheme to change page background
          SfPdfViewerTheme(
            data: SfPdfViewerThemeData(
              // Change pageBackgroundColor to backgroundColor
              backgroundColor: Colors.white,
            ),
            child: Container(
              color: Colors.white,
              child: GestureDetector(
                onTap: _toggleControls,
                child: SfPdfViewer.asset(
                  widget.pdfPath,
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  pageSpacing: 0,
                  scrollDirection: PdfScrollDirection.vertical,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  onPageChanged: (details) {
                    _currentPage.value = details.newPageNumber.toDouble();
                  },
                  onDocumentLoaded: (details) {
                    _totalPages.value = details.document.pages.count.toDouble();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  enableDoubleTapZooming: true,
                ),
              ),
            ),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: overlayOpacity,
            curve: Curves.easeOut,
            child: _buildOverlayControls(overlayOpacity),
          ),
        ],
      ),
    );
  }
}

import 'package:ebook_app/screens/book/reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side - Book Cover and Actions
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBookCover(isDesktop: true),
                          const SizedBox(height: 32),
                          _buildActionButtons(isDesktop: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Book Details
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(48),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookInfo(isDesktop: true),
                  const SizedBox(height: 32),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildBookDetails(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          expandedHeight: 400,
          leading: _buildBackButton(),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                color: isFavorite ? AppColors.primary : Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87),
              onPressed: () {
                // Implement share functionality
              },
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildBookCover(isDesktop: false),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookInfo(isDesktop: false),
                const SizedBox(height: 24),
                _buildActionButtons(isDesktop: false),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                _buildBookDetails(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildBookCover({required bool isDesktop}) {
    return Container(
      width: isDesktop ? 300 : double.infinity,
      height: isDesktop ? 450 : 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(widget.book['imageUrl'] ?? ''),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {},
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: widget.book['imageUrl'] == null
          ? Icon(
              Icons.book,
              size: isDesktop ? 80 : 60,
              color: Colors.grey[400],
            )
          : null,
    );
  }

  Widget _buildBookInfo({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.book['title'] ?? 'Book Title',
          style: GoogleFonts.urbanist(
            fontSize: isDesktop ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.book['author'] ?? 'Author Name',
          style: GoogleFonts.urbanist(
            fontSize: isDesktop ? 20 : 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.book['rating'] ?? '0.0'}',
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.book['reviewCount'] ?? '0'} Reviews',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPreviewDialog(bool isDesktop) {
    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: _buildPreviewContent(isDesktop: true),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: _buildPreviewContent(isDesktop: false),
        ),
      );
    }
  }

  Widget _buildPreviewContent({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Book Preview',
              style: GoogleFonts.urbanist(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Preview chapters list
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewChapter(
                  title: 'Chapter 1: The Beginning',
                  preview: true,
                  isDesktop: isDesktop,
                ),
                _buildPreviewChapter(
                  title: 'Chapter 2: The Journey',
                  preview: true,
                  isDesktop: isDesktop,
                ),
                _buildPreviewChapter(
                  title: 'Chapter 3: The Discovery',
                  preview: false,
                  isDesktop: isDesktop,
                ),
                _buildPreviewChapter(
                  title: 'Chapter 4: The Challenge',
                  preview: false,
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Implement purchase functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 20 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Get Full Access',
            style: GoogleFonts.urbanist(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewChapter({
    required String title,
    required bool preview,
    required bool isDesktop,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: preview ? AppColors.primaryLight : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: preview ? AppColors.primary.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: preview ? AppColors.primary : Colors.black54,
                  ),
                ),
                if (preview) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Preview Available',
                    style: GoogleFonts.urbanist(
                      fontSize: isDesktop ? 14 : 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            preview ? Icons.visibility : Icons.lock_outline,
            color: preview ? AppColors.primary : Colors.grey,
            size: isDesktop ? 24 : 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({required bool isDesktop}) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => ReaderScreen(
                   pdfPath: 'assets/books/atomic_habits.pdf', // Local path or URL
                   bookTitle: 'Book Title',
                   authorName: 'F. Scott Fitzgerald',
                   coverImageUrl: 'https://example.com/book_cover.jpg', // Optional

                 ),
               ),
             );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                vertical: isDesktop ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Read Now',
              style: GoogleFonts.urbanist(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => _showPreviewDialog(isDesktop),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 20 : 16,
              horizontal: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: AppColors.primary),
          ),
          icon: Icon(
            Icons.visibility_outlined,
            size: isDesktop ? 24 : 20,
            color: AppColors.primary,
          ),
          label: Text(
            'Preview',
            style: GoogleFonts.urbanist(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.book['description'] ?? 'No description available.',
          style: GoogleFonts.urbanist(
            fontSize: 16,
            color: Colors.black54,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBookDetails() {
    final details = [
      {
        'title': 'Publisher',
        'value': widget.book['publisher'] ?? 'Unknown',
      },
      {
        'title': 'Language',
        'value': widget.book['language'] ?? 'Unknown',
      },
      {
        'title': 'Pages',
        'value': widget.book['pages']?.toString() ?? 'Unknown',
      },
      {
        'title': 'Release Date',
        'value': widget.book['releaseDate'] ?? 'Unknown',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Details',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: details.map((detail) {
            return SizedBox(
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail['title']!,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail['value']!,
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
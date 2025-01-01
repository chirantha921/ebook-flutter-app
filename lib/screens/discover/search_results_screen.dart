import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultsScreen({Key? key, required this.searchQuery})
      : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool isGridView = true;

  // Sample data representing search results
  // Replace this with your actual search result data
  final List<Map<String, dynamic>> books = [
    {
      "title": "Harry Potter and the Deathly Hallows: Book 7",
      "imageUrl": "https://example.com/hp_deathly_hallows.jpg",
      "rating": 4.9,
      "price": 9.99,
      "genres": ["Fantasy", "Fiction", "Mystery"],
    },
    {
      "title": "Harry Potter and the Half-Blood Prince: Book 6",
      "imageUrl": "https://example.com/hp_half_blood_prince.jpg",
      "rating": 4.8,
      "price": 9.99,
      "genres": ["Fantasy", "Fiction", "Mystery"],
    },
    {
      "title": "Harry Potter and the Order of the Phoenix: Book 5",
      "imageUrl": "https://example.com/hp_order_phoenix.jpg",
      "rating": 4.9,
      "price": 9.99,
      "genres": ["Fantasy", "Fiction", "Mystery"],
    },
    {
      "title": "Harry Potter and the Goblet of Fire: Book 4",
      "imageUrl": "https://example.com/hp_goblet_fire.jpg",
      "rating": 4.7,
      "price": 8.99,
      "genres": ["Fantasy", "Fiction", "Mystery"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(isDesktop),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : 16.0,
          vertical: isDesktop ? 24.0 : 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Show in',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildViewToggleButton(
                  icon: Icons.grid_view,
                  selected: isGridView,
                  onTap: () => setState(() => isGridView = true),
                ),
                const SizedBox(width: 8),
                _buildViewToggleButton(
                  icon: Icons.view_list_rounded,
                  selected: !isGridView,
                  onTap: () => setState(() => isGridView = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isGridView ? _buildGridView(isDesktop) : _buildListView(isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDesktop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        color: Colors.black87,
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      centerTitle: false,
      title: _buildSearchField(isDesktop),
    );
  }

  Widget _buildSearchField(bool isDesktop) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(right: isDesktop ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.searchQuery,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () {
              // Clear the search query or navigate back to search screen
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: selected ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGridView(bool isDesktop) {
    final crossAxisCount = isDesktop ? 4 : 2;
    final spacing = isDesktop ? 24.0 : 16.0;

    return GridView.builder(
      itemCount: books.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildGridItem(
          title: book["title"],
          imageUrl: book["imageUrl"],
          rating: book["rating"],
          price: book["price"],
        );
      },
    );
  }

  Widget _buildGridItem({
    required String title,
    required String imageUrl,
    required double rating,
    required double price,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(color: Colors.grey.shade200),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Title
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.urbanist(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        // Rating & Price
        Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.urbanist(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              price > 0 ? "\$${price.toStringAsFixed(2)}" : "Free",
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(bool isDesktop) {
    return ListView.separated(
      itemCount: books.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildListItem(
          title: book["title"],
          imageUrl: book["imageUrl"],
          rating: book["rating"],
          price: book["price"],
          genres: List<String>.from(book["genres"]),
          isDesktop: isDesktop,
        );
      },
    );
  }

  Widget _buildListItem({
    required String title,
    required String imageUrl,
    required double rating,
    required double price,
    required List<String> genres,
    required bool isDesktop,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book cover
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: isDesktop ? 120 : 80,
            height: isDesktop ? 180 : 120,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              width: isDesktop ? 120 : 80,
              height: isDesktop ? 180 : 120,
              color: Colors.grey.shade200,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Book details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              // Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                price > 0 ? "\$${price.toStringAsFixed(2)}" : "Free",
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Genres (Chips)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      genre,
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

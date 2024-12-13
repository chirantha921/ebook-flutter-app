import 'package:ebook_app/screens/discover/search_results_screen.dart';
import 'package:ebook_app/screens/discover/search_screen.dart';
import 'package:ebook_app/screens/home/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart';
// Import the screens you want to navigate to
import '../home/genre_book_list_screen.dart'; 

// Sample data for books
final topCharts = [
  {
    "title": "Harry Potter and the Deathly Hallows",
    "imageUrl": "https://example.com/hp_deathly_hallows.jpg",
    "rating": 4.7,
    "price": 9.99,
  },
  {
    "title": "A Court of Thorns & Roses Book 1",
    "imageUrl": "https://example.com/acotar.jpg",
    "rating": 4.6,
    "price": 6.50,
  },
];

final topSelling = [
  {
    "title": "The Batman Who Laughs: Issues 1-7",
    "imageUrl": "https://example.com/batman.jpg",
    "rating": 4.3,
    "price": 10.44,
  },
  {
    "title": "Game of Thrones: A Song of Ice & Fire",
    "imageUrl": "https://example.com/got.jpg",
    "rating": 4.4,
    "price": 7.99,
  },
  {
    "title": "The Lord of the Rings",
    "imageUrl": "https://example.com/lotr.jpg",
    "rating": 4.8,
    "price": 12.99,
  },
];

final topFree = [
  {
    "title": "Alpha Magic: Reverse Harem Paranormal Romance",
    "imageUrl": "https://example.com/alpha_magic.jpg",
    "rating": 4.4,
    "price": 0.0,
  },
  {
    "title": "Taken by the Dragon King: Dragon Shifter",
    "imageUrl": "https://example.com/dragon_king.jpg",
    "rating": 4.6,
    "price": 0.0,
  },
  {
    "title": "Late Night Stories",
    "imageUrl": "https://example.com/late_night.jpg",
    "rating": 4.2,
    "price": 0.0,
  },
];

final topNewReleases = [
  {
    "title": "Song of Silver, Flame Like Night",
    "imageUrl": "https://example.com/song_of_silver.jpg",
    "rating": 4.8,
    "price": 10.99,
  },
  {
    "title": "Son of the Poison Rose: A Kagen Novel",
    "imageUrl": "https://example.com/son_of_poison_rose.jpg",
    "rating": 4.5,
    "price": 8.50,
  },
  {
    "title": "Last Sunrise in Eterna",
    "imageUrl": "https://example.com/last_sunrise.jpg",
    "rating": 4.1,
    "price": 9.50,
  },
];

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  void _onViewAllTopCharts(BuildContext context) {
    // Navigate to a SearchResultsScreen for 'Harry Potter' or a GenreBookListScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchResultsScreen(searchQuery: 'Harry Potter')),
    );
  }

  void _onViewAllTopSelling(BuildContext context) {
    // Navigate to a genre-based list. Adjust as needed.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GenreBookListScreen(genre: 'Bestsellers')),
    );
  }

  void _onViewAllTopFree(BuildContext context) {
    // Another example of navigation, maybe to SearchResultsScreen with 'Free Books'
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchResultsScreen(searchQuery: 'Free Books')),
    );
  }

  void _onViewAllNewReleases(BuildContext context) {
    // Navigate to GenreBookListScreen or SearchResultsScreen for 'New Releases'
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GenreBookListScreen(genre: 'New Releases')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: isDesktop ? 80 : null,
        leading: Padding(
          padding: EdgeInsets.only(left: isDesktop ? 24.0 : 16.0),
          child: Icon(Icons.menu_book, color: AppColors.primary, size: 28),
        ),
        titleSpacing: 0,
        title: Text(
          "Discover",
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Navigate to SearchScreen or directly to SearchResultsScreen with a default query
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // Navigate to NotificationScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          SizedBox(width: isDesktop ? 24 : 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : 16.0,
          vertical: isDesktop ? 24.0 : 16.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                title: "Top Charts",
                books: topCharts,
                onViewAll: () => _onViewAllTopCharts(context),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "Top Selling",
                books: topSelling,
                onViewAll: () => _onViewAllTopSelling(context),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "Top Free",
                books: topFree,
                onViewAll: () => _onViewAllTopFree(context),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: "Top New Releases",
                books: topNewReleases,
                onViewAll: () => _onViewAllNewReleases(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> books,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, onViewAll: onViewAll),
        const SizedBox(height: 12),
        SizedBox(
          height: 260, // Height of each book card section
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return _buildBookCard(
                context,
                title: book["title"],
                imageUrl: book["imageUrl"],
                rating: book["rating"],
                price: book["price"],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Add a "View All" text if you prefer:
                // Text("View All",
                //   style: GoogleFonts.urbanist(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //     color: AppColors.primary,
                //   ),
                // ),
                // SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required double rating,
    required double price,
  }) {
    return SizedBox(
      width: 120,
      child: GestureDetector(
        onTap: () {
          // Implement navigation on book tap (e.g. BookDetailsScreen)
          // Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailsScreen(...)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 180,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 180,
                  width: 120,
                  color: Colors.grey.shade200,
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
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: GoogleFonts.urbanist(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                if (price > 0)
                  Text(
                    "\$${price.toStringAsFixed(2)}",
                    style: GoogleFonts.urbanist(fontSize: 12, color: Colors.black87),
                  )
                else
                  Text(
                    "Free",
                    style: GoogleFonts.urbanist(fontSize: 12, color: Colors.black87),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

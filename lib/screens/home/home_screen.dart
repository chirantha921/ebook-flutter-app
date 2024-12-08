import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart'; // Ensure AppColors and other utilities are accessible

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For bottom navigation

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Implement navigation logic for each bottom nav item if needed
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 24,
      title: Text(
        "Erabook",
        style: GoogleFonts.urbanist(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () {
            // TODO: Implement search navigation
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black87),
          onPressed: () {
            // TODO: Implement notifications navigation
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Recommended For You"),
          const SizedBox(height: 8),
          _buildHorizontalBookList(recommendedBooks),

          const SizedBox(height: 24),
          _buildSectionTitle("Explore by Genre"),
          const SizedBox(height: 8),
          _buildHorizontalGenreList(genres),

          const SizedBox(height: 24),
          _buildSectionTitle("On Your Purchased"),
          const SizedBox(height: 8),
          _buildHorizontalBookList(purchasedBooks),

          const SizedBox(height: 24),
          _buildSectionTitle("On Your Wishlist"),
          const SizedBox(height: 8),
          _buildHorizontalBookList(wishlistBooks),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    // For desktop, let's arrange the layout into two columns:
    // Left column: Recommended For You, Explore by Genre
    // Right column: On Your Purchased, On Your Wishlist
    // We'll display books in a grid instead of horizontal lists and genres in a wrap.

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Recommended For You"),
                  const SizedBox(height: 8),
                  _buildGridBookList(recommendedBooks),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Explore by Genre"),
                  const SizedBox(height: 8),
                  _buildWrapGenreList(genres),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("On Your Purchased"),
                  const SizedBox(height: 8),
                  _buildGridBookList(purchasedBooks),
                  const SizedBox(height: 24),
                  _buildSectionTitle("On Your Wishlist"),
                  const SizedBox(height: 8),
                  _buildGridBookList(wishlistBooks),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Navigate to full list
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: Text(
            "→",
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  /// MOBILE Horizontal Lists
  Widget _buildHorizontalBookList(List<Book> books) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 24),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookCard(book, width: 140);
        },
      ),
    );
  }

  Widget _buildHorizontalGenreList(List<Genre> genres) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 24),
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final genre = genres[index];
          return _buildGenreChip(genre);
        },
      ),
    );
  }

  /// DESKTOP Grid Lists
  Widget _buildGridBookList(List<Book> books) {
    // For desktop, let's display books in a responsive grid (e.g., 3 columns).
    // Adjust crossAxisCount as needed.
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 250, // Control height of each item (book cover + text)
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(book, width: 140);
      },
    );
  }

  Widget _buildWrapGenreList(List<Genre> genres) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: genres.map((genre) => _buildGenreChip(genre)).toList(),
      ),
    );
  }

  Widget _buildBookCard(Book book, {double width = 140}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              book.coverUrl,
              width: width,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              color: Colors.black54,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(Genre genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        genre.name,
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.travel_explore_rounded),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Purchased',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Account',
        ),
      ],
    );
  }
}

// Dummy data classes and sample data
class Book {
  final String title;
  final String subtitle;
  final String coverUrl;
  Book({required this.title, required this.subtitle, required this.coverUrl});
}

class Genre {
  final String name;
  Genre(this.name);
}

// Sample data
final recommendedBooks = [
  Book(
    title: "The House of Hades\n(Heroes of Olympus ...)",
    subtitle: "4.6  \$7.50",
    coverUrl: 'assets/images/book1.jpg',
  ),
  Book(
    title: "My Quiet Blacksmith Life\nin Another World...",
    subtitle: "4.7  \$6.99",
    coverUrl: 'assets/images/book2.jpg',
  ),
  // Add more books as needed
];

final genres = [
  Genre("Romance"),
  Genre("Thriller"),
  Genre("Inspiration"),
  Genre("Sci-Fi"),
  // Add more genres as needed
];

final purchasedBooks = [
  Book(
    title: "Batman: Arkham\nUnhinged Vol. 1",
    subtitle: "4.3  Purchased",
    coverUrl: 'assets/images/book3.jpg',
  ),
  Book(
    title: "His Dark Materials:\nThe Golden Compass",
    subtitle: "4.4  Purchased",
    coverUrl: 'assets/images/book4.jpg',
  ),
  // Add more purchased books as needed
];

final wishlistBooks = [
  Book(
    title: "Fairy Tale",
    subtitle: "4.9  \$8.99",
    coverUrl: 'assets/images/book5.jpg',
  ),
  Book(
    title: "The Lost Metal",
    subtitle: "4.7  \$9.99",
    coverUrl: 'assets/images/book6.jpg',
  ),
  // Add more wishlist books as needed
];

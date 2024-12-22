import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your custom bottom navigation bar widget
import '../../widgets/custom_bottom_navigation_bar.dart';

// Import your additional screens
import '../discover/discover_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../purchased/purchased_screen.dart';
import '../account/profile_screen.dart';

// Existing imports from original code
import '../../models/book.dart';
import '../../utils/constants.dart';
import 'notification_screen.dart';
import 'explore_genre_screen.dart';
import 'genre_book_list_screen.dart';
import '../book/book_details_screen.dart';

// Sample Genre class and data from the original code
class Genre {
  final String name;
  final List<Color> gradientColors;
  Genre(this.name, this.gradientColors);
}

final genres = [
  Genre("Fantasy", [Colors.purple, Colors.deepPurple]),
  Genre("Science Fiction", [Colors.blue, Colors.indigo]),
  Genre("Mystery", [Colors.green, Colors.teal]),
  Genre("Romance", [Colors.pink, Colors.redAccent]),
];

// Update the sample book data - remove prices
final recommendedBooks = <Book>[
  Book(title: "Fairy Tale", rating: 4.9),
  Book(title: "The Lost Metal", rating: 4.7),
  Book(title: "The Way of Kings", rating: 4.8),
];

final purchasedBooks = <Book>[
  Book(title: "Project Hail Mary", rating: 4.5),
  Book(title: "Dune", rating: 4.6),
];

final wishlistBooks = <Book>[
  Book(title: "The Name of the Wind", rating: 4.7),
  Book(title: "Leviathan Wakes", rating: 4.5),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Main HomeScreen state that manages bottom navigation and desktop layout
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of pages for each bottom navigation index
  final List<Widget> _pages = [
    const HomeContent(),         // index 0: Main home content
    const ExploreGenreScreen(), // index 1: Explore - Changed from DiscoverScreen
    const WishlistScreen(),      // index 2: Wishlist
    const PurchasedScreen(),     // index 3: Cart / Purchased
    const AccountScreen(),       // index 4: Profile
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  @override
  void initState() {
    super.initState();
    // Set up transparent navigation bar
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
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopView = isDesktop(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        extendBody: true, // Important for transparent navigation bar
        body: Row(
          children: [
            if (isDesktopView) _buildDesktopSidebar(),
            Expanded(
              // Show the selected page using IndexedStack
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            if (isDesktopView) _buildDesktopRightPanel(),
          ],
        ),
        bottomNavigationBar: !isDesktopView
            ? CustomBottomNavigationBar(
                selectedIndex: _selectedIndex,
                onTap: _onBottomNavTapped,
              )
            : null,
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFFFF7E21), size: 32),
                const SizedBox(width: 12),
                Text(
                  "Erabook",
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          _buildDesktopNavItem(Icons.home_rounded, "Home", 0),
          _buildDesktopNavItem(Icons.explore_outlined, "Explore", 1), // Remove onTap parameter
          _buildDesktopNavItem(Icons.bookmark_border_rounded, "Bookmarks", 2),
          _buildDesktopNavItem(Icons.person_outline_rounded, "Profile", 4),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildUpgradeToPremium(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem(IconData icon, String label, int index, {VoidCallback? onTap}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ?? () => _onBottomNavTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7E21).withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFFF7E21) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF7E21) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFF7E21) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRightPanel() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reading Progress",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildReadingProgressCard(),
          const SizedBox(height: 24),
          Text(
            "Recent Activity",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildReadingProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "The House of Hades",
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Chapter 7 of 32",
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.22,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7E21)),
          ),
          const SizedBox(height: 8),
          Text(
            "22% Completed",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.book, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You finished Chapter 6",
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "2 hours ago",
                      style: GoogleFonts.urbanist(
                        fontSize: 12,
                                                color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeToPremium() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            "Upgrade to Premium",
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Get unlimited access to all books",
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// The main home content extracted from original code.
// Displays recommended books, genres, purchased, and wishlist sections.
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopView = isDesktop(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // No additional scroll logic needed, but this is where you'd handle it if required
        return false;
      },
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDesktopView, context),
          SliverPadding(
            padding: EdgeInsets.all(isDesktopView ? 24.0 : 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildBookSection(
                  context,
                  "Recommended",
                  recommendedBooks,
                  showRating: true,
                  isDesktopView: isDesktopView,
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const GenreBookListScreen(genre: 'Romance'),
                        ),
                      );
                    },
                ),
                SizedBox(height: isDesktopView ? 32 : 24),
                _buildGenreSection(context, isDesktopView),
                SizedBox(height: isDesktopView ? 32 : 24),
                _buildBookSection(
                  context,
                  "On Your Purchased",
                  purchasedBooks,
                  showPurchased: true,
                  showRating: true,
                  isDesktopView: isDesktopView,
                ),
                SizedBox(height: isDesktopView ? 32 : 24),
                _buildBookSection(
                  context,
                  "On Your Wishlist",
                  wishlistBooks,
                  showRating: true,
                  isDesktopView: isDesktopView,
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(bool isDesktopView, BuildContext context) {
    if (isDesktopView) {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        flexibleSpace: Container(
          color: Colors.white,
        ),
        title: Container(
          width: 400,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search for books, authors...",
              hintStyle: GoogleFonts.urbanist(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person_outline, color: Colors.grey),
            ),
          ),
        ],
      );
    } else {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: Container(
          color: Colors.white,
        ),
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: Color(0xFFFF7E21), size: 28),
            const SizedBox(width: 8),
            Text(
              "Erabook",
              style: GoogleFonts.urbanist(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // Update index to show explore screen instead of navigation
              if (context.findAncestorStateOfType<_HomeScreenState>() != null) {
                context.findAncestorStateOfType<_HomeScreenState>()!
                    ._onBottomNavTapped(1); // Switch to explore tab
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View All",
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF7E21),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFFF7E21),
                    size: 20,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookSection(
    BuildContext context,
    String title,
    List<Book> books, {
    bool showRating = false,
    bool showPurchased = false,
    bool isDesktopView = false,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, onViewAll: onViewAll),
        SizedBox(
          height: isDesktopView ? 300 : 260, // Height of each book card section
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (context, index) => SizedBox(width: isDesktopView ? 24 : 16),
            itemBuilder: (context, index) {
              return _buildBookCard(
                context,
                books[index],
                showRating: showRating,
                showPurchased: showPurchased,
                isDesktopView: isDesktopView,
              );
            },
          ),
        ),
      ],
    );
  }



 Widget _buildBookCard(
  BuildContext context,
  Book book, {
  bool showRating = false,
  bool showPurchased = false,
  bool isDesktopView = false,
}) {
  final cardWidth = isDesktopView ? 200.0 : 140.0;
  final imageHeight = isDesktopView ? 240.0 : 180.0; // Reduced from 260 to 240 for desktop

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsScreen(
            book: {
              'title': book.title,
              'author': 'Author Name',
              'imageUrl': 'assets/images/book_placeholder.jpg',
              'rating': book.rating,
              'reviewCount': 245,
              'description': 'A captivating journey through imagination...',
              'genres': ['Fiction', 'Adventure', 'Fantasy'],
              'publisher': 'Erabook Publishing',
              'language': 'English',
              'pages': 324,
              'releaseDate': 'January 15, 2024',
              'categories': ['Fiction', 'Fantasy'],
              'ageRating': '13+',
            },
          ),
        ),
      );
    },
    child: Container(
      width: cardWidth,
      height: isDesktopView ? 300 : 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: imageHeight,
              width: cardWidth,
              color: Colors.grey[200],
              child: const Icon(Icons.book, size: 48, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          // Book title
          Expanded(
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                fontSize: isDesktopView ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Rating and price information
          if (showRating || showPurchased)
            Container(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showRating)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          book.rating.toString(),
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  if (showPurchased)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "Purchased",
                        style: GoogleFonts.urbanist(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildGenreSection(BuildContext context, bool isDesktopView) {
    final cardWidth = isDesktopView ? 200.0 : 140.0;
    final spacing = isDesktopView ? 24.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Explore by Genre", onViewAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreGenreScreen()),
          );
        }),
        SizedBox(
          height: isDesktopView ? 140 : 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: spacing),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenreBookListScreen(
                          genre: genres[index].name,
                        ),
                      ),
                    );
                  },
                  child: _buildGenreCard(genres[index], isDesktopView, cardWidth),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenreCard(Genre genre, bool isDesktopView, double cardWidth) {
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: genre.gradientColors,
        ),
      ),
      padding: EdgeInsets.all(isDesktopView ? 20 : 12),
      alignment: Alignment.bottomLeft,
      child: Text(
        genre.name,
        style: GoogleFonts.urbanist(
          color: Colors.white,
          fontSize: isDesktopView ? 20 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeaturedBook() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/featured_book.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Book of the Week',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The Psychology of Money',
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Morgan Housel',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularBooksList() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: Image.asset(
                      'assets/images/book_cover.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Psychology of Money',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Morgan Housel',
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewReleasesList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: Image.asset(
                      'assets/images/book_cover.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Psychology of Money',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Morgan Housel',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedList() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/book_cover.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Psychology of Money',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                                        fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Morgan Housel',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchasedList() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/book_cover.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '70%',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Psychology of Money',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Morgan Housel',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistList() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/book_cover.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Psychology of Money',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Morgan Housel',
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '19.99',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
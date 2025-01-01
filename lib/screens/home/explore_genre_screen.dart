import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class ExploreGenreScreen extends StatelessWidget {
  const ExploreGenreScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> genres = const [
    {
      "name": "Romance",
      "image": "https://example.com/images/romance.jpg",
    },
    {
      "name": "Thriller",
      "image": "https://example.com/images/thriller.jpg",
    },
    {
      "name": "Inspiration",
      "image": "https://example.com/images/inspiration.jpg",
    },
    {
      "name": "Fantasy",
      "image": "https://example.com/images/fantasy.jpg",
    },
    {
      "name": "Sci-Fi",
      "image": "https://example.com/images/scifi.jpg",
    },
    {
      "name": "Horror",
      "image": "https://example.com/images/horror.jpg",
    },
    {
      "name": "Mystery",
      "image": "https://example.com/images/mystery.jpg",
    },
    {
      "name": "Psychology",
      "image": "https://example.com/images/psychology.jpg",
    },
    {
      "name": "Comedy",
      "image": "https://example.com/images/comedy.jpg",
    },
    {
      "name": "Action",
      "image": "https://example.com/images/action.jpg",
    },
    {
      "name": "Adventure",
      "image": "https://example.com/images/adventure.jpg",
    },
    {
      "name": "Comics",
      "image": "https://example.com/images/comics.jpg",
    },
    {
      "name": "Children's",
      "image": "https://example.com/images/children.jpg",
    },
    {
      "name": "Art & Photography",
      "image": "https://example.com/images/art_photography.jpg",
    },
    {
      "name": "Food & Drink",
      "image": "https://example.com/images/food_drink.jpg",
    },
    {
      "name": "Biography",
      "image": "https://example.com/images/biography.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final crossAxisCount = isDesktop ? 4 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: Colors.black87,
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'Explore by Genre',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.black87,
                onPressed: () {
                  // Implement search action
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24.0 : 16.0,
          vertical: isDesktop ? 24.0 : 16.0,
        ),
        child: GridView.builder(
          itemCount: genres.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isDesktop ? 24 : 16,
            mainAxisSpacing: isDesktop ? 24 : 16,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            final genre = genres[index];
            return _buildGenreCard(
              name: genre["name"]!,
              imageUrl: genre["image"]!,
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenreCard({required String name, required String imageUrl}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
              );
            },
          ),
          // Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Text at bottom-left
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 6.0,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
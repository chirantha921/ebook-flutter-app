import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Update this import path based on your project structure

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Sample previous searches
  List<String> previousSearches = [
    "Harry Potter and the Half Blood Prince",
    "Harry Potter and the Order of Phoenix",
    "The First Mountain Man: Book 1",
    "I'm Glad My Mom Dead",
    "The Silent Patient",
    "Alpha Magic: Reverse Harem",
    "Taken by the Dragon King: Dragon",
    "The Legacy: Semester 1: Academy",
  ];

  @override
  void initState() {
    super.initState();
    // Automatically focus the search field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  void _removeSearchItem(int index) {
    setState(() {
      previousSearches.removeAt(index);
    });
  }

  void _clearAllSearches() {
    setState(() {
      previousSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: isDesktop ? 24.0 : 16.0,
            right: isDesktop ? 24.0 : 16.0,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.black87,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSearchField(),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: previousSearches.isEmpty
            ? _buildEmptyState()
            : _buildPreviousSearchList(),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: GoogleFonts.urbanist(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (query) {
                // Handle the search action
                // You may add the searched query to the previousSearches list here if you want
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: const Icon(Icons.close, color: AppColors.primary, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviousSearchList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Previous Search',
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _clearAllSearches,
                icon: const Icon(Icons.close, color: Colors.black54),
                tooltip: 'Clear All',
              ),
            ],
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: previousSearches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        previousSearches[index],
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.black54),
                      onPressed: () => _removeSearchItem(index),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No previous searches.',
        style: GoogleFonts.urbanist(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}

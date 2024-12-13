import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/constants.dart'; // Update as needed

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Selected filter category index
  int _selectedCategoryIndex = 0;

  // Sort options
  String _selectedSort = 'Trending';

  // Price range
  double _minPrice = 4;
  double _maxPrice = 32;

  // Rating
  String _selectedRating = 'All';

  // Genres
  List<String> allGenres = [
    "All", "Action", "Adventure", "Romance", "Comics", "Comedy", "Fantasy",
    "Mystery", "Horror", "Sci-Fi", "Thriller", "Travel"
  ];
  Set<String> selectedGenres = {"Fantasy", "Thriller"};

  // Language
  String _selectedLanguage = 'English';
  bool _showOtherLanguages = false;

  // Age
  String _selectedAge = 'All';

  // Filter categories (Chips)
  final filterCategories = ["Sort", "Price", "Rating", "Genre", "Language", "Age"];

  void _resetFilters() {
    setState(() {
      _selectedSort = 'Trending';
      _minPrice = 4;
      _maxPrice = 32;
      _selectedRating = 'All';
      selectedGenres = {"Fantasy", "Thriller"};
      _selectedLanguage = 'English';
      _showOtherLanguages = false;
      _selectedAge = 'All';
      _selectedCategoryIndex = 0;
    });
  }

  void _applyFilters() {
    // Implement apply logic
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Filter',
          style: GoogleFonts.urbanist(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24.0 : 16.0,
                vertical: isDesktop ? 24.0 : 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filterCategories.asMap().entries.map((entry) {
                        int index = entry.key;
                        String category = entry.value;
                        bool isSelected = _selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            labelStyle: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: AppColors.primary),
                            selected: isSelected,
                            onSelected: (value) {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildSortSection(),
                          if (_selectedCategoryIndex == 1 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildPriceSection(),
                          if (_selectedCategoryIndex == 2 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildRatingSection(),
                          if (_selectedCategoryIndex == 3 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildGenreSection(),
                          if (_selectedCategoryIndex == 4 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildLanguageSection(),
                          if (_selectedCategoryIndex == 5 || _selectedCategoryIndex == -1 || _selectedCategoryIndex == null)
                            _buildAgeSection(),
                          const SizedBox(height: 100), // For bottom padding
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Apply',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    final sortOptions = ["Trending", "New Releases", "Highest Rating", "Lowest Rating", "Highest Price", "Lowest Price"];
    return _buildCard(
      title: "Sort",
      child: Column(
        children: sortOptions.map((option) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              option,
              style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
            ),
            activeColor: AppColors.primary,
            value: option,
            groupValue: _selectedSort,
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSection() {
    return _buildCard(
      title: "Price",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "\$${_minPrice.round()} - \$${_maxPrice.round()}",
            style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: AppColors.primary,
            ),
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 100,
              divisions: 100,
              labels: RangeLabels("\$${_minPrice.round()}", "\$${_maxPrice.round()}"),
              onChanged: (RangeValues values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final ratingOptions = ["All", "4.5+", "4.0+"];
    return _buildCard(
      title: "Rating",
      child: Column(
        children: ratingOptions.map((rating) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              rating,
              style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
            ),
            activeColor: AppColors.primary,
            value: rating,
            groupValue: _selectedRating,
            onChanged: (value) {
              setState(() {
                _selectedRating = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGenreSection() {
    return _buildCard(
      title: "Genre",
      child: Column(
        children: allGenres.map((genre) {
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              genre,
              style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
            ),
            activeColor: AppColors.primary,
            value: genre == "All" ? (selectedGenres.isEmpty || selectedGenres.contains("All")) : selectedGenres.contains(genre),
            onChanged: (value) {
              setState(() {
                if (genre == "All") {
                  if (value == true) {
                    // Select only 'All'
                    selectedGenres.clear();
                    selectedGenres.add("All");
                  } else {
                    selectedGenres.clear();
                  }
                } else {
                  selectedGenres.remove("All");
                  if (value == true) {
                    selectedGenres.add(genre);
                  } else {
                    selectedGenres.remove(genre);
                  }
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageSection() {
    final languageOptions = ["All", "English", "Mandarin", "Other Languages"];
    return _buildCard(
      title: "Language",
      child: Column(
        children: languageOptions.map((lang) {
          bool isOther = (lang == "Other Languages");
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  lang,
                  style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
                ),
                activeColor: AppColors.primary,
                value: lang,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                    if (lang == "Other Languages") {
                      _showOtherLanguages = !_showOtherLanguages;
                    } else {
                      _showOtherLanguages = false;
                    }
                  });
                },
              ),
              if (isOther && _selectedLanguage == "Other Languages" && _showOtherLanguages)
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "List of other languages ...",
                        style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
                      ),
                      // Add expansion or dropdown logic here
                    ],
                  ),
                )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgeSection() {
    final ageOptions = ["All", "Ages 12 & Under", "Ages 13-17", "Ages 18 & Above"];
    return _buildCard(
      title: "Age",
      child: Column(
        children: ageOptions.map((age) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              age,
              style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
            ),
            activeColor: AppColors.primary,
            value: age,
            groupValue: _selectedAge,
            onChanged: (value) {
              setState(() {
                _selectedAge = value!;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}

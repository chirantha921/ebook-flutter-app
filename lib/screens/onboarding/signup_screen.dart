import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 1;
  final PageController _pageController = PageController();
  String? _selectedGender;
  String? _selectedAgeRange;
  final List<String> _selectedGenres = [];
  
  final _profileFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();
  
  // Controllers for profile step
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  // Controllers for account step
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final List<String> _ageRanges = [
    '14 - 17', '18 - 24', '25 - 29', '30 - 34',
    '35 - 39', '40 - 44', '45 - 49', '≥ 50'
  ];

  final List<Map<String, dynamic>> _genres = [
    {'name': 'Romance', 'icon': '💕'},
    {'name': 'Fiction', 'icon': '📚'},
    {'name': 'Sci-Fi', 'icon': '🚀'},
    {'name': 'Horror', 'icon': '👻'},
    {'name': 'Mystery', 'icon': '🔍'},
    {'name': 'Thriller', 'icon': '🎭'},
    {'name': 'Psychology', 'icon': '🧠'},
    {'name': 'Biography', 'icon': '📝'},
    {'name': 'Business', 'icon': '💼'},
    {'name': 'History', 'icon': '📜'},
    {'name': 'Children', 'icon': '🧸'},
    {'name': 'Literature', 'icon': '📖'},
    {'name': 'Art & Photography', 'icon': '🎨'},
    {'name': 'Food & Drink', 'icon': '🍳'},
    {'name': 'Guide / How-To', 'icon': '📌'},
    {'name': 'Travel', 'icon': '✈️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: _previousStep,
              )
            : null,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentStep / 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildGenderStep(),
          _buildAgeStep(),
          _buildGenreStep(),
          _buildProfileStep(),
          _buildAccountStep(),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your gender? ℹ️',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select gender for better content.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          _buildGenderOption('I am male', 'male'),
          _buildGenderOption('I am female', 'female'),
          _buildGenderOption('Rather not to say', 'other'),
          const Spacer(),
          ElevatedButton(
            onPressed: _selectedGender != null ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Age 🎯',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select age range for better content.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _ageRanges.length,
              itemBuilder: (context, index) {
                final range = _ageRanges[index];
                final isSelected = _selectedAgeRange == range;
                
                return InkWell(
                  onTap: () => setState(() => _selectedAgeRange = range),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.primary : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      range,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _selectedAgeRange != null ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the Book Genre\nYou Like 📚',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select your preferred book genre for better\nrecommendations as you can skip it.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _genres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre['name']);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGenres.remove(genre['name']);
                        } else {
                          _selectedGenres.add(genre['name']);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            genre['icon'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            genre['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _nextStep(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedGenres.isNotEmpty ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete Your Profile 📝',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Don\'t worry, only you can see your personal\ndata. No one else will be able to see it.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/profile_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: _profileFormKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+1 234 567 8900',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _dobController,
                  label: 'Date of Birth',
                  hint: 'MM/DD/YYYY',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  suffixIcon: Icon(Icons.calendar_today, 
                    color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  hint: 'Select your country',
                  readOnly: true,
                  onTap: () => _showCountryPicker(context),
                  suffixIcon: Icon(Icons.keyboard_arrow_down, 
                    color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _validateAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create an Account 🔐',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your username, email & password. If you\nforget it, then you have to do forgot password.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: _accountFormKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter your username',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Remember me',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _createAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool isPassword = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          obscureText: isPassword,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
            suffixIcon: suffixIcon ?? (isPassword
                ? IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {},
                    color: Colors.grey.shade400,
                  )
                : null),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;
    
    return InkWell(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  void _showCountryPicker(BuildContext context) {
    // Implement country picker
  }

  void _validateAndContinue() {
    if (_profileFormKey.currentState?.validate() ?? false) {
      _nextStep();
    }
  }

  void _createAccount() {
    if (_accountFormKey.currentState?.validate() ?? false) {
      // Implement account creation
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
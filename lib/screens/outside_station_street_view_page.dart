import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OutsideStationStreetViewPage extends StatefulWidget {
  const OutsideStationStreetViewPage({super.key});

  @override
  State<OutsideStationStreetViewPage> createState() => _OutsideStationStreetViewPageState();
}

class _OutsideStationStreetViewPageState extends State<OutsideStationStreetViewPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSwiping = false; // Prevent rapid swipes

  final List<String> _images = [
    'assets/panoramas/outsie_station2.png',
    'assets/panoramas/outside_station.png',
  ];

  final List<String> _imageTitles = [
    'Outside Station View 1',
    'Outside Station View 2',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextImage() {
    if (_currentIndex < _images.length - 1) {
      _fadeController.forward().then((_) {
        setState(() {
          _currentIndex++;
        });
        _fadeController.reverse();
      });
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _fadeController.forward().then((_) {
        setState(() {
          _currentIndex--;
        });
        _fadeController.reverse();
      });
    }
  }
  
  // Add haptic feedback for better user experience
  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Fade Animation
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: _buildImageContainer(),
              );
            },
          ),
          
          // Swipe Direction Indicators
          _buildSwipeIndicators(),

          // AppBar with Title
          _buildAppBar(),

          // Navigation Arrows
          _buildNavigationArrows(),

          // Back Button
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return GestureDetector(
      onPanUpdate: (details) {
        // Prevent rapid swipes
        if (_isSwiping) return;
        
        // Detect horizontal swipe gestures with minimum threshold
        if (details.delta.dx > 30) {
          // Swipe right - go to previous image
          _isSwiping = true;
          _triggerHapticFeedback();
          _previousImage();
          // Reset swipe flag after animation
          Future.delayed(const Duration(milliseconds: 350), () {
            _isSwiping = false;
          });
        } else if (details.delta.dx < -30) {
          // Swipe left - go to next image
          _isSwiping = true;
          _triggerHapticFeedback();
          _nextImage();
          // Reset swipe flag after animation
          Future.delayed(const Duration(milliseconds: 350), () {
            _isSwiping = false;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.asset(
            _images[_currentIndex],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Explore: Outside Station - Tanger',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrows() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Arrow (Previous)
          if (_currentIndex > 0)
            Container(
              margin: const EdgeInsets.only(left: 30),
              child: _buildNavigationButton(
                icon: Icons.arrow_back_ios,
                onTap: _previousImage,
                isLeft: true,
              ),
            )
          else
            const SizedBox(width: 80), // Spacer for balance

          // Right Arrow (Next)
          if (_currentIndex < _images.length - 1)
            Container(
              margin: const EdgeInsets.only(right: 30),
              child: _buildNavigationButton(
                icon: Icons.arrow_forward_ios,
                onTap: _nextImage,
                isLeft: false,
              ),
            )
          else
            const SizedBox(width: 80), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSwipeIndicators() {
    return Positioned(
      bottom: 120, // Above the navigation arrows
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left swipe indicator
          if (_currentIndex > 0)
            Container(
              margin: const EdgeInsets.only(left: 30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.swipe_right,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe Right',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Right swipe indicator
          if (_currentIndex < _images.length - 1)
            Container(
              margin: const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Swipe Left',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.swipe_left,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

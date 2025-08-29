# 🚂 TrainSight - Street View Implementation

## 📋 Overview

The `OutsideStationStreetViewPage` is a Flutter screen that displays 360-degree PNG images of the outside of Tanger Station with smooth navigation between different views.

## 🎯 Features Implemented

### ✅ **Core Requirements Met:**
1. **Full-screen Image Display** - Images are displayed full-screen inside a Stack
2. **Navigation Arrows** - Right arrow (→) for next image, left arrow (←) for previous
3. **Image Switching** - Smooth transitions between two 360-degree images
4. **State Management** - Uses `int _currentIndex` to track current image
5. **Image Assets** - Correctly references PNG images from `assets/panoramas/`
6. **ClipRRect & BoxFit** - Images wrapped in ClipRRect with BoxFit.cover
7. **Responsive Design** - Screen adapts to different device sizes
8. **Smooth Animations** - Fade-in/fade-out transitions between images
9. **Swipe Gestures** - Swipe left/right to navigate between images

### ✅ **Bonus Features Added:**
1. **Transparent AppBar** - Title "Explore: Outside Station - Tanger"
2. **Back Button** - Floating back button at top-left for navigation
3. **Modern UI Design** - Glassmorphism effects and smooth animations
4. **Google Fonts Integration** - Uses Poppins font family
5. **Navigation Integration** - Added to Tanger station in map screen

## 🖼️ Image Assets

### **Images Used:**
- `assets/panoramas/outsie_station2.png` - First view (index 0)
- `assets/panoramas/outside_station.png` - Second view (index 1)

### **Asset Declaration:**
```yaml
flutter:
  assets:
    - assets/panoramas/
    - assets/images/
```

## 🔧 Technical Implementation

### **State Management:**
```dart
int _currentIndex = 0;  // Current image index
late AnimationController _fadeController;  // Animation controller
late Animation<double> _fadeAnimation;  // Fade animation
```

### **Image Navigation:**
```dart
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
```

### **Animation System:**
- **Duration:** 300ms fade transitions
- **Curve:** Curves.easeInOut for smooth animation
- **Opacity:** Fade out → change image → fade in

## 🎨 UI Components

### **1. Image Container**
- Full-screen display with BoxFit.cover
- Smooth transitions with AnimatedBuilder
- Responsive sizing

### **2. Navigation Arrows**
- **Right Arrow:** Bottom-right corner, navigates to next image
- **Left Arrow:** Bottom-left corner, navigates to previous image
- **Styling:** Semi-transparent black with white borders
- **Positioning:** Bottom of screen with proper spacing

### **3. Swipe Gestures**
- **Swipe Left:** Navigate to next image (forward)
- **Swipe Right:** Navigate to previous image (backward)
- **Threshold:** 30px minimum swipe distance
- **Haptic Feedback:** Light vibration on successful swipe
- **Anti-spam:** Prevents rapid consecutive swipes

### **4. AppBar**
- **Title:** "Explore: Outside Station - Tanger"
- **Style:** Glassmorphism with location icon
- **Position:** Top center with safe area handling

### **5. Back Button**
- **Position:** Top-left corner
- **Style:** Semi-transparent with white border
- **Function:** Returns to previous screen

### **6. Swipe Indicators**
- **Position:** Above navigation arrows
- **Left Indicator:** Shows "Swipe Right" when previous image available
- **Right Indicator:** Shows "Swipe Left" when next image available
- **Styling:** Semi-transparent with white text and borders

## 🚀 Navigation Integration

### **Map Screen Integration:**
The street view is accessible from the Tanger station in the map screen:

1. **Tap Tanger Station** marker on the map
2. **View Station Details** in bottom sheet
3. **Tap "Voir Street View"** button
4. **Navigate to Street View** page

### **Button Implementation:**
```dart
Widget _buildStreetViewButton() {
  return ElevatedButton.icon(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const OutsideStationStreetViewPage(),
        ),
      );
    },
    icon: const Icon(Icons.streetview, color: Colors.white),
    label: Text('Voir Street View'),
    // ... styling
  );
}
```

## 📱 Usage Instructions

### **1. From Map Screen:**
1. Open the TrainSight app
2. Navigate to the map screen
3. Find and tap the Tanger station marker
4. In the station details, tap "Voir Street View"
5. Use navigation arrows to explore different views

### **2. Direct Navigation (for testing):**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const OutsideStationStreetViewPage(),
  ),
);
```

### **3. Test Page:**
A test page is available at `lib/screens/test_street_view_page.dart` for development and testing purposes.

## 🔍 Code Structure

### **File Organization:**
```
lib/
├── screens/
│   ├── outside_station_street_view_page.dart  # Main street view screen
│   ├── test_street_view_page.dart             # Test navigation page
│   └── map_screen.dart                        # Map with street view integration
└── assets/
    └── panoramas/
        ├── outsie_station2.png                # First 360° view
        └── outside_station.png                # Second 360° view
```

### **Class Structure:**
```dart
class OutsideStationStreetViewPage extends StatefulWidget
class _OutsideStationStreetViewPageState extends State<OutsideStationStreetViewPage>
    with TickerProviderStateMixin
```

### **Key Methods:**
- `_buildImageContainer()` - Displays current image
- `_buildNavigationArrows()` - Navigation controls
- `_buildAppBar()` - Title and header
- `_buildBackButton()` - Back navigation
- `_nextImage()` / `_previousImage()` - Image switching logic

## 🎯 Future Enhancements

### **Potential Improvements:**
1. **✅ Gesture Support** - Swipe left/right for navigation (IMPLEMENTED!)
2. **Zoom Functionality** - Pinch to zoom on images
3. **More Stations** - Extend to other Moroccan stations
4. **AR Integration** - Combine with existing AR features
5. **Image Preloading** - Cache images for smoother transitions
6. **Custom Transitions** - Different animation effects
7. **Image Metadata** - Display location information
8. **Sharing** - Share street view images

## 🧪 Testing

### **Test Scenarios:**
1. **Navigation Flow** - Test arrow navigation between images
2. **Edge Cases** - Test first/last image boundaries
3. **Responsiveness** - Test on different screen sizes
4. **Animation Performance** - Ensure smooth transitions
5. **Memory Usage** - Check for memory leaks with large images
6. **Navigation Integration** - Test from map screen

### **Test Page:**
Use `TestStreetViewPage` for isolated testing of the street view functionality.

## 📚 Dependencies

### **Required Packages:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^5.1.0  # For typography
```

### **Asset Dependencies:**
- PNG images in `assets/panoramas/` directory
- Proper asset declaration in `pubspec.yaml`

## 🚀 Getting Started

### **1. Ensure Assets:**
- Verify PNG images are in `assets/panoramas/`
- Check `pubspec.yaml` asset declarations

### **2. Run the App:**
```bash
flutter pub get
flutter run
```

### **3. Navigate to Street View:**
- Open map screen
- Tap Tanger station
- Tap "Voir Street View" button

## 🎉 Summary

The `OutsideStationStreetViewPage` successfully implements all required features:

✅ **Full-screen 360° image display**  
✅ **Navigation arrows with smooth transitions**  
✅ **State management and image switching**  
✅ **Responsive design and animations**  
✅ **Integration with map screen**  
✅ **Modern UI with glassmorphism effects**  
✅ **Proper asset management**  
✅ **Navigation and back functionality**  

The implementation provides an immersive street view experience for exploring the outside of Tanger Station, with smooth navigation between different perspectives and seamless integration with the existing TrainSight application.

---

🚂 **TrainSight** - Exploring Morocco's stations in 360°! 🇲🇦

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outside_station_street_view_page.dart';

class TestStreetViewPage extends StatelessWidget {
  const TestStreetViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Street View Navigation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.streetview,
              size: 100,
              color: Color(0xFFFF6B35),
            ),
            const SizedBox(height: 24),
            Text(
              'Test Street View Navigation',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the button below to navigate to the\nOutside Station Street View Page',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OutsideStationStreetViewPage(),
                  ),
                );
              },
              icon: const Icon(Icons.streetview, color: Colors.white),
              label: Text(
                'Open Street View',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: const Color(0xFFFF6B35).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}






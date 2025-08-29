import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gare.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import '../widgets/modern_background.dart';
import 'outside_station_street_view_page.dart';

/// Écran de carte interactive moderne avec 12 stations marocaines
/// 
/// Affiche une carte Google Maps avec les 12 gares principales du Maroc,
/// un carousel de cartes interactives, et des fonctionnalités de recherche avancées.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  /// Contrôleur de la carte Google Maps
  GoogleMapController? mapController;
  
  /// Liste complète des 12 gares
  List<Gare> _allGares = [];
  
  /// Liste filtrée des gares
  List<Gare> _filteredGares = [];
  
  /// Marqueurs affichés sur la carte
  Set<Marker> _markers = {};
  
  /// État de chargement
  bool _isLoading = true;
  
  /// Message d'erreur
  String? _errorMessage;
  
  /// Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();
  
  /// Ville sélectionnée pour le filtre
  String? _selectedVille;
  
  /// Distance maximale pour le filtre (en km)
  double _maxDistance = 1000.0;

  /// Gare sélectionnée pour afficher dans le BottomSheet
  Gare? _selectedGare;
  
  /// État du BottomSheet (ouvert/fermé)
  bool _isBottomSheetOpen = false;
  
  /// Contrôleur d'animation pour le BottomSheet
  late AnimationController _bottomSheetController;
  late Animation<double> _bottomSheetAnimation;

  /// Mode d'affichage (carte ou liste)
  bool _isMapMode = true;

  /// Contrôleur pour le carousel des cartes
  final ScrollController _carouselController = ScrollController();

  /// Position initiale de la carte (centre du Maroc)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(31.7917, -7.0926), // Centre du Maroc
    zoom: 6.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGares();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bottomSheetController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  /// Initialiser les animations
  void _initializeAnimations() {
    _bottomSheetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bottomSheetAnimation = CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeInOut,
    );
  }

  /// Méthode pour charger les 12 gares depuis l'API
  Future<void> _loadGares() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final gares = await ApiService.fetchGares();

      setState(() {
        _allGares = gares;
        _filteredGares = gares;
        _markers = _createMarkersFromGares(gares);
        _isLoading = false;
      });

      // Ajuster la vue pour inclure toutes les stations
      _fitAllStationsInView();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Méthode pour ajuster la vue de la carte à toutes les stations
  void _fitAllStationsInView() {
    if (_allGares.isEmpty || mapController == null) return;

    final bounds = _calculateBounds(_allGares);
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
  }

  /// Méthode pour calculer les limites de la carte
  LatLngBounds _calculateBounds(List<Gare> gares) {
    if (gares.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(31.7917, -7.0926),
        northeast: const LatLng(31.7917, -7.0926),
      );
    }

    double minLat = gares.first.latitude;
    double maxLat = gares.first.latitude;
    double minLng = gares.first.longitude;
    double maxLng = gares.first.longitude;

    for (final gare in gares) {
      minLat = min(minLat, gare.latitude);
      maxLat = max(maxLat, gare.latitude);
      minLng = min(minLng, gare.longitude);
      maxLng = max(maxLng, gare.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Méthode pour créer les marqueurs depuis les gares
  Set<Marker> _createMarkersFromGares(List<Gare> gares) {
    return gares.map((gare) => Marker(
      markerId: MarkerId('gare_${gare.id}'),
      position: LatLng(gare.latitude, gare.longitude),
      icon: _getCustomMarkerIcon(gare),
      infoWindow: InfoWindow(
        title: gare.nom,
        snippet: gare.ville,
        onTap: () => _onGoogleMarkerTapped(gare),
      ),
      onTap: () => _onGoogleMarkerTapped(gare),
    )).toSet();
  }

  /// Méthode pour obtenir l'icône personnalisée du marqueur
  BitmapDescriptor _getCustomMarkerIcon(Gare gare) {
    // Utiliser une icône par défaut avec la couleur de la ville
    return BitmapDescriptor.defaultMarkerWithHue(
      _getMarkerHue(gare.getMarkerColor()),
    );
  }

  /// Méthode pour obtenir la teinte du marqueur
  double _getMarkerHue(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.hue;
  }

  /// Méthode appelée quand un marqueur Google Maps est tapé
  void _onGoogleMarkerTapped(Gare gare) {
    setState(() {
      _selectedGare = gare;
      _isBottomSheetOpen = true;
    });
    _bottomSheetController.forward();
    
    // Centrer la carte sur la gare sélectionnée
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(gare.latitude, gare.longitude),
        14.0,
      ),
    );
  }

  /// Méthode pour fermer le BottomSheet
  void _closeBottomSheet() {
    _bottomSheetController.reverse().then((_) {
      setState(() {
        _isBottomSheetOpen = false;
        _selectedGare = null;
      });
    });
  }

  /// Méthode pour lancer un appel téléphonique
  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// Méthode pour réinitialiser les filtres
  void _resetFilters() {
    setState(() {
      _selectedVille = null;
      _maxDistance = 1000.0;
      _searchController.clear();
      _filteredGares = _allGares;
      _markers = _createMarkersFromGares(_allGares);
    });
    _fitAllStationsInView();
  }

  /// Méthode pour appliquer les filtres
  void _applyFilters() {
    List<Gare> filtered = _allGares;

    // Filtre par ville
    if (_selectedVille != null) {
      filtered = filtered.where((gare) => gare.ville == _selectedVille).toList();
    }

    // Filtre par distance depuis Tanger
    filtered = filtered.where((gare) {
      final distance = gare.calculateDistance(35.7801, -5.8125); // Tanger Ville
      return distance <= _maxDistance;
    }).toList();

    // Filtre par recherche textuelle
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((gare) {
        return gare.nom.toLowerCase().contains(searchTerm) ||
               gare.ville.toLowerCase().contains(searchTerm) ||
               gare.description.toLowerCase().contains(searchTerm);
      }).toList();
    }

    setState(() {
      _filteredGares = filtered;
      _markers = _createMarkersFromGares(filtered);
    });
  }

  /// Méthode pour obtenir la liste des villes uniques
  List<String> get _villes {
    final villes = _allGares.map((gare) => gare.ville).toSet().toList();
    villes.sort();
    return villes;
  }

  /// Méthode pour basculer entre le mode carte et liste
  void _toggleViewMode() {
    setState(() {
      _isMapMode = !_isMapMode;
    });
  }

  /// Méthode pour centrer la carte sur une gare spécifique
  void _centerOnGare(Gare gare) {
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(gare.latitude, gare.longitude),
        14.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4E5), // Light beige background
      body: SafeArea(
        child: Column(
          children: [
            // TOP SECTION: AppBar + Search + Mode button
            _buildTopSection(),
            
            // MIDDLE SECTION: Mode indicator
            _buildMiddleSection(),
            
            // BOTTOM SECTION: Map OR List content (not both)
            Expanded(
              child: _buildBottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour la section supérieure (AppBar + Search + Mode button)
  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35), // Dark Orange
            const Color(0xFFFF6B35).withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec titre et boutons
          Row(
            children: [
              // Icône et titre
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.train,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carte des Gares',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '12 Stations Marocaines',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Boutons d'action
              Row(
                children: [
                  _buildActionButton(
                    icon: _isMapMode ? Icons.list : Icons.map,
                    onPressed: _toggleViewMode,
                    tooltip: _isMapMode ? 'Mode Liste' : 'Mode Carte',
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.refresh,
                    onPressed: _loadGares,
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Barre de recherche
          _buildSearchBar(),
        ],
      ),
    );
  }

  /// Widget pour un bouton d'action
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  /// Widget pour la barre de recherche
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _applyFilters(),
        decoration: InputDecoration(
          hintText: '🔍 Rechercher...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 14, // Reduced font size
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6), // Reduced margin
            padding: const EdgeInsets.all(6), // Reduced padding
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8), // Reduced radius
            ),
            child: Icon(Icons.search, color: const Color(0xFFFF6B35), size: 18), // Reduced size
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6), // Reduced margin
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4), // Reduced padding
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6), // Reduced radius
                ),
                child: Icon(Icons.tune, color: const Color(0xFFFF6B35), size: 16), // Reduced size
              ),
              onPressed: () => _showFilterDialog(),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
        ),
        style: GoogleFonts.poppins(fontSize: 14), // Reduced font size
      ),
    );
  }

  /// Widget pour la section du milieu (informations de mode)
  Widget _buildMiddleSection() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isMapMode ? Icons.map : Icons.list,
                  color: const Color(0xFFFF6B35),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isMapMode ? 'Mode Carte' : 'Mode Liste',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredGares.length} gares disponibles',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour la section inférieure (carte ou liste)
  Widget _buildBottomSection() {
    if (_isMapMode) {
      return _buildMapContent();
    } else {
      return _buildStationCardsCarousel();
    }
  }

  /// Widget pour le carousel des cartes de stations
  Widget _buildStationCardsCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header du carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.view_carousel,
                    color: const Color(0xFFFF6B35),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stations ONCF',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ),
                Text(
                  '${_filteredGares.length} gares',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Carousel des cartes
          Container(
            constraints: BoxConstraints(
              minHeight: 140,
              maxHeight: 180,
            ),
            child: ListView.builder(
              controller: _carouselController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getCarouselItems().length,
              itemBuilder: (context, index) {
                final item = _getCarouselItems()[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  child: item,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Méthode pour obtenir les éléments du carousel avec gestion spéciale de Rabat
  List<Widget> _getCarouselItems() {
    List<Widget> items = [];
    List<Gare> rabatGares = [];
    
    for (int i = 0; i < _filteredGares.length; i++) {
      final gare = _filteredGares[i];
      
      if (gare.ville.toLowerCase() == 'rabat') {
        rabatGares.add(gare);
      } else {
        items.add(_buildAnimatedStationCard(gare, i));
      }
    }
    
    // Add combined Rabat card if there are Rabat stations
    if (rabatGares.isNotEmpty) {
      items.add(_buildCombinedRabatCard(rabatGares));
    }
    
    return items;
  }

  /// Widget pour une carte combinée de Rabat
  Widget _buildCombinedRabatCard(List<Gare> rabatGares) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
            child: GestureDetector(
              onTap: () => _showRabatBottomSheet(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec couleur de Rabat
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3498DB), // Blue pour Rabat
                              const Color(0xFF3498DB).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🚆',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rabat - Gares',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${rabatGares.length} stations',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Description
                      Text(
                        'Gares principales de Rabat',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[700],
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Icons row
                      Row(
                        children: [
                          // Phone icon
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _launchPhoneCall(rabatGares.first.telephone),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Map marker icon
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '📍',
                                style: TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Arrow icon
                          Expanded(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget pour une carte de station animée
  Widget _buildAnimatedStationCard(Gare gare, int index) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
            child: _buildStationCard(gare),
          ),
        );
      },
    );
  }

  /// Widget pour le contenu de la carte
  Widget _buildMapContent() {
    return _buildCustomMoroccoMap();
  }

  /// Widget pour la carte personnalisée du Maroc
  Widget _buildCustomMoroccoMap() {
    return Stack(
      children: [
        // Background map container
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFF4E5), // Light beige
                const Color(0xFFFFEBD2), // Very light orange
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Morocco map placeholder
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 48,
                        color: const Color(0xFFFF6B35),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Carte du Maroc',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                      Text(
                        '12 Stations ONCF',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFFF6B35).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Interactive markers grid
                Container(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _filteredGares.length,
                    itemBuilder: (context, index) {
                      final gare = _filteredGares[index];
                      return _buildInteractiveMarker(gare, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Floating action buttons
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFloatingActionButton(
                icon: Icons.refresh,
                onPressed: _resetFilters,
                color: const Color(0xFFFF6B35),
              ),
              const SizedBox(height: 12),
              _buildFloatingActionButton(
                icon: Icons.fit_screen,
                onPressed: () => _scrollToFirstCard(),
                color: const Color(0xFF2ECC71),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget pour un marqueur interactif
  Widget _buildInteractiveMarker(Gare gare, int index) {
    final cityColor = _getCityColor(gare.ville);
    
    return GestureDetector(
      onTap: () => _onMarkerTapped(gare, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cityColor,
              cityColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cityColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onMarkerTapped(gare, index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Train icon with pulse animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: 0.8, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.train,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Station name
                  Text(
                    gare.nom.split(' ').first, // Show first word only
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    gare.ville,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Méthode appelée quand un marqueur est tapé
  void _onMarkerTapped(Gare gare, int index) {
    // Scroll to the corresponding card in carousel
    _scrollToCard(index);
    
    // Show station details
    if (gare.ville.toLowerCase() == 'rabat') {
      _showRabatBottomSheet();
    } else {
      _showStationBottomSheet(gare);
    }
  }

  /// Méthode pour faire défiler vers une carte spécifique
  void _scrollToCard(int index) {
    if (_carouselController.hasClients) {
      _carouselController.animateTo(
        index * 296.0, // 280 (card width) + 16 (margin)
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Méthode pour faire défiler vers la première carte
  void _scrollToFirstCard() {
    if (_carouselController.hasClients) {
      _carouselController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Widget pour un bouton d'action flottant
  Widget _buildFloatingActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        child: Icon(icon, size: 24),
      ),
    );
  }

  /// Widget de fallback si Google Maps ne charge pas
  Widget _buildMapFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.train,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'TrainSight - 12 Gares du Maroc',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[100]!,
                    Colors.orange[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Mode Liste - Toutes les fonctionnalités disponibles',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w600,
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

  /// Widget pour le contenu en mode liste
  Widget _buildListContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _filteredGares.length,
        itemBuilder: (context, index) {
          final gare = _filteredGares[index];
          return _buildStationCard(gare);
        },
      ),
    );
  }

  /// Widget pour une carte de station
  Widget _buildStationCard(Gare gare) {
    final cityColor = _getCityColor(gare.ville);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onStationCardTapped(gare),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec couleur de la ville
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cityColor,
                        cityColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Train icon
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '🚆',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gare.nom,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              gare.ville,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description (1 ligne avec ellipsis)
                if (gare.description.isNotEmpty)
                  Text(
                    gare.description,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[700],
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 8),
                
                // Icons row
                Row(
                  children: [
                    // Phone icon with hover effect
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _launchPhoneCall(gare.telephone),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.phone,
                              size: 14,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Map marker icon
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '📍',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Arrow icon
                    Expanded(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Méthode pour obtenir la couleur de la ville selon le thème ONCF
  Color _getCityColor(String ville) {
    switch (ville.toLowerCase()) {
      case 'tanger':
        return const Color(0xFFE74C3C); // Red
      case 'casablanca':
        return const Color(0xFF2ECC71); // Green
      case 'rabat':
        return const Color(0xFF3498DB); // Blue
      default:
        return const Color(0xFFFFA726); // Amber/Orange
    }
  }

  /// Méthode appelée quand une carte de station est tapée
  void _onStationCardTapped(Gare gare) {
    // Vérifier si c'est une station de Rabat pour traitement spécial
    if (gare.ville.toLowerCase() == 'rabat') {
      _showRabatBottomSheet();
    } else {
      _showStationBottomSheet(gare);
    }
  }

  /// Widget pour l'état de chargement
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(
                Icons.train,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chargement des gares...',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Récupération des 12 stations marocaines',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour l'état d'erreur
  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadGares,
              icon: Icon(Icons.refresh, size: 20),
              label: Text(
                'Réessayer',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Méthode pour afficher le BottomSheet spécial de Rabat
  void _showRabatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRabatBottomSheet(),
    );
  }

  /// Méthode pour afficher le BottomSheet d'une station normale
  void _showStationBottomSheet(Gare gare) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStationBottomSheet(gare),
    );
  }

  /// Widget pour le BottomSheet d'une station normale
  Widget _buildStationBottomSheet(Gare gare) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle pour fermer
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // En-tête avec Dark Orange
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35), // Dark Orange header
                  const Color(0xFFFF6B35).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.train, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gare.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        gare.ville,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (gare.description.isNotEmpty) ...[
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gare.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Coordonnées
                  Text(
                    'Coordonnées',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      '${gare.latitude.toStringAsFixed(4)}, ${gare.longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Téléphone
                  _buildDetailRow(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    value: gare.telephone,
                    onTap: () => _launchPhoneCall(gare.telephone),
                    isClickable: true,
                  ),
                  
                  // Street View Button for Tanger
                  if (gare.ville.toLowerCase() == 'tanger') ...[
                    const SizedBox(height: 20),
                    _buildStreetViewButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour le bouton Street View
  Widget _buildStreetViewButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OutsideStationStreetViewPage(),
            ),
          );
        },
        icon: const Icon(Icons.streetview, color: Colors.white),
        label: Text(
          'Voir Street View',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFFF6B35).withOpacity(0.3),
        ),
      ),
    );
  }

  /// Widget pour le BottomSheet spécial de Rabat
  Widget _buildRabatBottomSheet() {
    final rabatGares = _allGares.where((gare) => gare.ville.toLowerCase() == 'rabat').toList();
    final cityColor = const Color(0xFF3498DB); // Blue pour Rabat

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle pour fermer
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // En-tête
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35), // Dark Orange header
                  const Color(0xFFFF6B35).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.train, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rabat - Gares',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${rabatGares.length} stations disponibles',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des stations de Rabat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rabatGares.length,
              itemBuilder: (context, index) {
                final gare = rabatGares[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gare.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.phone,
                        title: 'Téléphone',
                        value: gare.telephone,
                        onTap: () => _launchPhoneCall(gare.telephone),
                        isClickable: true,
                      ),
                      if (gare.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          gare.description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour une ligne de détail
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback? onTap,
    required bool isClickable,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isClickable ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isClickable ? Border.all(color: Colors.blue[200]!) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isClickable ? Colors.blue[600] : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isClickable ? Colors.blue[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.blue[600],
              ),
          ],
        ),
      ),
    );
  }

  /// Méthode pour afficher le dialogue de filtres
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Filtrer les gares',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Filtre par ville
              Text(
                'Ville',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedVille,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Toutes les villes',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Toutes les villes'),
                  ),
                  ..._villes.map((ville) => DropdownMenuItem<String>(
                    value: ville,
                    child: Text(ville),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVille = value;
                  });
                  _applyFilters();
                },
              ),
              const SizedBox(height: 24),
              
              // Filtre par distance
              Text(
                'Distance maximale depuis Tanger',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _maxDistance,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      label: '${_maxDistance.round()} km',
                      onChanged: (value) {
                        setState(() {
                          _maxDistance = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  Text(
                    '${_maxDistance.round()} km',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Bouton de réinitialisation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Réinitialiser les filtres',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour la section de la carte (centrée, responsive)
  Widget _buildMapSection() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF4E5), // Light beige
            const Color(0xFFFFE0B2), // Light orange
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Morocco map placeholder (responsive)
            Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: BoxConstraints(
                maxWidth: 350,
                minHeight: 180,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 40,
                      color: const Color(0xFFFF6B35),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Carte du Maroc',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '12 Stations ONCF',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFFF6B35).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Interactive markers grid (responsive)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 100,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: _filteredGares.length,
                        itemBuilder: (context, index) {
                          final gare = _filteredGares[index];
                          return _buildInteractiveMarker(gare, index);
                        },
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

  /// Widget pour le carousel des stations
  Widget _buildStationCarousel() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 160,
        maxHeight: 200,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFFFF6B35).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header du carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.view_carousel,
                    color: const Color(0xFFFF6B35),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stations ONCF',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ),
                Text(
                  '${_filteredGares.length} gares',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Carousel des cartes
          Expanded(
            child: ListView.builder(
              controller: _carouselController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getCarouselItems().length,
              itemBuilder: (context, index) {
                final item = _getCarouselItems()[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 12),
                  child: item,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
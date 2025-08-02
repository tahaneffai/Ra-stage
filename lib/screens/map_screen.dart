import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gare.dart';
import '../services/api_service.dart';
import '../constants/app_colors.dart';
import '../widgets/modern_background.dart';
import 'dashboard_screen.dart';

/// Écran de carte interactive avec recherche et filtres
/// 
/// Affiche une carte Google Maps avec les gares, permet la recherche
/// et le filtrage des gares, et affiche les détails dans un BottomSheet moderne.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  /// Contrôleur de la carte Google Maps
  GoogleMapController? mapController;
  
  /// Liste complète des gares
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

  /// Position initiale de la carte (Tanger)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.7595, -5.8340),
    zoom: 8.0,
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

  /// Méthode pour charger les gares depuis l'API
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
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
        onTap: () => _onMarkerTapped(gare),
      ),
      onTap: () => _onMarkerTapped(gare),
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

  /// Méthode appelée quand un marqueur est tapé
  void _onMarkerTapped(Gare gare) {
    setState(() {
      _selectedGare = gare;
      _isBottomSheetOpen = true;
    });
    _bottomSheetController.forward();
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
      final distance = gare.calculateDistance(35.7595, -5.8340);
      return distance <= _maxDistance;
    }).toList();

    // Filtre par recherche textuelle
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((gare) {
        return gare.nom.toLowerCase().contains(searchTerm) ||
               gare.ville.toLowerCase().contains(searchTerm);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carte des Gares',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGares,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte Google Maps
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _buildMapContent(),

          // Barre de recherche
          if (!_isLoading && _errorMessage == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildSearchBar(),
            ),

          // Boutons d'action flottants
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: _resetFilters,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    heroTag: 'reset',
                    child: const Icon(Icons.refresh),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          const CameraPosition(
                            target: LatLng(35.7595, -5.8340),
                            zoom: 12.0,
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    heroTag: 'center',
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),

          // BottomSheet pour les détails de la gare
          if (_isBottomSheetOpen && _selectedGare != null)
            _buildBottomSheet(size),
        ],
      ),
    );
  }

  /// Widget pour l'état de chargement
  Widget _buildLoadingState() {
    return AnimatedModernBackground(
      isDark: Theme.of(context).brightness == Brightness.dark,
      child: Container(),
    );
  }

  /// Widget pour l'état d'erreur
  Widget _buildErrorState() {
    return AnimatedModernBackground(
      isDark: Theme.of(context).brightness == Brightness.dark,
      child: Container(),
    );
  }

  /// Widget pour le contenu de la carte
  Widget _buildMapContent() {
    // Check if Google Maps is available
    if (kIsWeb) {
      // For web, use fallback mode by default to avoid API key issues
      return _buildMapFallback();
    } else {
      // For mobile, try to use Google Maps
      try {
        return GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          initialCameraPosition: _initialPosition,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        );
      } catch (e) {
        // Fallback if Google Maps fails to load
        return _buildMapFallback();
      }
    }
  }

  /// Widget de fallback si Google Maps ne charge pas
  Widget _buildMapFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[100]!,
            Colors.blue[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header avec informations
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.train,
                  size: 48,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 12),
                Text(
                  'TrainSight - Gares du Maroc',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_filteredGares.length} gares disponibles',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Text(
                    'Mode Liste - Toutes les fonctionnalités disponibles',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des gares
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredGares.length,
              itemBuilder: (context, index) {
                final gare = _filteredGares[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: gare.getMarkerColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.train, color: Colors.white, size: 24),
                    ),
                    title: Text(
                      gare.nom,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gare.ville,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (gare.description.isNotEmpty)
                          Text(
                            gare.description,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () => _launchPhoneCall(gare.telephone),
                          tooltip: 'Appeler',
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, color: Colors.blue),
                          onPressed: () => _onMarkerTapped(gare),
                          tooltip: 'Détails',
                        ),
                      ],
                    ),
                    onTap: () => _onMarkerTapped(gare),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour la barre de recherche
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _applyFilters(),
        decoration: InputDecoration(
          hintText: 'Rechercher une gare...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: GoogleFonts.poppins(),
      ),
    );
  }

  /// Widget pour le BottomSheet
  Widget _buildBottomSheet(Size size) {
    return AnimatedBuilder(
      animation: _bottomSheetAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: -size.height * 0.4 * (1 - _bottomSheetAnimation.value),
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {}, // Empêcher la fermeture au tap sur le contenu
            child: Container(
              height: size.height * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle pour fermer
                  GestureDetector(
                    onTap: _closeBottomSheet,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _selectedGare!.ville.toLowerCase() == 'rabat'
                        ? _buildRabatBottomSheet()
                        : _buildStationBottomSheet(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget pour le BottomSheet d'une station normale
  Widget _buildStationBottomSheet() {
    final gare = _selectedGare!;
    final cityColor = gare.getMarkerColor();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cityColor.withOpacity(0.9),
                  cityColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.train,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gare.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
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
          const SizedBox(height: 20),

          // Détails de la station
          _buildDetailRow(
            icon: Icons.phone,
            title: 'Téléphone',
            value: gare.telephone,
            onTap: () => _launchPhoneCall(gare.telephone),
            isClickable: true,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.location_on,
            title: 'Coordonnées',
            value: '${gare.latitude.toStringAsFixed(4)}, ${gare.longitude.toStringAsFixed(4)}',
            onTap: null,
            isClickable: false,
          ),
          const SizedBox(height: 16),

          // Description
          if (gare.description.isNotEmpty) ...[
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 14,
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
          ],
        ],
      ),
    );
  }

  /// Widget pour le BottomSheet spécial de Rabat
  Widget _buildRabatBottomSheet() {
    final rabatGares = _allGares.where((gare) => gare.ville.toLowerCase() == 'rabat').toList();
    final cityColor = const Color(0xFF2196F3); // Bleu pour Rabat

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cityColor.withOpacity(0.9),
                  cityColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.train,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rabat - Gares',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
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
          const SizedBox(height: 20),

          // Liste des stations de Rabat
          Expanded(
            child: ListView.builder(
              itemCount: rabatGares.length,
              itemBuilder: (context, index) {
                final gare = rabatGares[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gare.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        icon: Icons.phone,
                        title: 'Téléphone',
                        value: gare.telephone,
                        onTap: () => _launchPhoneCall(gare.telephone),
                        isClickable: true,
                        isCompact: true,
                      ),
                      if (gare.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          gare.description,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
    bool isCompact = false,
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
              size: isCompact ? 16 : 20,
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
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: isCompact ? 12 : 14,
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
          color: AppColors.bottomSheetBackground,
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
                    backgroundColor: AppColors.primary,
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
} 
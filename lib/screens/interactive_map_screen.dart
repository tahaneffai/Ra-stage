import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/morocco_map_placeholder.dart';

/// Écran de carte interactive personnalisée
/// 
/// Remplace le "Mode Carte" par une expérience de carte interactive
/// avec une carte du Maroc en arrière-plan et des marqueurs de stations cliquables
class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen>
    with TickerProviderStateMixin {
  // Contrôleurs d'animation pour les marqueurs
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Variables pour le zoom et pan
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  
  // État de survol pour les marqueurs
  String? _hoveredStation;
  
  // Mode d'affichage (carte ou liste)
  bool _isMapMode = true;
  
  // Filtres et recherche
  String _searchQuery = '';
  String _selectedCity = 'Toutes';
  String _selectedRegion = 'Toutes';
  
  // Données des stations
  final List<StationData> _stations = [
    StationData(
      name: 'Tanger Ville',
      city: 'Tanger',
      region: 'Nord',
      position: const Offset(80, 50),
      description: 'Gare maritime moderne au nord du Maroc',
      phone: '+212-539-001',
    ),
    StationData(
      name: 'Rabat Agdal',
      city: 'Rabat',
      region: 'Centre',
      position: const Offset(120, 120),
      description: 'Gare urbaine au cœur du quartier Agdal',
      phone: '+212-537-020',
    ),
    StationData(
      name: 'Rabat Ville',
      city: 'Rabat',
      region: 'Centre',
      position: const Offset(125, 125),
      description: 'Gare centrale à proximité de la médina',
      phone: '+212-537-021',
    ),
    StationData(
      name: 'Casablanca Voyageurs',
      city: 'Casablanca',
      region: 'Centre',
      position: const Offset(100, 180),
      description: 'Plus grande gare ferroviaire du Maroc',
      phone: '+212-522-002',
    ),
    StationData(
      name: 'Fès',
      city: 'Fès',
      region: 'Centre',
      position: const Offset(180, 140),
      description: 'Gare historique et hub ferroviaire du centre',
      phone: '+212-535-003',
    ),
    StationData(
      name: 'Marrakech',
      city: 'Marrakech',
      region: 'Sud',
      position: const Offset(120, 280),
      description: 'Gare touristique du sud du Maroc',
      phone: '+212-524-004',
    ),
    StationData(
      name: 'Kenitra',
      city: 'Kenitra',
      region: 'Centre',
      position: const Offset(110, 150),
      description: 'Gare stratégique sur la ligne TGV',
      phone: '+212-537-005',
    ),
    StationData(
      name: 'Oujda',
      city: 'Oujda',
      region: 'Est',
      position: const Offset(280, 120),
      description: 'Gare de l\'extrême est du Maroc',
      phone: '+212-536-006',
    ),
    StationData(
      name: 'Oued Zem',
      city: 'Oued Zem',
      region: 'Centre',
      position: const Offset(150, 200),
      description: 'Gare régionale au centre du pays',
      phone: '+212-523-007',
    ),
    StationData(
      name: 'Settat',
      city: 'Settat',
      region: 'Centre',
      position: const Offset(130, 220),
      description: 'Gare régionale entre Casa et Marrakech',
      phone: '+212-523-008',
    ),
    StationData(
      name: 'El Jadida',
      city: 'El Jadida',
      region: 'Centre',
      position: const Offset(90, 220),
      description: 'Gare touristique sur la côte Atlantique',
      phone: '+212-523-009',
    ),
    StationData(
      name: 'Safi',
      city: 'Safi',
      region: 'Centre',
      position: const Offset(100, 250),
      description: 'Gare portuaire sur l\'océan Atlantique',
      phone: '+212-524-010',
    ),
  ];

  // Stations filtrées
  List<StationData> get _filteredStations {
    return _stations.where((station) {
      final matchesSearch = station.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           station.city.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCity = _selectedCity == 'Toutes' || station.city == _selectedCity;
      final matchesRegion = _selectedRegion == 'Toutes' || station.region == _selectedRegion;
      
      return matchesSearch && matchesCity && matchesRegion;
    }).toList();
  }

  // Villes uniques pour le filtre
  List<String> get _uniqueCities => _stations.map((s) => s.city).toSet().toList()..sort();
  
  // Régions uniques pour le filtre
  List<String> get _uniqueRegions => _stations.map((s) => s.region).toSet().toList()..sort();

  @override
  void initState() {
    super.initState();
    
    // Initialiser l'animation de pulsation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Démarrer l'animation en boucle
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showStationInfo(StationData station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildStationModal(station),
    );
  }

  Widget _buildStationModal(StationData station) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Station info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station name and city
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.train,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.name,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              station.city,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    station.description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Contact info
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        station.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // TODO: Navigate to station details
                          },
                          icon: const Icon(Icons.info_outline),
                          label: Text(
                            'Plus d\'infos',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: Text(
                            'Fermer',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal (carte ou liste)
          _isMapMode ? _buildMapView() : _buildListView(),
          
          // Barre de navigation en haut
          _buildTopNavigationBar(),
          
          // Bouton de retour
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Carte du Maroc en arrière-plan
        _buildMapBackground(),
        
        // Marqueurs des stations filtrées
        _buildStationMarkers(),
        
        // Légende en haut à droite
        _buildLegend(),
        
        // Contrôles de zoom
        _buildZoomControls(),
      ],
    );
  }

  Widget _buildListView() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(),
          
          // Liste des stations
          Expanded(
            child: _filteredStations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredStations.length,
                    itemBuilder: (context, index) {
                      final station = _filteredStations[index];
                      return _buildStationCard(station);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        _previousOffset = _offset;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_previousScale * details.scale).clamp(0.5, 3.0);
          
          // Calculer le décalage avec limitation horizontale
          final newOffset = _previousOffset + details.focalPointDelta;
          _offset = Offset(
            newOffset.dx.clamp(-200, 200),
            newOffset.dy.clamp(-100, 100),
          );
        });
      },
      child: Transform.scale(
        scale: _scale,
        child: Transform.translate(
          offset: _offset,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/map_morocco.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Utiliser la carte de remplacement si l'image n'est pas trouvée
                return const MoroccoMapPlaceholder();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationMarkers() {
    return Stack(
      children: _filteredStations.map((station) {
        final isHovered = _hoveredStation == station.name;
        
        return Positioned(
          left: station.position.dx,
          top: station.position.dy,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredStation = station.name),
            onExit: (_) => setState(() => _hoveredStation = null),
            child: GestureDetector(
              onTap: () => _showStationInfo(station),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isHovered ? 1.2 : _pulseAnimation.value,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: isHovered ? 15 : 8,
                            spreadRadius: isHovered ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Légende',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Station ferroviaire',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.zoom_in,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Zoom: Pincement',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pan_tool,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Déplacer: Glisser',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bouton de retour
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
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
                      color: Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Titre
            Expanded(
              child: Text(
                'Gares du Maroc',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Toggle Carte/Liste
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton(
                    icon: Icons.map,
                    label: 'Carte',
                    isSelected: _isMapMode,
                    onTap: () => setState(() => _isMapMode = true),
                  ),
                  _buildToggleButton(
                    icon: Icons.list,
                    label: 'Liste',
                    isSelected: !_isMapMode,
                    onTap: () => setState(() => _isMapMode = false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return const SizedBox.shrink(); // Maintenant géré dans la barre de navigation
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher une gare...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtres
          Row(
            children: [
              // Filtre par ville
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedCity,
                  items: ['Toutes', ..._uniqueCities],
                  label: 'Ville',
                  onChanged: (value) => setState(() => _selectedCity = value!),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Filtre par région
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedRegion,
                  items: ['Toutes', ..._uniqueRegions],
                  label: 'Région',
                  onChanged: (value) => setState(() => _selectedRegion = value!),
                ),
              ),
            ],
          ),
          
          // Compteur de résultats
          if (_searchQuery.isNotEmpty || _selectedCity != 'Toutes' || _selectedRegion != 'Toutes')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.filter_list, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredStations.length} gare(s) trouvée(s)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCity = 'Toutes';
                        _selectedRegion = 'Toutes';
                      });
                    },
                    child: Text(
                      'Réinitialiser',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            )).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStationCard(StationData station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showStationInfo(station),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de la gare
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.train,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informations de la gare
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station.city,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          station.region,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bouton d'action
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune gare trouvée',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres ou votre recherche',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCity = 'Toutes';
                _selectedRegion = 'Toutes';
              });
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Réinitialiser les filtres',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      right: 20,
      child: Column(
        children: [
          // Bouton zoom +
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _scale = (_scale * 1.2).clamp(0.5, 3.0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Bouton zoom -
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _scale = (_scale / 1.2).clamp(0.5, 3.0);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.remove,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Bouton reset
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _scale = 1.0;
                    _offset = Offset.zero;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.center_focus_strong,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Données d'une station ferroviaire
class StationData {
  final String name;
  final String city;
  final String region;
  final Offset position;
  final String description;
  final String phone;

  const StationData({
    required this.name,
    required this.city,
    required this.region,
    required this.position,
    required this.description,
    required this.phone,
  });
}

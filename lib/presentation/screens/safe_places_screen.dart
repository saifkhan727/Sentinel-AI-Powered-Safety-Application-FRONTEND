// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../data/models/safe_place_model.dart';
// import '../../../data/services/api_service.dart';
//
// class SafePlacesScreen extends StatefulWidget {
//   const SafePlacesScreen({super.key});
//
//   @override
//   State<SafePlacesScreen> createState() =>
//       _SafePlacesScreenState();
// }
//
// class _SafePlacesScreenState extends State<SafePlacesScreen> {
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   List<SafePlaceModel> _places = [];
//   Set<Marker> _markers = {};
//   bool _isLoading = true;
//   bool _isLocationLoading = true;
//   String _selectedType = 'all';
//
//   // Filter types
//   final List<Map<String, dynamic>> _filters = [
//     {
//       'type': 'all',
//       'label': 'All',
//       'icon': Icons.location_on_rounded
//     },
//     {
//       'type': 'police',
//       'label': 'Police',
//       'icon': Icons.local_police_rounded
//     },
//     {
//       'type': 'hospital',
//       'label': 'Hospital',
//       'icon': Icons.local_hospital_rounded
//     },
//     {
//       'type': 'mall',
//       'label': 'Mall',
//       'icon': Icons.store_rounded
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }
//
//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   // ─── Initialize ───────────────────────────────────────
//   Future<void> _initialize() async {
//     await _getCurrentLocation();
//     await _loadSafePlaces(type: 'all');
//   }
//
//   // ─── Get Current Location ──────────────────────────────
//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled =
//       await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() => _isLocationLoading = false);
//         return;
//       }
//
//       LocationPermission permission =
//       await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() => _isLocationLoading = false);
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         setState(() => _isLocationLoading = false);
//         return;
//       }
//
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//
//       setState(() {
//         _currentPosition = position;
//         _isLocationLoading = false;
//       });
//
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(
//           LatLng(position.latitude, position.longitude),
//           14,
//         ),
//       );
//
//     } catch (e) {
//       print('Location error: $e');
//       setState(() => _isLocationLoading = false);
//     }
//   }
//
//   // ─── Load Safe Places ──────────────────────────────────
//   Future<void> _loadSafePlaces({String type = 'all'}) async {
//     if (_currentPosition == null) {
//       await _getCurrentLocation();
//     }
//
//     if (_currentPosition == null) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Could not get your location. Please enable GPS.',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//             backgroundColor: AppColors.sosRed,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     final result = await ApiService.getSafePlaces(
//       latitude: _currentPosition!.latitude,
//       longitude: _currentPosition!.longitude,
//       type: type == 'all' ? null : type,
//       radius: 5000,
//     );
//
//     if (result['success'] == true) {
//       final List<dynamic> data = result['places'];
//       final places =
//       data.map((p) => SafePlaceModel.fromJson(p)).toList();
//
//       setState(() {
//         _places = places;
//         _isLoading = false;
//       });
//
//       _updateMarkers(places);
//     } else {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               result['message'] ?? 'Failed to load places',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//             backgroundColor: AppColors.sosRed,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     }
//   }
//
//   // ─── Update Map Markers ────────────────────────────────
//   void _updateMarkers(List<SafePlaceModel> places) {
//     final markers = <Marker>{};
//
//     // Add user location marker
//     if (_currentPosition != null) {
//       markers.add(
//         Marker(
//           markerId: const MarkerId('user_location'),
//           position: LatLng(
//             _currentPosition!.latitude,
//             _currentPosition!.longitude,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueViolet,
//           ),
//           infoWindow: const InfoWindow(title: 'You are here'),
//         ),
//       );
//     }
//
//     // Add place markers
//     for (final place in places) {
//       markers.add(
//         Marker(
//           markerId: MarkerId(place.id),
//           position: LatLng(place.latitude, place.longitude),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             _getMarkerHue(place.type),
//           ),
//           infoWindow: InfoWindow(
//             title: place.name,
//             snippet: place.address ?? place.type,
//           ),
//           onTap: () => _showPlaceDetails(place),
//         ),
//       );
//     }
//
//     setState(() => _markers = markers);
//   }
//
//   // ─── Get Marker Hue ────────────────────────────────────
//   double _getMarkerHue(String type) {
//     switch (type) {
//       case 'police':
//         return BitmapDescriptor.hueBlue;
//       case 'hospital':
//         return BitmapDescriptor.hueRed;
//       case 'mall':
//         return BitmapDescriptor.hueGreen;
//       default:
//         return BitmapDescriptor.hueViolet;
//     }
//   }
//
//   // ─── Get Color by Type ─────────────────────────────────
//   Color _getTypeColor(String type) {
//     switch (type) {
//       case 'police':
//         return const Color(0xFF1565C0);
//       case 'hospital':
//         return AppColors.sosRed;
//       case 'mall':
//         return AppColors.successGreen;
//       default:
//         return AppColors.deepPurple;
//     }
//   }
//
//   // ─── Get Icon by Type ──────────────────────────────────
//   IconData _getTypeIcon(String type) {
//     switch (type) {
//       case 'police':
//         return Icons.local_police_rounded;
//       case 'hospital':
//         return Icons.local_hospital_rounded;
//       case 'mall':
//         return Icons.store_rounded;
//       default:
//         return Icons.location_on_rounded;
//     }
//   }
//
//   // ─── Format Distance ───────────────────────────────────
//   String _formatDistance(double? distance) {
//     if (distance == null) return '';
//     if (distance < 1000) return '${distance.toInt()}m away';
//     return '${(distance / 1000).toStringAsFixed(1)}km away';
//   }
//
//   // ─── Show Place Details ────────────────────────────────
//   void _showPlaceDetails(SafePlaceModel place) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(28),
//             topRight: Radius.circular(28),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//
//             // Handle bar
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Place Info Row
//             Row(
//               children: [
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: _getTypeColor(place.type)
//                         .withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Icon(
//                     _getTypeIcon(place.type),
//                     color: _getTypeColor(place.type),
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         place.name,
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.darkGrey,
//                         ),
//                       ),
//                       if (place.address != null)
//                         Text(
//                           place.address!,
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             color: AppColors.mediumGrey,
//                           ),
//                         ),
//                       Row(
//                         children: [
//                           if (place.distance != null)
//                             Text(
//                               _formatDistance(place.distance),
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: _getTypeColor(place.type),
//                               ),
//                             ),
//                           if (place.distance != null &&
//                               place.isOpen != null)
//                             Text(
//                               '  •  ',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 color: AppColors.mediumGrey,
//                               ),
//                             ),
//                           if (place.isOpen != null)
//                             Text(
//                               place.isOpen! ? '🟢 Open' : '🔴 Closed',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // Action Buttons
//             Row(
//               children: [
//                 // Call Button
//                 if (place.phone != null) ...[
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () =>
//                           _callPlace(place.phone!),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.successGreen,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius:
//                           BorderRadius.circular(14),
//                         ),
//                         elevation: 0,
//                       ),
//                       icon: const Icon(
//                           Icons.call_rounded,
//                           size: 20),
//                       label: Text(
//                         'Call Now',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                 ],
//
//                 // Navigate Button
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _navigateToPlace(place),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.deepPurple,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.circular(14),
//                       ),
//                       elevation: 0,
//                     ),
//                     icon: const Icon(
//                         Icons.directions_rounded,
//                         size: 20),
//                     label: Text(
//                       'Navigate',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Call Place ────────────────────────────────────────
//   Future<void> _callPlace(String phone) async {
//     final Uri uri = Uri.parse('tel:$phone');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }
//
//   // ─── Navigate to Place ─────────────────────────────────
//   Future<void> _navigateToPlace(SafePlaceModel place) async {
//     final Uri uri = Uri.parse(
//       'https://maps.google.com/?q=${place.latitude},${place.longitude}',
//     );
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGrey,
//       body: Column(
//         children: [
//
//           // ─── Purple Header ─────────────────────────────
//           Container(
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: AppColors.purpleGradient,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(36),
//                 bottomRight: Radius.circular(36),
//               ),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(
//                     20, 16, 20, 20),
//                 child: Column(
//                   children: [
//
//                     // ── App Bar ──────────────────────────
//                     FadeInDown(
//                       duration:
//                       const Duration(milliseconds: 600),
//                       child: Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () =>
//                                 Navigator.pop(context),
//                             child: Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: Colors.white
//                                     .withOpacity(0.2),
//                                 borderRadius:
//                                 BorderRadius.circular(12),
//                               ),
//                               child: const Icon(
//                                 Icons.arrow_back_ios_new_rounded,
//                                 color: Colors.white,
//                                 size: 18,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Safe Places',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 Text(
//                                   _isLoading
//                                       ? 'Finding nearby places...'
//                                       : '${_places.length} places found nearby',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Refresh Button
//                           GestureDetector(
//                             onTap: () => _loadSafePlaces(
//                                 type: _selectedType),
//                             child: Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 color: Colors.white
//                                     .withOpacity(0.15),
//                                 borderRadius:
//                                 BorderRadius.circular(14),
//                               ),
//                               child: const Icon(
//                                 Icons.refresh_rounded,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // ── Filter Chips ─────────────────────
//                     FadeInUp(
//                       duration:
//                       const Duration(milliseconds: 600),
//                       delay:
//                       const Duration(milliseconds: 200),
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           children:
//                           _filters.map((filter) {
//                             final isSelected =
//                                 _selectedType ==
//                                     filter['type'];
//                             return Padding(
//                               padding: const EdgeInsets.only(
//                                   right: 10),
//                               child: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedType =
//                                     filter['type']
//                                     as String;
//                                   });
//                                   _loadSafePlaces(
//                                     type: filter['type']
//                                     as String,
//                                   );
//                                 },
//                                 child: Container(
//                                   padding:
//                                   const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 8,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: isSelected
//                                         ? Colors.white
//                                         : Colors.white
//                                         .withOpacity(0.2),
//                                     borderRadius:
//                                     BorderRadius.circular(
//                                         20),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize:
//                                     MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         filter['icon']
//                                         as IconData,
//                                         size: 16,
//                                         color: isSelected
//                                             ? AppColors
//                                             .deepPurple
//                                             : Colors.white,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         filter['label']
//                                         as String,
//                                         style: GoogleFonts
//                                             .poppins(
//                                           fontSize: 13,
//                                           fontWeight:
//                                           FontWeight.w600,
//                                           color: isSelected
//                                               ? AppColors
//                                               .deepPurple
//                                               : Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // ─── Map ───────────────────────────────────────
//           Expanded(
//             flex: 3,
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _currentPosition != null
//                         ? LatLng(
//                       _currentPosition!.latitude,
//                       _currentPosition!.longitude,
//                     )
//                         : const LatLng(28.6139, 77.2090),
//                     zoom: 14,
//                   ),
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                     if (_currentPosition != null) {
//                       controller.animateCamera(
//                         CameraUpdate.newLatLngZoom(
//                           LatLng(
//                             _currentPosition!.latitude,
//                             _currentPosition!.longitude,
//                           ),
//                           14,
//                         ),
//                       );
//                     }
//                   },
//                   markers: _markers,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   zoomControlsEnabled: false,
//                 ),
//
//                 // Loading overlay on map
//                 if (_isLoading)
//                   Container(
//                     color: Colors.white.withOpacity(0.5),
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment:
//                         MainAxisAlignment.center,
//                         children: [
//                           const CircularProgressIndicator(
//                             color: AppColors.deepPurple,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Finding safe places near you...',
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: AppColors.deepPurple,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           // ─── Places List ───────────────────────────────
//           Expanded(
//             flex: 2,
//             child: _isLoading
//                 ? const Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.deepPurple,
//               ),
//             )
//                 : _places.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment:
//                 MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.location_off_rounded,
//                     size: 48,
//                     color: AppColors.mediumGrey
//                         .withOpacity(0.5),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'No safe places found nearby',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: AppColors.mediumGrey,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton.icon(
//                     onPressed: () => _loadSafePlaces(
//                         type: _selectedType),
//                     icon: const Icon(
//                       Icons.refresh_rounded,
//                       color: AppColors.deepPurple,
//                     ),
//                     label: Text(
//                       'Try again',
//                       style: GoogleFonts.poppins(
//                         color: AppColors.deepPurple,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,
//               ),
//               itemCount: _places.length,
//               itemBuilder: (context, index) {
//                 return FadeInUp(
//                   duration: const Duration(
//                       milliseconds: 400),
//                   delay: Duration(
//                       milliseconds: index * 60),
//                   child: _buildPlaceCard(
//                       _places[index]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Place Card Widget ────────────────────────────────
//   Widget _buildPlaceCard(SafePlaceModel place) {
//     return GestureDetector(
//       onTap: () {
//         _mapController?.animateCamera(
//           CameraUpdate.newLatLngZoom(
//             LatLng(place.latitude, place.longitude),
//             16,
//           ),
//         );
//         _showPlaceDetails(place);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.deepPurple.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//
//             // Icon
//             Container(
//               width: 46,
//               height: 46,
//               decoration: BoxDecoration(
//                 color: _getTypeColor(place.type)
//                     .withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(
//                 _getTypeIcon(place.type),
//                 color: _getTypeColor(place.type),
//                 size: 24,
//               ),
//             ),
//
//             const SizedBox(width: 12),
//
//             // Name and Address
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     place.name,
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.darkGrey,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   if (place.address != null)
//                     Text(
//                       place.address!,
//                       style: GoogleFonts.poppins(
//                         fontSize: 11,
//                         color: AppColors.mediumGrey,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   if (place.isOpen != null)
//                     Text(
//                       place.isOpen!
//                           ? '🟢 Open Now'
//                           : '🔴 Closed',
//                       style: GoogleFonts.poppins(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(width: 8),
//
//             // Distance + Call Button
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 if (place.distance != null)
//                   Text(
//                     _formatDistance(place.distance),
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: _getTypeColor(place.type),
//                     ),
//                   ),
//                 const SizedBox(height: 4),
//                 GestureDetector(
//                   onTap: () => _navigateToPlace(place),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.deepPurple
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.directions_rounded,
//                           size: 12,
//                           color: AppColors.deepPurple,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Go',
//                           style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.deepPurple,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/safe_place_model.dart';
import '../../../data/services/api_service.dart';

class SafePlacesScreen extends StatefulWidget {
  const SafePlacesScreen({super.key});

  @override
  State<SafePlacesScreen> createState() =>
      _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen>
    with TickerProviderStateMixin {

  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<SafePlaceModel> _places = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isLocationFetching = true; // Swiggy-style animation
  String _selectedType = 'all';
  String _locationName = 'Fetching location...';

  // Animation controllers
  late AnimationController _locationPinController;
  late Animation<double> _locationPinAnimation;

  final List<Map<String, dynamic>> _filters = [
    {'type': 'all', 'label': 'All',
      'icon': Icons.location_on_rounded},
    {'type': 'police', 'label': 'Police',
      'icon': Icons.local_police_rounded},
    {'type': 'hospital', 'label': 'Hospital',
      'icon': Icons.local_hospital_rounded},
    {'type': 'mall', 'label': 'Mall',
      'icon': Icons.store_rounded},
  ];

  @override
  void initState() {
    super.initState();

    // Setup pin bounce animation
    _locationPinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _locationPinAnimation = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(CurvedAnimation(
      parent: _locationPinController,
      curve: Curves.easeInOut,
    ));

    _initialize();
  }

  @override
  void dispose() {
    _locationPinController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _loadSafePlaces(type: 'all');
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocationFetching = false);
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocationFetching = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLocationFetching = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    } catch (e) {
      setState(() => _isLocationFetching = false);
    }
  }

  Future<void> _loadSafePlaces({String type = 'all'}) async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.getSafePlaces(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      type: type == 'all' ? null : type,
      radius: 5000,
    );

    if (result['success'] == true) {
      final List<dynamic> data = result['places'];
      final places =
      data.map((p) => SafePlaceModel.fromJson(p)).toList();

      setState(() {
        _places = places;
        _isLoading = false;
        // ✅ Update location name from API response
        if (result['locationName'] != null) {
          _locationName = result['locationName'];
        }
      });

      _updateMarkers(places);
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarkers(List<SafePlaceModel> places) {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    for (final place in places) {
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(place.type),
          ),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address ?? place.type,
          ),
          onTap: () => _showPlaceDetails(place),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  double _getMarkerHue(String type) {
    switch (type) {
      case 'police':
        return BitmapDescriptor.hueBlue;
      case 'hospital':
        return BitmapDescriptor.hueRed;
      case 'mall':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'police':
        return const Color(0xFF1565C0);
      case 'hospital':
        return AppColors.sosRed;
      case 'mall':
        return AppColors.successGreen;
      default:
        return AppColors.deepPurple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'police':
        return Icons.local_police_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'mall':
        return Icons.store_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) return '${distance.toInt()}m away';
    return '${(distance / 1000).toStringAsFixed(1)}km away';
  }

  void _showPlaceDetails(SafePlaceModel place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: _getTypeColor(place.type)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTypeIcon(place.type),
                    color: _getTypeColor(place.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      if (place.address != null)
                        Text(
                          place.address!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      if (place.distance != null)
                        Text(
                          _formatDistance(place.distance),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(place.type),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (place.phone != null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _callPlace(place.phone!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.successGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                          Icons.call_rounded, size: 20),
                      label: Text('Call Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _navigateToPlace(place),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(
                        Icons.directions_rounded, size: 20),
                    label: Text('Navigate',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _callPlace(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _navigateToPlace(SafePlaceModel place) async {
    final Uri uri = Uri.parse(
      'https://maps.google.com/?q=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {

    // ✅ Show full screen location fetching animation
    if (_isLocationFetching) {
      return Scaffold(
        backgroundColor: AppColors.deepPurple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Bouncing pin animation
              AnimatedBuilder(
                animation: _locationPinAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0, _locationPinAnimation.value),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Pin shadow that shrinks/grows
              AnimatedBuilder(
                animation: _locationPinAnimation,
                builder: (context, child) {
                  final scale = 1.0 +
                      (_locationPinAnimation.value / 12)
                          .abs() *
                          0.3;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Text(
                'Getting your location...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Finding safe places near you',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ─── Purple Header ─────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    20, 16, 20, 20),
                child: Column(
                  children: [

                    // ── App Bar ──────────────────────────
                    FadeInDown(
                      duration:
                      const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pop(context),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ✅ Location Name like Swiggy
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _locationName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _isLoading
                                      ? 'Finding nearby places...'
                                      : '${_places.length} safe places found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Refresh Button
                          GestureDetector(
                            onTap: () => _loadSafePlaces(
                                type: _selectedType),
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.15),
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Filter Chips ─────────────────────
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 200),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                          _filters.map((filter) {
                            final isSelected =
                                _selectedType ==
                                    filter['type'];
                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                  right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedType =
                                    filter['type']
                                    as String;
                                  });
                                  _loadSafePlaces(
                                    type: filter['type']
                                    as String,
                                  );
                                },
                                child: Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white
                                        .withOpacity(
                                        0.2),
                                    borderRadius:
                                    BorderRadius.circular(
                                        20),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Icon(
                                        filter['icon']
                                        as IconData,
                                        size: 16,
                                        color: isSelected
                                            ? AppColors
                                            .deepPurple
                                            : Colors.white,
                                      ),
                                      const SizedBox(
                                          width: 6),
                                      Text(
                                        filter['label']
                                        as String,
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 13,
                                          fontWeight:
                                          FontWeight.w600,
                                          color: isSelected
                                              ? AppColors
                                              .deepPurple
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Map ───────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                        : const LatLng(28.6139, 77.2090),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_currentPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          14,
                        ),
                      );
                    }
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
                if (_isLoading)
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Finding safe places...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ─── Places List ───────────────────────────────
          Expanded(
            flex: 2,
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.deepPurple,
              ),
            )
                : _places.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 48,
                    color: AppColors.mediumGrey
                        .withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No safe places found nearby',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        _loadSafePlaces(
                            type: _selectedType),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.deepPurple,
                    ),
                    label: Text(
                      'Try again',
                      style: GoogleFonts.poppins(
                        color: AppColors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: _places.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  duration: const Duration(
                      milliseconds: 400),
                  delay: Duration(
                      milliseconds: index * 60),
                  child: _buildPlaceCard(
                      _places[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(SafePlaceModel place) {
    return GestureDetector(
      onTap: () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(place.latitude, place.longitude),
            16,
          ),
        );
        _showPlaceDetails(place);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPurple.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _getTypeColor(place.type)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getTypeIcon(place.type),
                color: _getTypeColor(place.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (place.address != null)
                    Text(
                      place.address!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.mediumGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (place.isOpen != null)
                    Text(
                      place.isOpen!
                          ? '🟢 Open Now'
                          : '🔴 Closed',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (place.distance != null)
                  Text(
                    _formatDistance(place.distance),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(place.type),
                    ),
                  ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _navigateToPlace(place),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_rounded,
                          size: 12,
                          color: AppColors.deepPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Go',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class HelplinesScreen extends StatefulWidget {
  const HelplinesScreen({super.key});

  @override
  State<HelplinesScreen> createState() =>
      _HelplinesScreenState();
}

class _HelplinesScreenState extends State<HelplinesScreen> {

  String _selectedCategory = 'all';

  // ─── Helpline Categories ─────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'All',
      'icon': Icons.apps_rounded},
    {'id': 'women', 'label': 'Women',
      'icon': Icons.woman_rounded},
    {'id': 'emergency', 'label': 'Emergency',
      'icon': Icons.emergency_rounded},
    {'id': 'medical', 'label': 'Medical',
      'icon': Icons.medical_services_rounded},
    {'id': 'legal', 'label': 'Legal',
      'icon': Icons.gavel_rounded},
  ];

  // ─── All Helplines Data ───────────────────────────────
  final List<Map<String, dynamic>> _helplines = [

    // Women Helplines
    {
      'name': 'Women Helpline',
      'number': '1091',
      'description': '24x7 helpline for women in distress',
      'category': 'women',
      'color': const Color(0xFFE91E8C),
      'icon': Icons.woman_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Women Helpline (Domestic Abuse)',
      'number': '181',
      'description': 'Support for domestic violence victims',
      'category': 'women',
      'color': const Color(0xFFE91E8C),
      'icon': Icons.home_rounded,
      'isEmergency': false,
    },
    {
      'name': 'NCW Helpline',
      'number': '7827170170',
      'description': 'National Commission for Women',
      'category': 'women',
      'color': const Color(0xFFE91E8C),
      'icon': Icons.people_rounded,
      'isEmergency': false,
    },
    {
      'name': 'Nirbhaya Helpline',
      'number': '112',
      'description': 'Emergency helpline for women safety',
      'category': 'women',
      'color': const Color(0xFFE91E8C),
      'icon': Icons.shield_rounded,
      'isEmergency': true,
    },

    // Emergency Helplines
    {
      'name': 'National Emergency',
      'number': '112',
      'description': 'All in one emergency number',
      'category': 'emergency',
      'color': AppColors.sosRed,
      'icon': Icons.emergency_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Police',
      'number': '100',
      'description': 'Police emergency helpline',
      'category': 'emergency',
      'color': const Color(0xFF1565C0),
      'icon': Icons.local_police_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Fire Brigade',
      'number': '101',
      'description': 'Fire emergency services',
      'category': 'emergency',
      'color': const Color(0xFFE65100),
      'icon': Icons.local_fire_department_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Disaster Management',
      'number': '108',
      'description': 'National disaster response',
      'category': 'emergency',
      'color': const Color(0xFF6A1B9A),
      'icon': Icons.warning_rounded,
      'isEmergency': false,
    },

    // Medical Helplines
    {
      'name': 'Ambulance',
      'number': '102',
      'description': 'Free ambulance service',
      'category': 'medical',
      'color': AppColors.sosRed,
      'icon': Icons.local_hospital_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Medical Emergency',
      'number': '108',
      'description': 'Emergency medical services',
      'category': 'medical',
      'color': AppColors.sosRed,
      'icon': Icons.medical_services_rounded,
      'isEmergency': true,
    },
    {
      'name': 'Blood Bank',
      'number': '104',
      'description': 'Blood bank and donation helpline',
      'category': 'medical',
      'color': const Color(0xFFC62828),
      'icon': Icons.bloodtype_rounded,
      'isEmergency': false,
    },
    {
      'name': 'Mental Health Helpline',
      'number': '14416',
      'description': 'iCall mental health support',
      'category': 'medical',
      'color': const Color(0xFF00897B),
      'icon': Icons.psychology_rounded,
      'isEmergency': false,
    },

    // Legal Helplines
    {
      'name': 'Legal Aid',
      'number': '15100',
      'description': 'Free legal aid helpline',
      'category': 'legal',
      'color': const Color(0xFF1565C0),
      'icon': Icons.gavel_rounded,
      'isEmergency': false,
    },
    {
      'name': 'Cyber Crime',
      'number': '1930',
      'description': 'Cyber crime reporting helpline',
      'category': 'legal',
      'color': const Color(0xFF1565C0),
      'icon': Icons.computer_rounded,
      'isEmergency': false,
    },
    {
      'name': 'Child Helpline',
      'number': '1098',
      'description': 'CHILDLINE India Foundation',
      'category': 'legal',
      'color': const Color(0xFF2E7D32),
      'icon': Icons.child_care_rounded,
      'isEmergency': false,
    },
    {
      'name': 'Senior Citizen Helpline',
      'number': '14567',
      'description': 'Elder care helpline',
      'category': 'legal',
      'color': const Color(0xFF6A1B9A),
      'icon': Icons.elderly_rounded,
      'isEmergency': false,
    },
  ];

  // ─── Get Filtered Helplines ───────────────────────────
  List<Map<String, dynamic>> get _filteredHelplines {
    if (_selectedCategory == 'all') return _helplines;
    return _helplines
        .where((h) => h['category'] == _selectedCategory)
        .toList();
  }

  // ─── Call Helpline ────────────────────────────────────
  Future<void> _callHelpline(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not launch call to $number',
              style: GoogleFonts.poppins(
                  color: Colors.white),
            ),
            backgroundColor: AppColors.sosRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ─── Purple Header ───────────────────────────
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

                    // ── App Bar ────────────────────────
                    FadeInDown(
                      duration:
                      const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons
                                    .arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Helplines',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'One tap emergency calling',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Emergency Quick Buttons ────────
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          _buildEmergencyQuickButton(
                            label: 'Police',
                            number: '100',
                            icon: Icons.local_police_rounded,
                            color: const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 10),
                          _buildEmergencyQuickButton(
                            label: 'Ambulance',
                            number: '102',
                            icon: Icons
                                .local_hospital_rounded,
                            color: AppColors.sosRed,
                          ),
                          const SizedBox(width: 10),
                          _buildEmergencyQuickButton(
                            label: 'Women',
                            number: '1091',
                            icon: Icons.woman_rounded,
                            color:
                            const Color(0xFFE91E8C),
                          ),
                          const SizedBox(width: 10),
                          _buildEmergencyQuickButton(
                            label: 'Emergency',
                            number: '112',
                            icon: Icons.emergency_rounded,
                            color: AppColors.sosRed,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Category Filter ────────────────
                    FadeInUp(
                      duration:
                      const Duration(milliseconds: 600),
                      delay:
                      const Duration(milliseconds: 300),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                          _categories.map((category) {
                            final isSelected =
                                _selectedCategory ==
                                    category['id'];
                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                  right: 10),
                              child: GestureDetector(
                                onTap: () => setState(() =>
                                _selectedCategory =
                                category['id']
                                as String),
                                child: Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white
                                        .withOpacity(
                                        0.2),
                                    borderRadius:
                                    BorderRadius
                                        .circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                    MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category['icon']
                                        as IconData,
                                        size: 15,
                                        color: isSelected
                                            ? AppColors
                                            .deepPurple
                                            : Colors.white,
                                      ),
                                      const SizedBox(
                                          width: 5),
                                      Text(
                                        category['label']
                                        as String,
                                        style: GoogleFonts
                                            .poppins(
                                          fontSize: 12,
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

          // ─── Helplines List ──────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 20),
              itemCount: _filteredHelplines.length,
              itemBuilder: (context, index) {
                final helpline = _filteredHelplines[index];
                return FadeInUp(
                  duration:
                  const Duration(milliseconds: 400),
                  delay: Duration(
                      milliseconds: index * 60),
                  child:
                  _buildHelplineCard(helpline),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Emergency Quick Button ───────────────────────────
  Widget _buildEmergencyQuickButton({
    required String label,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _callHelpline(number),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpline Card ────────────────────────────────────
  Widget _buildHelplineCard(
      Map<String, dynamic> helpline) {
    final color = helpline['color'] as Color;
    final isEmergency = helpline['isEmergency'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [

              // ── Color Strip ──────────────────────────
              Container(
                width: 5,
                color: color,
              ),

              // ── Content ──────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [

                      // Icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: Icon(
                          helpline['icon'] as IconData,
                          color: color,
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Name and Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    helpline['name']
                                    as String,
                                    style:
                                    GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.bold,
                                      color:
                                      AppColors.darkGrey,
                                    ),
                                  ),
                                ),
                                if (isEmergency)
                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration:
                                    BoxDecoration(
                                      color: AppColors
                                          .sosRed
                                          .withOpacity(0.1),
                                      borderRadius:
                                      BorderRadius
                                          .circular(8),
                                    ),
                                    child: Text(
                                      '24x7',
                                      style: GoogleFonts
                                          .poppins(
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.bold,
                                        color:
                                        AppColors.sosRed,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              helpline['description']
                              as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Number
                            Text(
                              helpline['number'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Call Button
                      GestureDetector(
                        onTap: () => _callHelpline(
                          helpline['number'] as String,
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius:
                            BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: Colors.white,
                            size: 22,
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
      ),
    );
  }
}
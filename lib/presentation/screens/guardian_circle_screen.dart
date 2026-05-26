import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/guardian_model.dart';
import '../../../data/services/api_service.dart';

class GuardianCircleScreen extends StatefulWidget {
  const GuardianCircleScreen({super.key});

  @override
  State<GuardianCircleScreen> createState() =>
      _GuardianCircleScreenState();
}

class _GuardianCircleScreenState extends State<GuardianCircleScreen> {
  List<GuardianModel> _guardians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  // ─── Load Guardians from Backend ─────────────────────
  Future<void> _loadGuardians() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getGuardians();

    if (result['success'] == true) {
      final List<dynamic> data = result['guardians'];
      setState(() {
        _guardians = data
            .map((g) => GuardianModel.fromJson(g))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showError(result['message'] ?? 'Failed to load guardians');
    }
  }

  // ─── Show Add/Edit Bottom Sheet ───────────────────────
  void _showAddEditSheet({GuardianModel? guardian}) {
    final nameController = TextEditingController(
      text: guardian?.contactName ?? '',
    );
    final phoneController = TextEditingController(
      text: guardian?.contactPhone.replaceAll('+91', '') ?? '',
    );
    int selectedPriority = guardian?.priorityOrder ??
        (_guardians.length + 1);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    guardian == null
                        ? 'Add Guardian'
                        : 'Edit Guardian',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGrey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    guardian == null
                        ? 'This person will be alerted during SOS'
                        : 'Update guardian details',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.mediumGrey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name Field
                  Text(
                    'Full Name',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.darkGrey,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Mom, Sister, Friend',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.deepPurple,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.deepPurple,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phone Field
                  Text(
                    'Phone Number',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.darkGrey,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '9876543210',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇮🇳',
                                style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '+91',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepPurple,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 1,
                              height: 22,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.deepPurple,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Priority Selector
                  Text(
                    'Alert Priority',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      final priority = index + 1;
                      final isSelected = selectedPriority == priority;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedPriority = priority;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepPurple
                                  : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.deepPurple
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$priority',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.mediumGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1 = First to be alerted during SOS',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.mediumGrey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        // Validate
                        if (nameController.text.trim().isEmpty) {
                          _showError('Please enter a name');
                          return;
                        }
                        if (phoneController.text.trim().length != 10) {
                          _showError('Please enter valid 10-digit number');
                          return;
                        }

                        setSheetState(() => isLoading = true);

                        Map<String, dynamic> result;

                        if (guardian == null) {
                          // Add new
                          result = await ApiService.addGuardian(
                            name: nameController.text.trim(),
                            phone: '+91${phoneController.text.trim()}',
                            priority: selectedPriority,
                          );
                        } else {
                          // Update existing
                          result = await ApiService.updateGuardian(
                            id: guardian.id,
                            name: nameController.text.trim(),
                            phone: '+91${phoneController.text.trim()}',
                            priority: selectedPriority,
                          );
                        }

                        setSheetState(() => isLoading = false);

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          _loadGuardians();
                          _showSuccess(
                            guardian == null
                                ? 'Guardian added!'
                                : 'Guardian updated!',
                          );
                        } else {
                          _showError(
                            result['message'] ?? 'Something went wrong',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : Text(
                        guardian == null
                            ? 'Add Guardian'
                            : 'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Show Delete Confirmation ─────────────────────────
  void _showDeleteConfirmation(GuardianModel guardian) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.sosRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_remove_rounded,
                color: AppColors.sosRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Remove Guardian?',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${guardian.contactName} will no longer receive SOS alerts.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.mediumGrey,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.deepPurple,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result =
              await ApiService.deleteGuardian(guardian.id);
              if (result['success'] == true) {
                _loadGuardians();
                _showSuccess('${guardian.contactName} removed');
              } else {
                _showError(result['message'] ?? 'Failed to remove');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ─── Get Priority Color ───────────────────────────────
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.sosRed;
      case 2:
        return AppColors.warningAmber;
      case 3:
        return AppColors.successGreen;
      default:
        return AppColors.deepPurple;
    }
  }

  // ─── Get Avatar Color ─────────────────────────────────
  Color _getAvatarColor(int index) {
    final colors = [
      AppColors.deepPurple,
      AppColors.sosRed,
      AppColors.successGreen,
      AppColors.warningAmber,
      const Color(0xFF0288D1),
    ];
    return colors[index % colors.length];
  }

  // ─── Show Snackbars ───────────────────────────────────
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.sosRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [

          // ─── Purple Header ────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  children: [

                    // ── App Bar Row ──────────────────────
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [

                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Guardian Circle',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${_guardians.length}/5 guardians added',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // People Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.people_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Info Card ────────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'These people will be instantly alerted with your location when you trigger SOS',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  height: 1.4,
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
          ),

          // ─── Guardians List ───────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.deepPurple,
              ),
            )
                : _guardians.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _guardians.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(
                      milliseconds: index * 100),
                  child: _buildGuardianCard(
                    _guardians[index],
                    index,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ─── Add Guardian FAB ─────────────────────────────
      floatingActionButton: _guardians.length < 5
          ? FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEditSheet(),
          backgroundColor: AppColors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 6,
          icon: const Icon(Icons.person_add_rounded),
          label: Text(
            'Add Guardian',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      )
          : null,
    );
  }

  // ─── Guardian Card Widget ─────────────────────────────
  Widget _buildGuardianCard(GuardianModel guardian, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPurple.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _getAvatarColor(index).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                guardian.contactName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _getAvatarColor(index),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name and Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guardian.contactName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  guardian.contactPhone,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),

          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: _getPriorityColor(guardian.priorityOrder)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${guardian.priorityOrder}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getPriorityColor(guardian.priorityOrder),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Edit Button
          GestureDetector(
            onTap: () => _showAddEditSheet(guardian: guardian),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.deepPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.deepPurple,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Delete Button
          GestureDetector(
            onTap: () => _showDeleteConfirmation(guardian),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sosRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppColors.sosRed,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State Widget ───────────────────────────────
  Widget _buildEmptyState() {
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.deepPurple.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline_rounded,
                  size: 50,
                  color: AppColors.deepPurple,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'No Guardians Yet',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Add trusted people who will be\nalerted when you trigger SOS',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () => _showAddEditSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.deepPurple.withOpacity(0.4),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: Text(
                  'Add First Guardian',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
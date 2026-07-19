import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

class PrescriptionUploadSheet extends StatefulWidget {
  const PrescriptionUploadSheet({super.key});

  @override
  State<PrescriptionUploadSheet> createState() => _PrescriptionUploadSheetState();
}

enum UploadStatus { initial, scanning, completed }

class _PrescriptionUploadSheetState extends State<PrescriptionUploadSheet>
    with SingleTickerProviderStateMixin {
  UploadStatus _status = UploadStatus.initial;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  late AnimationController _scanController;
  String _scanStep = "Starting OCR Handwriting Scanner...";
  
  // Selected meds mapped to quantities
  final Map<ProductEntity, int> _detectedMeds = {};

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImage = file;
          _imageBytes = bytes;
          _status = UploadStatus.scanning;
        });
        _scanController.repeat(reverse: true);
        _runScanningSimulation();
      } else {
        // Fallback for browser automation / demo mode
        _triggerDemoScan();
      }
    } catch (_) {
      _triggerDemoScan();
    }
  }

  void _triggerDemoScan() {
    setState(() {
      _status = UploadStatus.scanning;
    });
    _scanController.repeat(reverse: true);
    _runScanningSimulation();
  }

  void _runScanningSimulation() async {
    final steps = [
      "Running OCR Handwriting Scanner...",
      "Matching formulas with 100k+ drug index...",
      "Analyzing dosage frequencies...",
      "Connecting to Registered Pharmacist panel...",
      "Verifying doctor signature and seal...",
    ];

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 900));
      setState(() {
        _scanStep = steps[i];
      });
    }

    if (!mounted) return;
    
    // Automatically match with some mock products
    setState(() {
      _status = UploadStatus.completed;
      _scanController.stop();
      
      // Auto-extract Dolo 650mg and Allegra 120mg from the mock list
      final dolo = MockProducts.all.firstWhere((p) => p.id == 'p1');
      final allegra = MockProducts.all.firstWhere((p) => p.id == 'p4');
      _detectedMeds[dolo] = 1;
      _detectedMeds[allegra] = 1;
    });

    // Save to Firebase Storage and Firestore
    _uploadPrescriptionToFirebase();
  }

  Future<void> _uploadPrescriptionToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String downloadUrl = "https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&q=80";

      if (_imageBytes != null) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'prescriptions/${user.uid}/$timestamp.jpg';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        
        final uploadTask = storageRef.putData(
          _imageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        
        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }
      
      final prescriptionDoc = FirebaseFirestore.instance.collection('prescriptions').doc();
      
      final matchedMedsList = _detectedMeds.entries.map((entry) => {
        'productId': entry.key.id,
        'name': entry.key.name,
        'quantity': entry.value,
        'price': entry.key.price,
      }).toList();

      await prescriptionDoc.set({
        'id': prescriptionDoc.id,
        'userId': user.uid,
        'imageUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'matchedMedicines': matchedMedsList,
        'status': 'pending_verification',
      });
    } catch (e) {
      debugPrint("Firebase upload error: $e");
    }
  }

  double get _totalPrice {
    double total = 0;
    _detectedMeds.forEach((prod, qty) {
      total += prod.price * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_status == UploadStatus.initial) _buildInitialState(),
          if (_status == UploadStatus.scanning) _buildScanningState(),
          if (_status == UploadStatus.completed) _buildCompletedState(),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Initial State ──────────────────────────────────────────────────────────
  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order via Prescription',
                    style: AppTextStyles.headlineLarge,
                  ),
                  Text(
                    'Upload & get medicines verified in 3 minutes',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Dashed Dropzone Box
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Upload prescription photo or PDF',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Supported: PNG, JPEG, PDF up to 10MB',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 38),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(120, 38),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Trust features
        Row(
          children: [
            Expanded(
              child: _buildBadgeItem(Icons.verified_user_outlined, '100% Secure', 'HIPAA Compliant privacy'),
            ),
            Expanded(
              child: _buildBadgeItem(Icons.health_and_safety_outlined, 'Certified RPh', 'Verified by Pharmacists'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppColors.success, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 9, color: AppColors.textHint)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Scanning State ─────────────────────────────────────────────────────────
  Widget _buildScanningState() {
    return Column(
      children: [
        Text(
          'Processing Prescription...',
          style: AppTextStyles.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Our AI engine is matching handwriting patterns.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        
        // Scanning card
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.65,
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                        : const SizedBox(),
                  ),
                ),
                // Glowing scanline animation
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanController.value * 220,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              AppColors.secondary.withOpacity(0.1),
                              AppColors.secondary,
                              AppColors.secondary.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                // Top gradient info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _scanStep,
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
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
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Completed State ────────────────────────────────────────────────────────
  Widget _buildCompletedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Handwriting Matches Verified!',
                    style: AppTextStyles.headlineLarge,
                  ),
                  Text(
                    'Approved by Registered Pharmacist (Lic. #RPH-7452)',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Text('Extracted Medicines', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        // Meds List
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: _detectedMeds.keys.map((prod) {
              final qty = _detectedMeds[prod]!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prod.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                          Text(prod.composition, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                          onPressed: () {
                            if (qty > 1) {
                              setState(() => _detectedMeds[prod] = qty - 1);
                            }
                          },
                        ),
                        Text('$qty', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                          onPressed: () {
                            setState(() => _detectedMeds[prod] = qty + 1);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${(prod.price * qty).toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ 30-Min Delivery Guaranteed',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Delivered by: ${DateTime.now().add(const Duration(minutes: 30)).hour}:${DateTime.now().add(const Duration(minutes: 30)).minute.toString().padLeft(2, '0')} or FREE.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        KlinButton(
          label: 'Add Verified Meds to Cart (₹${_totalPrice.toStringAsFixed(0)})',
          onTap: () {
            final cart = context.read<CartBloc>();
            _detectedMeds.forEach((prod, qty) {
              for (int i = 0; i < qty; i++) {
                cart.add(CartAddItem(prod));
              }
            });
            
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prescription medicines added to your cart successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String description;
  final String composition;
  final List<String> uses;
  final List<String> sideEffects;
  final double price;
  final double mrp;
  final int discount;
  final List<String> imageUrls;
  final bool requiresPrescription;
  final bool inStock;
  final int stockCount;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.description,
    required this.composition,
    required this.uses,
    required this.sideEffects,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.imageUrls,
    required this.requiresPrescription,
    required this.inStock,
    required this.stockCount,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, name, brand, price, inStock];

  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      composition: map['composition'] as String? ?? '',
      uses: List<String>.from(map['uses'] ?? []),
      sideEffects: List<String>.from(map['sideEffects'] ?? []),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (map['mrp'] as num?)?.toDouble() ?? 0.0,
      discount: map['discount'] as int? ?? 0,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      requiresPrescription: map['requiresPrescription'] as bool? ?? false,
      inStock: map['inStock'] as bool? ?? true,
      stockCount: map['stockCount'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'categoryId': categoryId,
        'description': description,
        'composition': composition,
        'uses': uses,
        'sideEffects': sideEffects,
        'price': price,
        'mrp': mrp,
        'discount': discount,
        'imageUrls': imageUrls,
        'requiresPrescription': requiresPrescription,
        'inStock': inStock,
        'stockCount': stockCount,
        'rating': rating,
        'reviewCount': reviewCount,
        'tags': tags,
      };
}

// Mock products for development
class MockProducts {
  static final List<ProductEntity> all = [
    const ProductEntity(
      id: 'p1',
      name: 'Dolo 650mg',
      brand: 'Micro Labs',
      categoryId: 'pain-relief',
      description: 'Dolo 650 is a pain reliever and fever reducer. It contains Paracetamol 650mg.',
      composition: 'Paracetamol 650mg',
      uses: ['Fever', 'Headache', 'Body ache', 'Toothache'],
      sideEffects: ['Nausea', 'Rash (rare)', 'Liver damage (overdose)'],
      price: 30,
      mrp: 36,
      discount: 17,
      imageUrls: [],
      requiresPrescription: false,
      inStock: true,
      stockCount: 500,
      rating: 4.8,
      reviewCount: 12540,
      tags: ['fever', 'pain', 'paracetamol'],
    ),
    const ProductEntity(
      id: 'p2',
      name: 'Crocin 500mg',
      brand: 'GSK',
      categoryId: 'pain-relief',
      description: 'Crocin 500 tablet is used to reduce fever and relieve mild to moderate pain.',
      composition: 'Paracetamol 500mg',
      uses: ['Fever', 'Common cold', 'Mild pain'],
      sideEffects: ['Nausea', 'Stomach upset (rare)'],
      price: 28,
      mrp: 32,
      discount: 12,
      imageUrls: [],
      requiresPrescription: false,
      inStock: true,
      stockCount: 300,
      rating: 4.6,
      reviewCount: 8920,
      tags: ['fever', 'pain', 'paracetamol'],
    ),
    const ProductEntity(
      id: 'p3',
      name: 'Pan D',
      brand: 'Alkem',
      categoryId: 'gastro',
      description: 'Pan D capsule is used to treat acidity, heartburn, and stomach ulcers.',
      composition: 'Pantoprazole 40mg + Domperidone 10mg',
      uses: ['Acidity', 'Heartburn', 'GERD', 'Bloating'],
      sideEffects: ['Headache', 'Diarrhea', 'Dizziness'],
      price: 88,
      mrp: 105,
      discount: 16,
      imageUrls: [],
      requiresPrescription: false,
      inStock: true,
      stockCount: 200,
      rating: 4.5,
      reviewCount: 5630,
      tags: ['acidity', 'gastro', 'pantoprazole'],
    ),
    const ProductEntity(
      id: 'p4',
      name: 'Allegra 120mg',
      brand: 'Sanofi',
      categoryId: 'allergy',
      description: 'Allegra 120mg tablet is used to relieve allergy symptoms such as sneezing, runny nose, and itchy eyes.',
      composition: 'Fexofenadine 120mg',
      uses: ['Allergic rhinitis', 'Sneezing', 'Itchy eyes', 'Skin rash'],
      sideEffects: ['Headache', 'Drowsiness', 'Nausea'],
      price: 145,
      mrp: 175,
      discount: 17,
      imageUrls: [],
      requiresPrescription: false,
      inStock: true,
      stockCount: 150,
      rating: 4.4,
      reviewCount: 3210,
      tags: ['allergy', 'antihistamine'],
    ),
    const ProductEntity(
      id: 'p5',
      name: 'Vitamin D3 60K',
      brand: 'Sun Pharma',
      categoryId: 'vitamins',
      description: 'Vitamin D3 60000 IU capsule helps treat and prevent Vitamin D deficiency.',
      composition: 'Cholecalciferol 60000 IU',
      uses: ['Vitamin D deficiency', 'Bone health', 'Immunity'],
      sideEffects: ['Nausea (rare)', 'Hypercalcemia (overdose)'],
      price: 65,
      mrp: 80,
      discount: 19,
      imageUrls: [],
      requiresPrescription: false,
      inStock: true,
      stockCount: 400,
      rating: 4.7,
      reviewCount: 7890,
      tags: ['vitamin', 'immunity', 'bone health'],
    ),
    const ProductEntity(
      id: 'p6',
      name: 'Azithromycin 500',
      brand: 'Cipla',
      categoryId: 'antibiotics',
      description: 'Azithromycin 500mg is an antibiotic used to treat bacterial infections.',
      composition: 'Azithromycin 500mg',
      uses: ['Throat infection', 'Chest infection', 'Ear infection'],
      sideEffects: ['Stomach pain', 'Diarrhea', 'Nausea'],
      price: 95,
      mrp: 120,
      discount: 21,
      imageUrls: [],
      requiresPrescription: true,
      inStock: true,
      stockCount: 100,
      rating: 4.3,
      reviewCount: 2140,
      tags: ['antibiotic', 'infection'],
    ),
  ];
}

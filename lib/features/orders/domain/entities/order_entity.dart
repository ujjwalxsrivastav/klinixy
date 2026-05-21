import 'package:equatable/equatable.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // placed|confirmed|packed|picked|outForDelivery|delivered|cancelled
  final AddressEntity deliveryAddress;
  final String paymentMethod; // cod|online
  final String paymentStatus; // pending|paid
  final DateTime placedAt;
  final DateTime? estimatedDelivery;
  final Map<String, double>? deliveryPartnerLocation;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.placedAt,
    this.estimatedDelivery,
    this.deliveryPartnerLocation,
  });

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'items': items
            .map((i) => {
                  'productId': i.product.id,
                  'productName': i.product.name,
                  'brand': i.product.brand,
                  'price': i.product.price,
                  'quantity': i.quantity,
                })
            .toList(),
        'totalAmount': totalAmount,
        'status': status,
        'deliveryAddress': deliveryAddress.toMap(),
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'placedAt': placedAt.toIso8601String(),
        'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      };
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

// Cart item model
class CartItem extends Equatable {
  final ProductEntity product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({ProductEntity? product, int? quantity}) => CartItem(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  double get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [product.id, quantity];
}

// ── Events ────────────────────────────────────────────────────────
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartAddItem extends CartEvent {
  final ProductEntity product;
  const CartAddItem(this.product);
  @override
  List<Object?> get props => [product.id];
}

class CartRemoveItem extends CartEvent {
  final String productId;
  const CartRemoveItem(this.productId);
  @override
  List<Object?> get props => [productId];
}

class CartUpdateQuantity extends CartEvent {
  final String productId;
  final int quantity;
  const CartUpdateQuantity(this.productId, this.quantity);
  @override
  List<Object?> get props => [productId, quantity];
}

class CartClear extends CartEvent {
  const CartClear();
}

// ── State ─────────────────────────────────────────────────────────
class CartState extends Equatable {
  final List<CartItem> items;
  final String? couponCode;
  final double couponDiscount;

  const CartState({
    this.items = const [],
    this.couponCode,
    this.couponDiscount = 0,
  });

  CartState copyWith({
    List<CartItem>? items,
    String? couponCode,
    double? couponDiscount,
  }) =>
      CartState(
        items: items ?? this.items,
        couponCode: couponCode ?? this.couponCode,
        couponDiscount: couponDiscount ?? this.couponDiscount,
      );

  double get subtotal => items.fold(0, (sum, i) => sum + i.totalPrice);
  double get deliveryCharge => subtotal >= 499 ? 0 : 30;
  double get total => subtotal + deliveryCharge - couponDiscount;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  bool get isEmpty => items.isEmpty;

  int quantityOf(String productId) {
    try {
      return items.firstWhere((i) => i.product.id == productId).quantity;
    } catch (_) {
      return 0;
    }
  }

  @override
  List<Object?> get props => [items, couponCode, couponDiscount];
}

// ── BLoC ──────────────────────────────────────────────────────────
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAddItem>(_onAdd);
    on<CartRemoveItem>(_onRemove);
    on<CartUpdateQuantity>(_onUpdate);
    on<CartClear>(_onClear);
  }

  void _onAdd(CartAddItem event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == event.product.id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: event.product, quantity: 1));
    }
    emit(state.copyWith(items: items));
  }

  void _onRemove(CartRemoveItem event, Emitter<CartState> emit) {
    final items =
        state.items.where((i) => i.product.id != event.productId).toList();
    emit(state.copyWith(items: items));
  }

  void _onUpdate(CartUpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(CartRemoveItem(event.productId));
      return;
    }
    final items = List<CartItem>.from(state.items);
    final idx = items.indexWhere((i) => i.product.id == event.productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: event.quantity);
    }
    emit(state.copyWith(items: items));
  }

  void _onClear(CartClear event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}

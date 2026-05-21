import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klinixy/core/utils/app_constants.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/orders/domain/entities/address_entity.dart';
import 'package:klinixy/features/orders/domain/entities/order_entity.dart';

// ── Events ─────────────────────────────────────────────────────────
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class CheckoutSelectAddress extends CheckoutEvent {
  final AddressEntity address;
  const CheckoutSelectAddress(this.address);
  @override
  List<Object?> get props => [address];
}

class CheckoutSelectPayment extends CheckoutEvent {
  final String method; // cod | online
  const CheckoutSelectPayment(this.method);
  @override
  List<Object?> get props => [method];
}

class CheckoutPlaceOrder extends CheckoutEvent {
  final CartState cartState;
  const CheckoutPlaceOrder(this.cartState);
}

// ── State ──────────────────────────────────────────────────────────
class CheckoutState extends Equatable {
  final AddressEntity? selectedAddress;
  final String paymentMethod;
  final bool isLoading;
  final String? error;
  final String? placedOrderId;

  const CheckoutState({
    this.selectedAddress,
    this.paymentMethod = 'cod',
    this.isLoading = false,
    this.error,
    this.placedOrderId,
  });

  CheckoutState copyWith({
    AddressEntity? selectedAddress,
    String? paymentMethod,
    bool? isLoading,
    String? error,
    String? placedOrderId,
  }) =>
      CheckoutState(
        selectedAddress: selectedAddress ?? this.selectedAddress,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        placedOrderId: placedOrderId ?? this.placedOrderId,
      );

  bool get canPlaceOrder => selectedAddress != null && !isLoading;

  @override
  List<Object?> get props =>
      [selectedAddress, paymentMethod, isLoading, error, placedOrderId];
}

// ── BLoC ───────────────────────────────────────────────────────────
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CheckoutBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const CheckoutState()) {
    on<CheckoutSelectAddress>(_onSelectAddress);
    on<CheckoutSelectPayment>(_onSelectPayment);
    on<CheckoutPlaceOrder>(_onPlaceOrder);
  }

  void _onSelectAddress(
      CheckoutSelectAddress event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(selectedAddress: event.address));
  }

  void _onSelectPayment(
      CheckoutSelectPayment event, Emitter<CheckoutState> emit) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  Future<void> _onPlaceOrder(
      CheckoutPlaceOrder event, Emitter<CheckoutState> emit) async {
    if (state.selectedAddress == null) return;

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Generate order ID
      final orderRef =
          _firestore.collection(AppConstants.ordersCollection).doc();

      final order = OrderEntity(
        id: orderRef.id,
        userId: uid,
        items: event.cartState.items,
        totalAmount: event.cartState.total,
        status: 'placed',
        deliveryAddress: state.selectedAddress!,
        paymentMethod: state.paymentMethod,
        paymentStatus: state.paymentMethod == 'cod' ? 'pending' : 'paid',
        placedAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(minutes: 30)),
      );

      await orderRef.set(order.toMap());

      emit(state.copyWith(isLoading: false, placedOrderId: orderRef.id));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, error: 'Failed to place order. Try again.'));
    }
  }
}

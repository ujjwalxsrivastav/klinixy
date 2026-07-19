import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

// ── Events ────────────────────────────────────────────────────────
abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class WishlistToggleItem extends WishlistEvent {
  final ProductEntity product;
  const WishlistToggleItem(this.product);
  @override
  List<Object?> get props => [product.id];
}

class WishlistClear extends WishlistEvent {
  const WishlistClear();
}

// ── State ─────────────────────────────────────────────────────────
class WishlistState extends Equatable {
  final List<ProductEntity> items;

  const WishlistState({this.items = const []});

  WishlistState copyWith({List<ProductEntity>? items}) =>
      WishlistState(items: items ?? this.items);

  bool isWishlisted(String productId) {
    return items.any((p) => p.id == productId);
  }

  @override
  List<Object?> get props => [items];
}

// ── BLoC ──────────────────────────────────────────────────────────
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(const WishlistState()) {
    on<WishlistToggleItem>(_onToggle);
    on<WishlistClear>(_onClear);
  }

  void _onToggle(WishlistToggleItem event, Emitter<WishlistState> emit) {
    final list = List<ProductEntity>.from(state.items);
    final idx = list.indexWhere((p) => p.id == event.product.id);
    if (idx != -1) {
      list.removeAt(idx);
    } else {
      list.add(event.product);
    }
    emit(state.copyWith(items: list));
  }

  void _onClear(WishlistClear event, Emitter<WishlistState> emit) {
    emit(const WishlistState());
  }
}

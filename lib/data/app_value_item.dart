
import 'package:equatable/equatable.dart';

class AppValueItem extends Equatable {
  final String label;
  final dynamic value;

  const AppValueItem({required this.label, required this.value});

  @override
  List<Object> get props => [value];
}

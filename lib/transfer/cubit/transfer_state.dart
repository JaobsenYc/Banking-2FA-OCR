part of 'transfer_cubit.dart';

@immutable
sealed class TransferState {}

final class TransferInitial extends TransferState {}

final class TransferLoading extends TransferState {}

final class TransferCreated extends TransferState {
  final String id;
  final String payeeFullName;
  final int sortCode;
  final String accountNumber;
  final String amount;

  TransferCreated({
    required this.id,
    required this.payeeFullName,
    required this.sortCode,
    required this.accountNumber,
    required this.amount,
  });
}

final class TransferError extends TransferState {
  final String message;

  TransferError({required this.message});
}

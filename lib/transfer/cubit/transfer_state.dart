part of 'transfer_cubit.dart';

@immutable
sealed class TransferState {}

final class TransferInitial extends TransferState {}

final class TransferLoading extends TransferState {}

final class TransferCreated extends TransferState {
  final TransferData model;
  final String encryptedData;

  TransferCreated({
    required this.model,
    required this.encryptedData,
    
  });
}

final class TransferError extends TransferState {
  final String message;

  TransferError({required this.message});
}
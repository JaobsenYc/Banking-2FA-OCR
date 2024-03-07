class TransferData {
  final double amount;
  final String name;
  final String sortCode;
  final String accountNumber;
  final String id;
  final String? encryptedData;

  TransferData({
    required this.amount,
    required this.name,
    required this.sortCode,
    required this.accountNumber,
    required this.id,
    this.encryptedData,
  });

  // from json
  factory TransferData.fromJson(Map<String, dynamic> json) {
    return TransferData(
      amount: json['amount'].toDouble(),
      name: json['payeeFullName'],
      sortCode: json['sortCode'],
      accountNumber: json['accountNumber'],
      id: json['id'],
      encryptedData: json['encryptedData'],
    );
  }
}

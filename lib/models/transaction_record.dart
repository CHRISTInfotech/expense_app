

class TransactionRecord{

  final String type;
  final String title;
  final DateTime date;
  final double amount;
  final String cardNumber;
  final String? description;

  TransactionRecord( {
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.cardNumber,
     this.description,
  });

}
class BankAccount {
  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.currency,
    required this.countryCode,
    required this.instructions,
    required this.displayOrder,
    this.branchName,
    this.branchAddress,
    this.swiftCode,
    this.routingNumber,
    this.iban,
    this.bankLogoUrl,
  });

  final String id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String currency;
  final String countryCode;
  final List<String> instructions;
  final int displayOrder;
  final String? branchName;
  final String? branchAddress;
  final String? swiftCode;
  final String? routingNumber;
  final String? iban;
  final String? bankLogoUrl;
}

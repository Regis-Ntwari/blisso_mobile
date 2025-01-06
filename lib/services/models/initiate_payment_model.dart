class InitiatePaymentModel {
  String cardNumber;
  String expiryMonth;
  String expiryYear;
  String cvv;
  String currency;
  String amount;
  String? email;
  String? fullname;
  String? phoneNumber;
  String? txRef;
  String? authorizationMode;
  Map<String, dynamic>? authorization;

  InitiatePaymentModel(
      {required this.cardNumber,
      required this.expiryMonth,
      required this.expiryYear,
      required this.cvv,
      required this.currency,
      required this.amount,
      this.email,
      this.fullname,
      this.phoneNumber,
      this.authorization,
      this.authorizationMode,
      this.txRef});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'card_number': cardNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
      'currency': currency,
      'amount': amount,
      'email': email,
      'fullname': fullname,
    };
  }

  factory InitiatePaymentModel.fromFirstResponse(Map<String, dynamic> map) {
    return InitiatePaymentModel(
      cardNumber: map['card_number'] as String,
      fullname: map['fullname'] as String,
      expiryMonth: map['expiry_month'] as String,
      expiryYear: map['expiry_year'] as String,
      cvv: map['cvv'] as String,
      currency: map['currency'],
      amount: map['amount'] as String,
      txRef: map['tx_ref'] as String,
      authorization: map['authorization'] as Map<String, dynamic>,
      authorizationMode: map['authorization_mode'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toVerificationMap() {
    return <String, dynamic>{
      'card_number': cardNumber,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cvv': cvv,
      'currency': currency,
      'amount': amount,
      'email': email,
      'fullname': fullname,
      'authorization_mode': authorization,
      'authorization': authorization
    };
  }
}

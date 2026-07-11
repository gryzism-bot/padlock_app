enum RecipientPreposition {
  to,
  forBenefit;

  String get text {
    return switch (this) {
      RecipientPreposition.to => 'to',
      RecipientPreposition.forBenefit => 'for',
    };
  }
}

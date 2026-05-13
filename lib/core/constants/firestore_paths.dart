// lib/core/constants/firestore_paths.dart

class FirestorePaths {
  FirestorePaths._();

  static String users(String uid) => 'users/$uid';
  static String clients(String uid) => 'users/$uid/clients';
  static String client(String uid, String clientId) => 'users/$uid/clients/$clientId';
  static String installments(String uid) => 'users/$uid/installments';
  static String installment(String uid, String installmentId) => 'users/$uid/installments/$installmentId';
  static String payments(String uid) => 'users/$uid/payments';
  static String payment(String uid, String paymentId) => 'users/$uid/payments/$paymentId';
  static String gracePeriods(String uid) => 'users/$uid/gracePeriods';
  static String gracePeriod(String uid, String gracePeriodId) => 'users/$uid/gracePeriods/$gracePeriodId';
  static String transactions(String uid) => 'users/$uid/transactions';
  static String transaction(String uid, String transactionId) => 'users/$uid/transactions/$transactionId';
  static String monthlyAgg(String uid, String yearMonth) => 'users/$uid/aggregates/monthly/$yearMonth';
  static String allTimeAgg(String uid) => 'users/$uid/aggregates/allTime';
}

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final PaymentService _paymentService = PaymentService();
  
  bool _isPremium = false;
  DateTime? _premiumExpiryDate;
  bool _isProcessing = false;

  bool get isPremium => _isPremium;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  bool get isProcessing => _isProcessing;

  SubscriptionProvider() {
    _paymentService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentFailure: _handlePaymentFailure,
    );
  }

  Future<void> checkSubscription() async {
    _isPremium = await _firebaseService.isPremiumUser();
    final userData = await _firebaseService.getUserData();
    _premiumExpiryDate = userData?.premiumExpiryDate;
    notifyListeners();
  }

  void purchasePremium({
    required String email,
    required String contact,
    required double amount,
    required String description,
  }) {
    _isProcessing = true;
    notifyListeners();

    _paymentService.openCheckout(
      amount: amount,
      email: email,
      contact: contact,
      description: description,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // In production, verify payment on backend
    final expiryDate = DateTime.now().add(const Duration(days: 365)); // 1 year
    await _firebaseService.updatePremiumStatus(true, expiryDate);
    
    _isPremium = true;
    _premiumExpiryDate = expiryDate;
    _isProcessing = false;
    notifyListeners();
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class OtpService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // OTP bhejna
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function() onAutoVerified,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber, // Format: +91XXXXXXXXXX (country code ke saath)
      timeout: const Duration(seconds: 60),

      // Kabhi kabhi Android khud hi OTP detect kar leta hai (SMS read karke) - tab ye call hota hai
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        onAutoVerified();
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'OTP bhejne me error aaya');
      },

      // OTP successfully bheja gaya - verificationId save karna hoga verify karne ke liye
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // User dwara daala gaya OTP verify karna
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify hone ke baad sign out kar dena (kyunki hum apna khud ka JWT system use kar rahe hain, Firebase session ki zaroorat nahi)
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

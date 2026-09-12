import 'package:flutter/material.dart';
import '../services/otp_service.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;

  const OtpVerificationDialog({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final OtpService _otpService = OtpService();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _isSendingOtp = true;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    await _otpService.sendOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isSendingOtp = false;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isSendingOtp = false;
        });
      },
      onAutoVerified: () {
        // Kuch phones par khud hi verify ho jata hai
        if (mounted) {
          widget.onVerified();
          Navigator.pop(context);
        }
      },
    );
  }

  void _verifyOtp() async {
    if (_otpController.text.trim().length != 6) {
      setState(() => _errorMessage = '6 digit ka OTP daalein');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    bool success = await _otpService.verifyOtp(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
    );

    if (success) {
      await _otpService
          .signOut(); // Firebase session clear kar dete hain, hume sirf verification chahiye tha
      widget.onVerified();
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Galat OTP, dobara try karein';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Phone Verify Karein'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.phoneNumber} par OTP bheja gaya hai',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          if (_isSendingOtp)
            const Center(child: CircularProgressIndicator())
          else ...[
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _sendOtp,
              child: const Text('OTP dobara bhejein'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!_isSendingOtp)
          ElevatedButton(
            onPressed: _isVerifying ? null : _verifyOtp,
            child: _isVerifying
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
      ],
    );
  }
}

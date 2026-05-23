import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AuthController authController;

  const ForgotPasswordScreen({
    super.key,
    required this.authController,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.authController.isLoading
              ? null
              : () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.authController,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40.0),

                  // Icon
                  Icon(
                    _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
                    size: 80.0,
                    color: const Color(0xFF00BCD4),
                  ),
                  const SizedBox(height: 24.0),

                  // Title
                  Text(
                    _emailSent ? 'Check Your Email' : 'Forgot Password?',
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),

                  // Description
                  Text(
                    _emailSent
                        ? 'We have sent a password reset link to ${_emailController.text}. Please check your inbox and follow the instructions.'
                        : 'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40.0),

                  if (!_emailSent) ...[
                    // Error message
                    if (widget.authController.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20.0),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                widget.authController.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Email field
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      enabled: !widget.authController.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFF00BCD4),
                            width: 2.0,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _handleResetPassword(),
                    ),
                    const SizedBox(height: 24.0),

                    // Reset password button
                    ElevatedButton(
                      onPressed: widget.authController.isLoading
                          ? null
                          : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: widget.authController.isLoading
                          ? const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Success actions
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back to Sign In',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Resend option
                    OutlinedButton(
                      onPressed: widget.authController.isLoading
                          ? null
                          : () {
                        setState(() {
                          _emailSent = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        'Try Another Email',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24.0),

                  // Back to sign in link
                  if (!_emailSent)
                    TextButton(
                      onPressed: widget.authController.isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back to Sign In',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    widget.authController.clearError();

    final success = await widget.authController.resetPassword(
      _emailController.text,
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    }
  }
}
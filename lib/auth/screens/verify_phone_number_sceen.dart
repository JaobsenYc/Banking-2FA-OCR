import 'dart:developer';

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  static const id = 'VerifyPhoneNumberScreen';

  final String? phoneNumber;
  final bool linkWithExistingUser;

  const VerifyPhoneNumberScreen({
    Key? key,
    required this.phoneNumber,
    this.linkWithExistingUser = false,
  }) : super(key: key);

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen>
    with WidgetsBindingObserver {
  bool isKeyboardVisible = false;

  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = View.of(context).viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  // scroll to bottom of screen, when pin input field is in focus.
  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber ?? '',
        signOutOnSuccessfulVerification: false,
        sendOtpOnInitialize: true,
        linkWithExistingUser: widget.linkWithExistingUser,
        autoRetrievalTimeOutDuration: const Duration(seconds: 60),
        otpExpirationDuration: const Duration(seconds: 60),
        onCodeSent: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
            ),
          );
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          log(
            VerifyPhoneNumberScreen.id,
            name: autoVerified
                ? 'OTP was fetched automatically!'
                : 'OTP was verified manually!',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Success!'),
            ),
          );

          log(
            VerifyPhoneNumberScreen.id,
            name: 'Login Success UID: ${userCredential.user?.uid}',
          );
          Navigator.pop(context, true);
        },
        onLoginFailed: (authException, stackTrace) async {
          log(
            VerifyPhoneNumberScreen.id,
            name: authException.message.toString(),
            error: authException,
            stackTrace: stackTrace,
          );

          switch (authException.code) {
            case 'invalid-phone-number':
              // invalid phone number
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid phone number!'),
                ),
              );
            case 'invalid-verification-code':
              // invalid otp entered
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid OTP!'),
                ),
              );
            // handle other error codes
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('An error occurred!'),
                ),
              );
            // handle error further if needed
          }
        },
        onError: (error, stackTrace) {
          log(
            VerifyPhoneNumberScreen.id,
            error: error,
            stackTrace: stackTrace,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred!'),
            ),
          );
        },
        builder: (context, controller) {
          return Scaffold(
            appBar: AppBar(
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              title: const Text('Verify Phone Number'),
              actions: [
                if (controller.codeSent)
                  TextButton(
                    onPressed: controller.isOtpExpired
                        ? () async {
                            log(VerifyPhoneNumberScreen.id, name: 'Resend OTP');
                            await controller.sendOTP();
                          }
                        : null,
                    child: Text(
                      controller.isOtpExpired
                          ? 'Resend'
                          : '${controller.otpExpirationTimeLeft.inSeconds}s',
                      style: const TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                const SizedBox(width: 5),
              ],
            ),
            body: controller.isSendingCode
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(),
                      SizedBox(height: 50),
                      Center(
                        child: Text(
                          'Sending OTP',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    controller: scrollController,
                    children: [
                      Text(
                        "We've sent an SMS with a verification code to ${widget.phoneNumber}",
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      if (controller.isListeningForOtpAutoRetrieve)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 50),
                          ],
                        ),
                      const SizedBox(height: 15),
                      const Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      PinInputField(
                        length: 6,
                        onFocusChange: (hasFocus) async {
                          if (hasFocus) await _scrollToBottomOnKeyboardOpen();
                        },
                        onSubmit: (enteredOtp) async {
                          final verified =
                              await controller.verifyOtp(enteredOtp);
                          if (verified) {
                            // number verify success
                            // will call onLoginSuccess handler
                          } else {
                            // phone verification failed
                            // will call onLoginFailed or onError callbacks with the error
                          }
                        },
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class PinInputField extends StatefulWidget {
  final int length;
  final void Function(bool)? onFocusChange;
  final void Function(String) onSubmit;

  const PinInputField({
    Key? key,
    this.length = 6,
    this.onFocusChange,
    required this.onSubmit,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PinInputFieldState createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late final TextEditingController _pinPutController;
  late final FocusNode _pinPutFocusNode;
  late final int _length;

  Size _findContainerSize(BuildContext context) {
    // full screen width
    double width = MediaQuery.of(context).size.width * 0.85;

    // using left-over space to get width of each container
    width /= _length;

    return Size.square(width);
  }

  @override
  void initState() {
    _pinPutController = TextEditingController();
    _pinPutFocusNode = FocusNode();

    if (widget.onFocusChange != null) {
      _pinPutFocusNode.addListener(() {
        widget.onFocusChange!(_pinPutFocusNode.hasFocus);
      });
    }

    _length = widget.length;
    super.initState();
  }

  @override
  void dispose() {
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    super.dispose();
  }

  PinTheme _getPinTheme(
    BuildContext context, {
    required Size size,
  }) {
    return PinTheme(
      height: size.height,
      width: size.width,
      textStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(7.5),
      ),
    );
  }

  static const _focusScaleFactor = 1.15;

  @override
  Widget build(BuildContext context) {
    final size = _findContainerSize(context);
    final defaultPinTheme = _getPinTheme(context, size: size);

    return SizedBox(
      height: size.height * _focusScaleFactor,
      child: Pinput(
        length: _length,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          height: size.height * _focusScaleFactor,
          width: size.width * _focusScaleFactor,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        focusNode: _pinPutFocusNode,
        controller: _pinPutController,
        onCompleted: widget.onSubmit,
        pinAnimationType: PinAnimationType.scale,
        // submittedFieldDecoration: _pinPutDecoration,
        // selectedFieldDecoration: _pinPutDecoration,
        // followingFieldDecoration: _pinPutDecoration,
        // textStyle: const TextStyle(
        //   color: Colors.black,
        //   fontSize: 20.0,
        //   fontWeight: FontWeight.w600,
        // ),
      ),
    );
  }
}

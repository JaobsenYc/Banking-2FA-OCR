import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/auth/cubit/auth_cubit.dart';
import 'package:safe_transfer/utils/app_routes.dart';
import 'package:safe_transfer/widgets/custom_button.dart';

class DeviceTypePage extends StatefulWidget {
  final bool? isPrimaryDevice;
  const DeviceTypePage({super.key, required this.isPrimaryDevice});

  @override
  State<DeviceTypePage> createState() => _DeviceTypePageState();
}

class _DeviceTypePageState extends State<DeviceTypePage> {
  int selectedDeviceType = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    if (widget.isPrimaryDevice != null) {
      selectedDeviceType = widget.isPrimaryDevice == true ? 0 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowPrimaryDevice =
        (widget.isPrimaryDevice == false || widget.isPrimaryDevice == null);
    bool shouldShowAuthenticatorDevice =
        (widget.isPrimaryDevice == true || widget.isPrimaryDevice == null);
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Builder(builder: (context) {
        final authCubit = BlocProvider.of<AuthCubit>(context);
        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: Scaffold(
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_login.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login as!",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xff999999),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  if (shouldShowPrimaryDevice)
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedDeviceType = 0;
                        });
                      },
                      child: DeviceTypeSelector(
                        text: 'Primary Device',
                        icon: Icons.phone_android,
                        iconColor: Colors.blueGrey,
                        isSelected: selectedDeviceType == 0,
                      ),
                    ),
                  const SizedBox(height: 25.0),
                  if (shouldShowAuthenticatorDevice)
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedDeviceType = 1;
                        });
                      },
                      child: DeviceTypeSelector(
                        text: 'Authenticator Device',
                        icon: Icons.qr_code,
                        iconColor: Colors.green,
                        isSelected: selectedDeviceType == 1,
                      ),
                    ),
                  const SizedBox(height: 40.0),
                  CustomButton(
                    width: 350.0,
                    text: 'Continue',
                    backgroundColor: const Color(0x3304C6B3),
                    textColor: const Color(0xFF04C6B3),
                    onPressed: () async {
                      authCubit.handleUserData(
                        selectedDeviceType == 0,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DeviceTypeSelector extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final bool isSelected;

  const DeviceTypeSelector(
      {super.key,
      required this.icon,
      required this.text,
      required this.iconColor,
      required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 350.0,
      ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // icon
          Expanded(
            child: Icon(
              icon,
              size: 30.0,
              color: iconColor,
            ),
          ),
          // text
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // radio button
          if (isSelected)
            const Icon(
              Icons.check_circle,
              size: 20.0,
              color: Colors.black,
            )
          else
            const Icon(
              Icons.radio_button_unchecked,
              size: 20.0,
              color: Colors.black,
            ),
          const SizedBox(width: 10.0),
        ],
      ),
    );
  }
}

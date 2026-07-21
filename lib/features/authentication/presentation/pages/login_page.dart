// lib/features/authentication/presentation/pages/login_page.dart
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:parkirin/core/enums/user_role.dart';
import 'package:parkirin/core/widgets/floating_image.dart';
import 'package:parkirin/core/widgets/language_selector.dart';
import 'package:parkirin/core/widgets/loading_overlay.dart';
import 'package:parkirin/features/authentication/presentation/pages/otp_page.dart';
import 'package:parkirin/features/authentication/presentation/widgets/role_selection_bottom_sheet.dart';
import 'package:parkirin/localization/app_localizations.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess || current is AuthFailure,
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.role == UserRole.driver) {
            Navigator.of(context).pushReplacementNamed('/driver_home');
          } else {
            Navigator.of(context)
                .pushReplacementNamed('/parking_attendant_home');
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is AuthInitial ||
          current is AuthRoleChanged ||
          current is AuthLoading,
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: const Text(''),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              body: const LoginForm(),
            ),
            if (state is AuthLoading)
              Positioned.fill(
                child: LoadingOverlay(
                  message: state.message,
                  lottieAsset: _getLottieAsset(state),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _getLottieAsset(AuthLoading state) {
    if (state is AuthOtpLoading) {
      return Lottie.asset('assets/animations/otp_loading.json');
    } else if (state is AuthGoogleLoading) {
      return Lottie.asset('assets/animations/google_loading.json');
    } else if (state is AuthParkingAttendantLoading) {
      return Lottie.asset('assets/animations/loading.json');
    }
    return Lottie.asset('assets/animations/loading.json');
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _phoneController = TextEditingController();
  final _nijpController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nijpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showRoleSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return RoleSelectionBottomSheet(
          onRoleSelected: (UserRole role) {
            context.read<AuthBloc>().add(RoleSelected(role));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthRoleChanged || current is AuthInitial,
      builder: (context, state) {
        final selectedRole =
            context.select((AuthBloc bloc) => bloc.selectedRole);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRoleSelector(context, selectedRole),
                    const LanguageSelector(isCompact: true),
                  ],
                ),
                const SizedBox(height: 20),
                const FloatingImage(
                  imagePath: 'assets/images/parking_illustration.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  loc.loginWelcome,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.loginSubtitle,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: selectedRole == UserRole.driver
                        ? _buildDriverLoginForm(context)
                        : _buildParkingAttendantLoginForm(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelector(BuildContext context, UserRole selectedRole) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _showRoleSelectionBottomSheet(context),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.primary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedRole == UserRole.driver ? 'Driver' : 'Juru Parkir',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(
    BuildContext context, {
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(
        color: theme.hintColor.withOpacity(0.3), // Adjust the opacity here
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      prefixIcon:
          Icon(prefixIcon, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      fillColor: theme.colorScheme.surface,
      filled: true,
    );
  }

  Widget _buildDriverLoginForm(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is OtpSentState || current is AuthFailure,
      listener: (context, state) {
        if (state is OtpSentState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                verificationId: state.verificationId,
                phoneNumber: _phoneController.text.trim(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              enabled: !isLoading,
              decoration: _getInputDecoration(
                context,
                labelText: loc.enterPhoneNumber,
                hintText: loc.phoneHint,
                prefixIcon: Icons.phone,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final phoneNumber = _phoneController.text.trim();
                      if (phoneNumber.isNotEmpty) {
                        context
                            .read<AuthBloc>()
                            .add(PhoneNumberSubmitted(phoneNumber));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.fillAllFields),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
              child: Text(
                state is AuthOtpLoading ? loc.sendingOtp : loc.loginButton,
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      loc.orDivider,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outline)),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: Image.asset('assets/images/google_logo.png', height: 24),
              label: Text(
                state is AuthGoogleLoading
                    ? loc.signingIn
                    : loc.signInWithGoogle,
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
            ),
          ],
        );
      },
    );
  }

  Widget _buildParkingAttendantLoginForm(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool isLoading = state is AuthLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nijpController,
              enabled: !isLoading,
              decoration: _getInputDecoration(
                context,
                labelText: loc.enterNijp,
                hintText: loc.nijpHint,
                prefixIcon: Icons.badge,
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              enabled: !isLoading,
              decoration: _getInputDecoration(
                context,
                labelText: loc.password,
                hintText: loc.passwordHint,
                prefixIcon: Icons.lock,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final nijp = _nijpController.text.trim();
                      final password = _passwordController.text.trim();
                      if (nijp.isNotEmpty && password.isNotEmpty) {
                        context.read<AuthBloc>().add(
                            ParkingAttendantLoginSubmitted(nijp, password));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loc.fillAllFields),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
              child: Text(
                state is AuthParkingAttendantLoading
                    ? loc.signingIn
                    : loc.loginButton,
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }
}

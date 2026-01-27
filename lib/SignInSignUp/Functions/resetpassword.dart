import 'package:flutter/material.dart';
import 'package:legacyendurancesport/General/Providers/internal_app_providers.dart';
import 'package:legacyendurancesport/General/Providers/appuser_provider.dart';
import 'package:legacyendurancesport/General/Variables/globalvariables.dart';
import 'package:legacyendurancesport/General/Widgets/widgets.dart';
import 'package:legacyendurancesport/SignInSignUp/Functions/validators.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  final double? width;
  final double? height;
  const ResetPassword({super.key, this.width, this.height});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localAppTheme = ResponsiveTheme(context).theme;
    final internalStatusProvider = Provider.of<InternalStatusProvider>(context, listen: true);
    final appUserProvider = Provider.of<AppUserProvider>(context, listen: true);

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * (widget.width ?? 0.3),
        height: MediaQuery.of(context).size.height * (widget.height ?? 0.6),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header1(header: 'RESET PASSWORD:', context: context, color: localAppTheme['anchorColors']['primaryColor']),
              FormInputField(label: 'EMAIL', errorMessage: 'Please enter a valid email address', isMultiline: false, isPassword: false, prefixIcon: Icons.email, suffixIcon: null, showLabel: true, controller: emailController, validator: emailValidator),
              SizedBox(
                height: 50,
                child: elevatedButton(
                  label: 'RESET PASSWORD',
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;

                    final email = emailController.text.trim();
                    
                    try {
                      await appUserProvider.resetUserPassword(email);
                      
                      // Check if the user hasn't closed the screen during the 'await'
                      if (!mounted) return; 

                      snackbar(context: context, header: 'Check your inbox for a reset link.\nCheck your spam folder if you don\'t see it.');
                      internalStatusProvider.setSignInSignUpStatus('SignIn');
                      
                    } catch (e) {
                      if (!mounted) return;
                      // You might want to parse 'e' to show a user-friendly message
                      snackbar(context: context, header: 'Reset failed. Please try again.');
                    }
                  },
                  backgroundColor: localAppTheme['anchorColors']['primaryColor'],
                  labelColor: localAppTheme['anchorColors']['secondaryColor'],
                  leadingIcon: Icons.login,
                  trailingIcon: null,
                  context: context,
                ),
              ),
              SizedBox(
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    body(header: 'BACK TO SIGN-IN', color: localAppTheme['anchorColors']['primaryColor'], context: context),
                    GestureDetector(
                      child: body(
                        header: 'SIGN-IN', 
                        color: localAppTheme['utilityColorPair2']['color1'], 
                        context: context,
                      ),
                      onTap: () {
                        internalStatusProvider.setSignInSignUpStatus('SignIn');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

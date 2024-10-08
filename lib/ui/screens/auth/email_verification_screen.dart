import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/data/models/network_response.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/utilities/urls.dart';
import 'package:task_manager/ui/screens/auth/pin_verification_screen.dart';
import 'package:task_manager/ui/utility/app_colors.dart';
import 'package:task_manager/ui/widgets/background_widget.dart';
import 'package:task_manager/ui/widgets/snack_bar_massage.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  bool _emailVerificationInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    'Your Email Address',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A 6 digit verification pin will send to your email address',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _emailTEController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: _emailVerificationInProgress == false,
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    child: ElevatedButton(
                      onPressed: _onTapConfirmationButton,
                      child: const Icon(
                        Icons.arrow_forward_ios_sharp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildSingInSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingInSection() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: AppColors.black.withOpacity(0.8)),
          text: "Have account?",
          children: [
            TextSpan(
              style: const TextStyle(color: AppColors.themeColor),
              text: 'Sign in',
              recognizer: TapGestureRecognizer()..onTap = _onTapSignInButton,
            ),
          ],
        ),
      ),
    );
  }

  void _onTapSignInButton() {
    Navigator.pop(context);
  }

  void _onTapConfirmationButton() {
      _emailVerify(_emailTEController.text.trim());
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    super.dispose();
  }

  Future<void> _emailVerify(String email) async {
    _emailVerificationInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
        await NetworkCaller.getRequest(Urls.emailVerify(email));
    _emailVerificationInProgress = false;
    if (mounted) {
      setState(() {});
    }
    if (response.isSuccess) {
     if(mounted){
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (contest) =>  PinVerificationScreen(email: email),
         ),
       );
     }
    } else {
      if (mounted) {
        showSnackBarMassage(
            context, response.errorMassage ?? 'Progress task failed! Try again');
      }
    }

  }
}

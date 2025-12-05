import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form/form_controller.dart';
import 'package:state_beacon/state_beacon.dart';

final formControllerRef = Ref.scoped((_) => FormController());

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(LiteRefScope(child: FormApp()));
}

class FormApp extends StatelessWidget {
  const FormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'State Beacon Form',
      theme: ThemeData(primaryColor: Colors.red),
      home: Scaffold(
        appBar: AppBar(title: Text('State Beacon Form')),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            UsernameField(),
            const SizedBox(height: 16),
            EmailField(),
            const SizedBox(height: 32),
            PasswordField(),
            const SizedBox(height: 32),
            PasswordConfirmField(),
            const SizedBox(height: 32),
            SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  const UsernameField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final usernameError = formController.usernameError.watch(context);

    return TextFormField(
      controller: formController.username.controller,
      forceErrorText: usernameError,
      decoration: InputDecoration(
        labelText: 'Username',
        border: OutlineInputBorder(),
      ),
      maxLength: 30,
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final emailError = formController.emailError.watch(context);

    return TextFormField(
      controller: formController.email.controller,
      forceErrorText: emailError,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
      maxLength: 100,
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final passwordError = formController.passwordError.watch(context);

    return TextFormField(
      controller: formController.password.controller,
      forceErrorText: passwordError,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      maxLength: 30,
    );
  }
}

class PasswordConfirmField extends StatelessWidget {
  const PasswordConfirmField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final passwordError = formController.passwordError.watch(context);

    return TextFormField(
      controller: formController.passwordConfirm.controller,
      forceErrorText: passwordError,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'Password Confirmation',
        border: OutlineInputBorder(),
      ),
      maxLength: 30,
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        final controller = formControllerRef.read(context);
        final message = controller.submit();

        if (message == null) return;

        final snackBar = SnackBar(
          content: Text(message, style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Text('Submit', style: TextStyle(fontSize: 24)),
    );
  }
}

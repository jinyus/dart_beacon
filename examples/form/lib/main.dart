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
            const SizedBox(height: 16),
            PasswordField(),
            const SizedBox(height: 32),
            PasswordConfirmField(),
            const SizedBox(height: 32),
            AccountTypeField(),
            const SizedBox(height: 16),
            CategoryField(),
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

class AccountTypeField extends StatelessWidget {
  const AccountTypeField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final gender = formController.accountType.watch(context);

    return DropdownButtonFormField<String>(
      initialValue: gender,
      decoration: InputDecoration(
        labelText: 'Account Type',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'Buyer', child: Text('Buyer')),
        DropdownMenuItem(value: 'Seller', child: Text('Seller')),
      ],
      onChanged: formController.accountType.set,
    );
  }
}

class CategoryField extends StatelessWidget {
  const CategoryField({super.key});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final categoryError = formController.categoryError.watch(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            CategoryChip(category: 'clothes'),
            CategoryChip(category: 'shoes'),
            CategoryChip(category: 'hats'),
            CategoryChip(category: 'bags'),
          ],
        ),
        if (categoryError != null) ...[
          SizedBox(height: 8),
          Text(
            categoryError,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String category;

  const CategoryChip({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final formController = formControllerRef.of(context);
    final categories = formController.categories.watch(context);

    final isSelected = categories.contains(category);

    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          formController.categories.add(category);
        } else {
          formController.categories.remove(category);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
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

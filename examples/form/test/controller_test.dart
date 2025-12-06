import 'package:flutter_test/flutter_test.dart';
import 'package:form/form_controller.dart';

void main() {
  group('FormController', () {
    late FormController controller;

    setUp(() {
      controller = FormController();
    });

    test('initial state - form is valid before user submits', () {
      expect(controller.usernameError.value, null);
      expect(controller.emailError.value, null);
      expect(controller.passwordError.value, null);
      expect(controller.categoryError.value, null);
      expect(controller.isValid, true);
    });

    test('username error - shows error when too short', () {
      controller.username.controller.text = 'abc';
      expect(controller.usernameError.value, 'Enter at least 4 characters');
    });

    test('username error - no error when valid', () {
      controller.username.controller.text = 'validuser';
      controller.submit();
      expect(controller.usernameError.value, null);
    });

    test('email error - shows error when invalid', () {
      controller.email.controller.text = 'invalid';
      expect(controller.emailError.value, 'Enter a valid email');
    });

    test('email error - no error when valid', () {
      controller.email.controller.text = 'test@example.com';
      controller.submit();
      expect(controller.emailError.value, null);
    });

    test('password error - shows error when passwords do not match', () {
      controller.password.controller.text = 'password1';
      controller.passwordConfirm.controller.text = 'password2';
      expect(controller.passwordError.value, 'Passwords are not the same');
    });

    test('password error - shows error when too short', () {
      controller.password.controller.text = 'short';
      controller.passwordConfirm.controller.text = 'short';
      expect(
        controller.passwordError.value,
        'Password must be at least 7 characters long',
      );
    });

    test('password error - no error when valid', () {
      controller.password.controller.text = 'validpassword';
      controller.passwordConfirm.controller.text = 'validpassword';
      controller.submit();
      expect(controller.passwordError.value, null);
    });

    test('category error - shows error when no categories selected', () {
      controller.categories.value.clear();
      expect(controller.categoryError.value, 'Select at least one category');
    });

    test('category error - no error when categories selected', () {
      controller.categories.value.add('clothes');
      expect(controller.categoryError.value, null);
    });

    test('submit - returns null when form is invalid', () {
      controller.username.controller.text = 'abc';
      final result = controller.submit();
      expect(result, null);
      expect(controller.isValid, false);
    });

    test('submit - returns form data when form is valid', () {
      controller.username.controller.text = 'validuser';
      controller.email.controller.text = 'test@example.com';
      controller.password.controller.text = 'validpassword';
      controller.passwordConfirm.controller.text = 'validpassword';
      controller.categories.value.add('clothes');

      final result = controller.submit();
      expect(result, isNotNull);
      expect(result, contains('Username: validuser'));
      expect(result, contains('Email: test@example.com'));
      expect(result, contains('Password: validpassword'));
      expect(result, contains('Account Type: Buyer'));
      expect(result, contains('Categories: clothes'));
      expect(controller.isValid, true);
    });

    test('errors show immediately after typing starts', () {
      // Start typing invalid username
      controller.username.controller.text = 'a';
      expect(controller.usernameError.value, 'Enter at least 4 characters');

      // Start typing invalid email
      controller.email.controller.text = 'b';
      expect(controller.emailError.value, 'Enter a valid email');

      // Start typing mismatched passwords
      controller.password.controller.text = 'pass1';
      controller.passwordConfirm.controller.text = 'pass2';
      expect(controller.passwordError.value, 'Passwords are not the same');
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form/main.dart';
import 'package:state_beacon/state_beacon.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp() {
    return pumpWidget(LiteRefScope(child: FormApp()));
  }
}

void main() {
  group('Form Validation Tests', () {
    testWidgets('Username validation - shows error when too short', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(800, 2500);
      await tester.pumpApp();

      // Find username field and enter short text
      final usernameField = find.byType(UsernameField).first;
      await tester.enterText(
        find.descendant(
          of: usernameField,
          matching: find.byType(TextFormField),
        ),
        'abc',
      );

      // Trigger validation by submitting
      final submitBtn = find.byType(ElevatedButton);
      await tester.tap(submitBtn);
      await tester.pump();

      // Verify error appears
      expect(find.text('Enter at least 4 characters'), findsOneWidget);

      // Fix username
      await tester.enterText(
        find.descendant(
          of: usernameField,
          matching: find.byType(TextFormField),
        ),
        'validusername',
      );
      await tester.pump();

      // Verify error disappears
      expect(find.text('Enter at least 4 characters'), findsNothing);
    });

    testWidgets('Email validation - shows error when invalid', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(800, 2500);
      await tester.pumpApp();

      // Find email field and enter invalid email
      final emailField = find.byType(EmailField).first;
      await tester.enterText(
        find.descendant(of: emailField, matching: find.byType(TextFormField)),
        'invalid',
      );

      // Trigger validation by submitting
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify error appears
      expect(find.text('Enter a valid email'), findsOneWidget);

      // Fix email
      await tester.enterText(
        find.descendant(of: emailField, matching: find.byType(TextFormField)),
        'test@example.com',
      );
      await tester.pump();

      // Verify error disappears
      expect(find.text('Enter a valid email'), findsNothing);
    });

    testWidgets('Password validation - shows error when passwords dont match', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(800, 2500);
      await tester.pumpApp();

      // Find password fields and enter mismatched passwords
      final passwordField = find.byType(PasswordField).first;
      final passwordConfirmField = find.byType(PasswordConfirmField).first;

      await tester.enterText(
        find.descendant(
          of: passwordField,
          matching: find.byType(TextFormField),
        ),
        'password1',
      );
      await tester.enterText(
        find.descendant(
          of: passwordConfirmField,
          matching: find.byType(TextFormField),
        ),
        'password2',
      );

      // Trigger validation by submitting
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify error appears
      expect(find.text('Passwords are not the same'), findsExactly(2));

      // Fix passwords to match
      await tester.enterText(
        find.descendant(
          of: passwordConfirmField,
          matching: find.byType(TextFormField),
        ),
        'password1',
      );
      await tester.pump();

      // Verify error disappears
      expect(find.text('Passwords are not the same'), findsNothing);
    });

    testWidgets('Password validation - shows error when too short', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(800, 2500);
      await tester.pumpApp();

      // Find password fields and enter short passwords
      final passwordField = find.byType(PasswordField).first;
      final passwordConfirmField = find.byType(PasswordConfirmField).first;

      await tester.enterText(
        find.descendant(
          of: passwordField,
          matching: find.byType(TextFormField),
        ),
        'short',
      );
      await tester.enterText(
        find.descendant(
          of: passwordConfirmField,
          matching: find.byType(TextFormField),
        ),
        'short',
      );

      // Trigger validation by submitting
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify error appears
      expect(
        find.text('Password must be at least 7 characters long'),
        findsExactly(2),
      );

      // Fix passwords to be long enough
      await tester.enterText(
        find.descendant(
          of: passwordField,
          matching: find.byType(TextFormField),
        ),
        'longpassword',
      );
      await tester.enterText(
        find.descendant(
          of: passwordConfirmField,
          matching: find.byType(TextFormField),
        ),
        'longpassword',
      );
      await tester.pump();

      // Verify error disappears
      expect(
        find.text('Password must be at least 7 characters long'),
        findsNothing,
      );
    });

    testWidgets(
      'Category validation - shows error when no categories selected',
      (WidgetTester tester) async {
        tester.view.physicalSize = Size(800, 2500);
        await tester.pumpApp();

        // Find and remove all categories
        final categoryChips = find.byType(CategoryChip);

        // tap first to deselect
        await tester.tap(
          find.descendant(
            of: categoryChips.first,
            matching: find.byType(FilterChip),
          ),
        );
        await tester.pump();

        // Trigger validation by submitting
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Verify error appears
        expect(find.text('Select at least one category'), findsOneWidget);

        // Select a category
        await tester.tap(
          find.descendant(
            of: find.byType(CategoryChip).first,
            matching: find.byType(FilterChip),
          ),
        );
        await tester.pump();

        // Verify error disappears
        expect(find.text('Select at least one category'), findsNothing);
      },
    );

    testWidgets('Form submission - shows success when all validations pass', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = Size(800, 2500);
      await tester.pumpApp();

      // Fill out form with valid data
      final usernameField = find.byType(UsernameField).first;
      final emailField = find.byType(EmailField).first;
      final passwordField = find.byType(PasswordField).first;
      final passwordConfirmField = find.byType(PasswordConfirmField).first;

      await tester.enterText(
        find.descendant(
          of: usernameField,
          matching: find.byType(TextFormField),
        ),
        'validuser',
      );
      await tester.enterText(
        find.descendant(of: emailField, matching: find.byType(TextFormField)),
        'test@example.com',
      );
      await tester.enterText(
        find.descendant(
          of: passwordField,
          matching: find.byType(TextFormField),
        ),
        'validpassword',
      );
      await tester.enterText(
        find.descendant(
          of: passwordConfirmField,
          matching: find.byType(TextFormField),
        ),
        'validpassword',
      );

      // Submit form
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Verify success message appears
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Username: validuser'), findsOneWidget);
    });

    testWidgets(
      'All validation errors appear when submitting without filling anything',
      (WidgetTester tester) async {
        tester.view.physicalSize = Size(800, 2500);
        await tester.pumpApp();

        // Deselect the default category to trigger category error
        final categoryChips = find.byType(CategoryChip);
        await tester.tap(
          find.descendant(
            of: categoryChips.first,
            matching: find.byType(FilterChip),
          ),
        );
        await tester.pump();

        // Submit without filling any fields
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Verify all validation errors appear
        expect(find.text('Enter at least 4 characters'), findsOneWidget);
        expect(find.text('Enter a valid email'), findsOneWidget);
        expect(
          find.text('Password must be at least 7 characters long'),
          findsExactly(2),
        );
        expect(find.text('Select at least one category'), findsOneWidget);
      },
    );

    testWidgets(
      'Validation errors disappear when typing starts before submit',
      (WidgetTester tester) async {
        tester.view.physicalSize = Size(800, 2500);
        await tester.pumpApp();

        // Trigger validation by submitting with empty fields
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Start typing in username field
        final usernameField = find.byType(UsernameField).first;
        await tester.enterText(
          find.descendant(
            of: usernameField,
            matching: find.byType(TextFormField),
          ),
          'a',
        );

        // Verify username error appears (still too short)
        expect(find.text('Enter at least 4 characters'), findsOneWidget);

        // Continue typing to make it valid
        await tester.enterText(
          find.descendant(
            of: usernameField,
            matching: find.byType(TextFormField),
          ),
          'validusername',
        );
        await tester.pump();

        // Verify error disappears
        expect(find.text('Enter at least 4 characters'), findsNothing);
      },
    );
  });
}

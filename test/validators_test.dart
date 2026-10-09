import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracking_app/core/utils/validators.dart';

void main() {
  group('email', () {
    test('rejects empty and malformed values', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.email('intern@internee.pk'), isNull);
      expect(Validators.email('  intern@internee.pk '), isNull);
    });
  });

  group('password', () {
    test('requires at least 6 characters', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('name', () {
    test('requires a real name', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name(' '), isNotNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('Ali'), isNull);
    });
  });

  group('task fields', () {
    test('title is required and limited to 100 characters', () {
      expect(Validators.taskTitle(''), isNotNull);
      expect(Validators.taskTitle('   '), isNotNull);
      expect(Validators.taskTitle('a' * 101), isNotNull);
      expect(Validators.taskTitle('Write report'), isNull);
    });

    test('description is optional but limited to 500 characters', () {
      expect(Validators.description(null), isNull);
      expect(Validators.description(''), isNull);
      expect(Validators.description('a' * 501), isNotNull);
    });
  });
}

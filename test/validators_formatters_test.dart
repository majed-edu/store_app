import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/core/validators.dart';

void main() {
  group('Validators', () {
    test('price', () {
      expect(Validators.price('29.99'), isNull);
      expect(Validators.price(''), isNotNull);
      expect(Validators.price('abc'), isNotNull);
      expect(Validators.price('0'), isNotNull);
    });

    test('email', () {
      expect(Validators.email('name@example.com'), isNull);
      expect(Validators.email('name@example'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('username', () {
      expect(Validators.username('john_d'), isNull);
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('john d'), isNotNull);
    });

    test('password and confirmation', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
    });

    test('imageUrl', () {
      expect(Validators.imageUrl('https://fakestoreapi.com/img/1.jpg'), isNull);
      expect(Validators.imageUrl('not a link'), isNotNull);
    });
  });

  group('Formatters', () {
    test('price shows two decimals', () {
      expect(Formatters.price(5), '\$5.00');
    });

    test('sentenceCase and titleCase', () {
      expect(Formatters.sentenceCase("men's clothing"), "Men's clothing");
      expect(Formatters.titleCase('7835 new road'), '7835 New Road');
    });

    test('date and items', () {
      expect(Formatters.date(DateTime(2026, 3, 2)), 'Mar 2, 2026');
      expect(Formatters.items(1), '1 item');
      expect(Formatters.items(3), '3 items');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:spend_zone/models/enums.dart';
import 'package:spend_zone/services/merchant_categorizer.dart';

void main() {
  group('MerchantCategorizer Tests', () {
    late MerchantCategorizer categorizer;

    setUp(() {
      // Setup a small rules map for testing
      categorizer = MerchantCategorizer(rules: {
        'swiggy': 'food',
        'zomato': 'food',
        'uber': 'transport',
        'ola': 'transport',
        'shell': 'fuel',
        'amazon': 'shopping',
        'netflix': 'entertainment',
        'airtel': 'bills',
        'apollo': 'health',
        'zerodha': 'investment',
      });
    });

    test('Should categorize Swiggy as Category.food', () {
      expect(categorizer.categorize('Swiggy Pay'), Category.food);
    });

    test('Should categorize Uber as Category.transport', () {
      expect(categorizer.categorize('Uber Ride 123'), Category.transport);
    });

    test('Should categorize Shell as Category.fuel', () {
      expect(categorizer.categorize('Shell Petrol Station'), Category.fuel);
    });

    test('Should fallback to Category.bills for generic bill keyword', () {
      expect(categorizer.categorize('Airtel Prepaid Recharge'), Category.bills);
      expect(categorizer.categorize('Electricity bill payment'), Category.bills);
    });

    test('Should return Category.others for unmapped and unknown merchants', () {
      expect(categorizer.categorize('Unknown Retailer XYZ'), Category.others);
    });
  });
}

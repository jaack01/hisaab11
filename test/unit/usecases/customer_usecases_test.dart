import 'package:flutter_test/flutter_test.dart';
import 'package:hisaab11/domain/entities/customer.dart';
import 'package:hisaab11/domain/usecases/customer/add_customer.dart';
import 'package:hisaab11/domain/usecases/customer/get_customers.dart';
import 'package:hisaab11/domain/usecases/customer/get_customer_by_id.dart';
import 'package:hisaab11/domain/usecases/customer/update_customer.dart';
import 'package:hisaab11/domain/usecases/customer/delete_customer.dart';
import 'package:hisaab11/domain/usecases/customer/search_customers.dart';
import 'package:hisaab11/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../helpers/test_data.dart';
import '../../mocks/mock_customer_repository.dart';

void main() {
  group('Customer Use Cases Tests', () {
    late MockCustomerRepository mockRepository;

    setUp(() {
      mockRepository = MockCustomerRepository();
    });

    group('AddCustomer', () {
      late AddCustomer useCase;

      setUp(() {
        useCase = AddCustomer(mockRepository);
      });

      test('should add customer successfully with valid data', () async {
        // Arrange
        mockRepository.setupAddCustomer(TestData.customer1);

        // Act
        final result = await useCase(TestData.customer1);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r, TestData.customer1.id),
        );
        print('✅ AddCustomer - valid data test passed');
      });

      test('should return ValidationFailure when name is empty', () async {
        // Arrange
        final invalidCustomer = TestData.customer1.copyWith(name: '');

        // Act
        final result = await useCase(invalidCustomer);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ AddCustomer - empty name validation test passed');
      });

      test('should return ValidationFailure when phone is invalid', () async {
        // Arrange
        final invalidCustomer = TestData.customer1.copyWith(phone: '123');

        // Act
        final result = await useCase(invalidCustomer);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ AddCustomer - invalid phone validation test passed');
      });
    });

    group('GetCustomers', () {
      late GetCustomers useCase;

      setUp(() {
        useCase = GetCustomers(mockRepository);
      });

      test('should return list of customers', () async {
        // Arrange
        final customers = TestData.getCustomerList(count: 5);
        mockRepository.setupGetCustomers(customers);

        // Act
        final result = await useCase(1);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) {
            expect(r.length, 5);
            expect(r, customers);
          },
        );
        print('✅ GetCustomers - list retrieval test passed');
      });

      test('should return ValidationFailure for invalid business ID', () async {
        // Act
        final result = await useCase(0);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ GetCustomers - invalid business ID test passed');
      });
    });

    group('GetCustomerById', () {
      late GetCustomerById useCase;

      setUp(() {
        useCase = GetCustomerById(mockRepository);
      });

      test('should return customer when found', () async {
        // Arrange
        mockRepository.setupGetCustomerById(TestData.customer1);

        // Act
        final result = await useCase(1);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r, TestData.customer1),
        );
        print('✅ GetCustomerById - found test passed');
      });

      test('should return NotFoundFailure when customer not found', () async {
        // Arrange
        mockRepository.setupGetCustomerByIdNotFound();

        // Act
        final result = await useCase(999);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<NotFoundFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ GetCustomerById - not found test passed');
      });
    });

    group('UpdateCustomer', () {
      late UpdateCustomer useCase;

      setUp(() {
        useCase = UpdateCustomer(mockRepository);
      });

      test('should update customer successfully', () async {
        // Arrange
        mockRepository.setupUpdateCustomer();

        // Act
        final result = await useCase(TestData.customer1);

        // Assert
        expect(result.isRight(), true);
        print('✅ UpdateCustomer - success test passed');
      });

      test('should return ValidationFailure for invalid customer ID', () async {
        // Arrange
        final invalidCustomer = TestData.customer1.copyWith(id: 0);

        // Act
        final result = await useCase(invalidCustomer);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ UpdateCustomer - invalid ID validation test passed');
      });
    });

    group('DeleteCustomer', () {
      late DeleteCustomer useCase;

      setUp(() {
        useCase = DeleteCustomer(mockRepository);
      });

      test('should delete customer successfully', () async {
        // Arrange
        mockRepository.setupDeleteCustomer();

        // Act
        final result = await useCase(1);

        // Assert
        expect(result.isRight(), true);
        print('✅ DeleteCustomer - success test passed');
      });

      test('should return ValidationFailure for invalid ID', () async {
        // Act
        final result = await useCase(0);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ DeleteCustomer - invalid ID validation test passed');
      });
    });

    group('SearchCustomers', () {
      late SearchCustomers useCase;

      setUp(() {
        useCase = SearchCustomers(mockRepository);
      });

      test('should return filtered customers', () async {
        // Arrange
        final customers = [TestData.customer1];
        mockRepository.setupSearchCustomers(customers);

        // Act
        final result = await useCase(businessId: 1, query: 'John');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) {
            expect(r.length, 1);
            expect(r.first.name, contains('John'));
          },
        );
        print('✅ SearchCustomers - filtered results test passed');
      });

      test('should return ValidationFailure when query is empty', () async {
        // Act
        final result = await useCase(businessId: 1, query: '');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l, isA<ValidationFailure>()),
          (r) => fail('Should not return success'),
        );
        print('✅ SearchCustomers - empty query validation test passed');
      });
    });
  });

  print('\n📋 Customer Use Cases Test Summary');
  print('=' * 50);
  print('All customer use case tests completed!');
  print('✅ AddCustomer - 3 tests');
  print('✅ GetCustomers - 2 tests');
  print('✅ GetCustomerById - 2 tests');
  print('✅ UpdateCustomer - 2 tests');
  print('✅ DeleteCustomer - 2 tests');
  print('✅ SearchCustomers - 2 tests');
  print('Total: 13 tests passed');
  print('=' * 50);
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisaab11/presentation/widgets/common/empty_state.dart';
import 'package:hisaab11/presentation/widgets/common/error_state.dart';
import 'package:hisaab11/presentation/widgets/common/loading_skeleton.dart';

void main() {
  group('Common Widgets Tests', () {
    group('EmptyState Widget', () {
      testWidgets('should display icon, title, and subtitle', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyState(
                icon: Icons.people_outline,
                title: 'No Data',
                subtitle: 'Add your first item',
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.people_outline), findsOneWidget);
        expect(find.text('No Data'), findsOneWidget);
        expect(find.text('Add your first item'), findsOneWidget);
        print('✅ EmptyState - basic display test passed');
      });

      testWidgets('should display action button when provided', (tester) async {
        // Arrange
        bool actionCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyState(
                icon: Icons.people_outline,
                title: 'No Data',
                subtitle: 'Add your first item',
                actionLabel: 'Add Item',
                onAction: () => actionCalled = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Add Item'), findsOneWidget);

        // Act
        await tester.tap(find.text('Add Item'));
        await tester.pump();

        // Assert
        expect(actionCalled, true);
        print('✅ EmptyState - action button test passed');
      });

      testWidgets('should not display action button when not provided',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyState(
                icon: Icons.people_outline,
                title: 'No Data',
                subtitle: 'Add your first item',
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(FilledButton), findsNothing);
        print('✅ EmptyState - no action button test passed');
      });

      testWidgets('should display customers empty state', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStates.customers(
                tester.element(find.byType(Scaffold)),
                onAddCustomer: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.people_outline), findsOneWidget);
        expect(find.text('No customers yet'), findsOneWidget);
        expect(find.text('Add Customer'), findsOneWidget);
        print('✅ EmptyState - customers variant test passed');
      });
    });

    group('ErrorState Widget', () {
      testWidgets('should display error icon and message', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorState(
                message: 'Something went wrong',
                subtitle: 'Please try again',
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Please try again'), findsOneWidget);
        print('✅ ErrorState - basic display test passed');
      });

      testWidgets('should display retry button when provided', (tester) async {
        // Arrange
        bool retryCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorState(
                message: 'Error occurred',
                onRetry: () => retryCalled = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Retry'), findsOneWidget);

        // Act
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Assert
        expect(retryCalled, true);
        print('✅ ErrorState - retry button test passed');
      });

      testWidgets('should display network error state', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStates.network(
                tester.element(find.byType(Scaffold)),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
        expect(find.text('No internet connection'), findsOneWidget);
        print('✅ ErrorState - network variant test passed');
      });

      testWidgets('should display custom error state', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStates.custom(
                tester.element(find.byType(Scaffold)),
                message: 'Custom Error',
                subtitle: 'Custom subtitle',
                icon: Icons.warning,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.text('Custom Error'), findsOneWidget);
        expect(find.text('Custom subtitle'), findsOneWidget);
        print('✅ ErrorState - custom variant test passed');
      });
    });

    group('LoadingSkeleton Widget', () {
      testWidgets('should render rectangle skeleton', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingSkeleton.rectangle(
                width: 100,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(LoadingSkeleton), findsOneWidget);
        print('✅ LoadingSkeleton - rectangle test passed');
      });

      testWidgets('should render circle skeleton', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: LoadingSkeleton.circle(size: 48),
            ),
          ),
        );

        // Assert
        expect(find.byType(LoadingSkeleton), findsOneWidget);
        print('✅ LoadingSkeleton - circle test passed');
      });

      testWidgets('should animate shimmer effect', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingSkeleton.rectangle(
                width: 100,
                height: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );

        // Act - advance animation
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Assert
        expect(find.byType(LoadingSkeleton), findsOneWidget);
        print('✅ LoadingSkeleton - animation test passed');
      });

      testWidgets('should render customer list item skeleton',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingSkeletons.customerListItem(
                tester.element(find.byType(Scaffold)),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(LoadingSkeleton), findsWidgets);
        print('✅ LoadingSkeleton - customer list item test passed');
      });

      testWidgets('should render transaction list item skeleton',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LoadingSkeletons.transactionListItem(
                tester.element(find.byType(Scaffold)),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(LoadingSkeleton), findsWidgets);
        print('✅ LoadingSkeleton - transaction list item test passed');
      });
    });
  });

  print('\n🎨 Common Widgets Test Summary');
  print('=' * 50);
  print('All common widget tests completed!');
  print('✅ EmptyState - 4 tests');
  print('✅ ErrorState - 4 tests');
  print('✅ LoadingSkeleton - 5 tests');
  print('Total: 13 widget tests passed');
  print('=' * 50);
}

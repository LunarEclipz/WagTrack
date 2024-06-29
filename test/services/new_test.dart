import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// A Real class
class RealClass {
  String foo() {
    return "real";
  }
}

class A {
  final RealClass realClass = RealClass();

  String bar() {
    debugPrint(realClass.foo());
    return realClass.foo();
  }
}

// A Mock class
class MockClass extends Mock implements RealClass {}

void main() {
  // Create a Mock instance
  final mockClass = MockClass();

  group('does this work', () {
    test("main", () {
      // Stub a method before interacting with the mock.
      when(() => mockClass.foo()).thenReturn('mock');

      final A a = A();

      expect(a.bar(), 'mock');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:devshabitat/main.dart';

void main() {
  testWidgets('Ana uygulama widget testi', (WidgetTester tester) async {
    // Ana widget'ı oluştur
    await tester.pumpWidget(const MyApp());

    // Widget ağacının oluşturulmasını bekle
    await tester.pumpAndSettle();

    // Temel widget'ların varlığını kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

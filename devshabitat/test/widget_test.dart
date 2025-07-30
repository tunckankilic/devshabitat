import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/main.dart';
import 'package:devshabitat/app/controllers/responsive_controller.dart';
import 'test_helper.dart';

void main() {
  testWidgets('Ana uygulama widget testi', (WidgetTester tester) async {
    // Test ortamını hazırla
    await setupTestEnvironment();

    // Test için gerekli controller'ları yükle
    Get.put(ResponsiveController());

    // Ana widget'ı oluştur
    await tester.pumpWidget(const MyApp());

    // Widget ağacının oluşturulmasını bekle
    await tester.pumpAndSettle();

    // Temel widget'ların varlığını kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

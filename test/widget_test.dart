import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('麻將計分器應用啟動測試', (WidgetTester tester) async {
    // 構建應用並觸發框架
    await tester.pumpWidget(const MyApp());

    // 等待啟動畫面載入
    await tester.pump(const Duration(seconds: 1));
    
    // 驗證啟動畫面元素
    expect(find.text('麻將計分器'), findsOneWidget);
    expect(find.text('讓計分更簡單'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
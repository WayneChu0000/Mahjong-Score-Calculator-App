// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:flutter_application_1/main.dart';

// void main() {
//   testWidgets('Game app UI elements test', (WidgetTester tester) async {
//     // Build our app and trigger a frame
//     await tester.pumpWidget(const GameApp());

//     // Verify that the game screen appears
//     expect(find.byType(GameScreen), findsOneWidget);
    
//     // Verify that the buttons appear
//     expect(find.text('Start New Game'), findsOneWidget);
//     expect(find.text('Rules'), findsOneWidget);
    
//     // Verify that DiceTiles are rendered
//     expect(find.byType(DiceTile), findsWidgets);
    
//     // Test the "Start New Game" button
//     await tester.tap(find.text('Start New Game'));
//     await tester.pumpAndSettle(); // Wait for dialog animation
    
//     // Verify the dialog appears
//     expect(find.text('New Game'), findsOneWidget);
//     expect(find.text('Starting new game...'), findsOneWidget);
//     expect(find.text('OK'), findsOneWidget);
    
//     // Close the dialog
//     await tester.tap(find.text('OK'));
//     await tester.pumpAndSettle();
    
//     // Test the "Rules" button
//     await tester.tap(find.text('Rules'));
//     await tester.pumpAndSettle();
    
//     // Verify the rules dialog appears
//     expect(find.text('Game Rules'), findsOneWidget);
//     expect(find.text('Here are the game rules...'), findsOneWidget);
//     expect(find.text('Close'), findsOneWidget);
//   });
  
//   testWidgets('GameButton widget test', (WidgetTester tester) async {
//     bool buttonPressed = false;
    
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: GameButton(
//             text: 'Test Button',
//             color: Colors.blue,
//             onPressed: () {
//               buttonPressed = true;
//             },
//           ),
//         ),
//       ),
//     );
    
//     // Verify button appears with correct text
//     expect(find.text('Test Button'), findsOneWidget);
    
//     // Tap the button and verify callback is triggered
//     await tester.tap(find.text('Test Button'));
//     expect(buttonPressed, true);
//   });
  
//   testWidgets('DiceTile widget test', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       const MaterialApp(
//         home: Scaffold(
//           body: DiceTile(),
//         ),
//       ),
//     );
    
//     // Verify dice tile has correct components
//     expect(find.byType(Container), findsWidgets);
//     expect(find.byType(Icon), findsOneWidget);
//     expect(find.byIcon(Icons.circle), findsOneWidget);
//   });
// }
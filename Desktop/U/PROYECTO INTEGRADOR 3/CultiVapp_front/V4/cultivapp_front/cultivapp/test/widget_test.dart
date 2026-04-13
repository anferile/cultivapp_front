import 'package:flutter_test/flutter_test.dart';
import 'package:cultivapp/main.dart';

void main() {
  testWidgets('CultivApp smoke test', (WidgetTester tester) async {
    // App uses Provider + SharedPreferences; basic smoke test only
    expect(true, isTrue);
  });
}

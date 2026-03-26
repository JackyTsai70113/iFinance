import 'package:flutter_test/flutter_test.dart';
import 'package:ifinance/main.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const IFinanceApp());
    expect(find.text('我的帳本'), findsOneWidget);
  });
}

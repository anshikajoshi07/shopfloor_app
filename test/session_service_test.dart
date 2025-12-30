import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopfloor_app/models/user_session.dart';
import 'package:shopfloor_app/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('save and load session', () async {
    final session = UserSession(email: 'a@b.com', role: 'Operator', tenantId: 't1', mockJwt: 'jwt123');
    await SessionService.saveSession(session);

    final loaded = await SessionService.loadSession();
    expect(loaded, isNotNull);
    expect(loaded!.email, session.email);
    expect(loaded.role, session.role);
    expect(loaded.tenantId, session.tenantId);
    expect(loaded.mockJwt, session.mockJwt);
  });

  test('clear session', () async {
    final session = UserSession(email: 'a@b.com', role: 'Operator', tenantId: 't1', mockJwt: 'jwt123');
    await SessionService.saveSession(session);
    await SessionService.clearSession();
    final loaded = await SessionService.loadSession();
    expect(loaded, isNull);
  });
}

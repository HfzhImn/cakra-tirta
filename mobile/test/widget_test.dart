import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile/data/api_client.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('backend zones and projection flow appear across tabs', (
    tester,
  ) async {
    final api = ApiClient(
      baseUrl: 'http://test.local',
      client: MockClient((request) async {
        if (request.url.path == '/api/risk-zones') {
          return http.Response(
            jsonEncode({
              'source': 'demo',
              'isDemo': true,
              'data': [
                {
                  'id': 'demo-zone-01',
                  'kelurahan': 'Zona Contoh Utara',
                  'kecamatan': 'Wilayah ilustrasi',
                  'risk_level': 'waspada',
                  'subsidence_rate_cm_year': 8.4,
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'source': 'demo',
            'isDemo': true,
            'data': {
              'year': int.parse(request.url.queryParameters['year']!),
              'riskLevel': 'bahaya',
              'projectedElevationCm': -63.6,
              'estimatedFloodDaysPerYear': 76,
              'notice': 'Angka ilustrasi untuk demo.',
            },
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(CakraTirtaApp(apiClient: api));
    await tester.pumpAndSettle();
    expect(find.textContaining('Zona Contoh Utara'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);

    await tester.tap(find.text('Peta'));
    await tester.pumpAndSettle();
    expect(find.text('Zona Contoh Utara'), findsOneWidget);

    await tester.tap(find.text('Simulasi'));
    await tester.pumpAndSettle();
    expect(find.text('Elevasi proyeksi'), findsOneWidget);
    expect(find.text('-63.6 cm'), findsOneWidget);
    expect(find.text('Angka ilustrasi untuk demo.'), findsOneWidget);
  });
}

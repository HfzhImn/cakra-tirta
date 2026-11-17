import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RiskZone {
  const RiskZone({
    required this.id,
    required this.name,
    required this.district,
    required this.riskLevel,
    required this.subsidenceRate,
    required this.isDemo,
  });

  final String id;
  final String name;
  final String district;
  final String riskLevel;
  final double? subsidenceRate;
  final bool isDemo;

  factory RiskZone.fromJson(
    Map<String, dynamic> json, {
    required bool isDemo,
  }) => RiskZone(
    id: json['id'] as String,
    name: json['kelurahan'] as String,
    district: (json['kecamatan'] as String?) ?? '—',
    riskLevel: (json['risk_level'] as String?) ?? 'belum_dinilai',
    subsidenceRate: (json['subsidence_rate_cm_year'] as num?)?.toDouble(),
    isDemo: isDemo,
  );
}

class Projection {
  const Projection({
    required this.year,
    required this.riskLevel,
    required this.elevationCm,
    required this.floodDays,
    required this.isDemo,
    required this.notice,
  });

  final int year;
  final String riskLevel;
  final double elevationCm;
  final int floodDays;
  final bool isDemo;
  final String notice;

  factory Projection.fromJson(
    Map<String, dynamic> json, {
    required bool isDemo,
  }) => Projection(
    year: json['year'] as int,
    riskLevel: json['riskLevel'] as String,
    elevationCm: (json['projectedElevationCm'] as num).toDouble(),
    floodDays: json['estimatedFloodDaysPerYear'] as int,
    isDemo: isDemo,
    notice: (json['notice'] as String?) ?? '',
  );
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          (baseUrl ??
                  const String.fromEnvironment(
                    'API_BASE_URL',
                    defaultValue: 'http://localhost:4000',
                  ))
              .replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<List<RiskZone>> fetchRiskZones() async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/api/risk-zones'))
        .timeout(const Duration(seconds: 8));
    final body = _decode(response);
    final isDemo = body['isDemo'] == true;
    return (body['data'] as List<dynamic>)
        .map(
          (item) =>
              RiskZone.fromJson(item as Map<String, dynamic>, isDemo: isDemo),
        )
        .toList(growable: false);
  }

  Future<Projection> fetchProjection({
    required String zoneId,
    required int year,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/subsidence/projection',
    ).replace(queryParameters: {'zoneId': zoneId, 'year': '$year'});
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    final body = _decode(response);
    return Projection.fromJson(
      body['data'] as Map<String, dynamic>,
      isDemo: body['isDemo'] == true,
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        (body['message'] as String?) ??
            'Server mengembalikan HTTP ${response.statusCode}.',
      );
    }
    return body;
  }

  @visibleForTesting
  void close() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

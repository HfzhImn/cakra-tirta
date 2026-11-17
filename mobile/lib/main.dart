import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/api_client.dart';

void main() => runApp(const CakraTirtaApp());

class CakraTirtaApp extends StatelessWidget {
  const CakraTirtaApp({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cakra Tirta',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: AppShell(apiClient: apiClient ?? ApiClient()),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late Future<List<RiskZone>> _zonesFuture;

  @override
  void initState() {
    super.initState();
    _zonesFuture = widget.apiClient.fetchRiskZones();
  }

  void _reloadZones() {
    setState(() => _zonesFuture = widget.apiClient.fetchRiskZones());
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(zonesFuture: _zonesFuture, onRetry: _reloadZones),
      RiskMapScreen(zonesFuture: _zonesFuture, onRetry: _reloadZones),
      ProjectionScreen(
        apiClient: widget.apiClient,
        zonesFuture: _zonesFuture,
        onRetry: _reloadZones,
      ),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Simulasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.zonesFuture,
    required this.onRetry,
  });

  final Future<List<RiskZone>> zonesFuture;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<RiskZone>>(
    future: zonesFuture,
    builder: (context, snapshot) {
      final zones = snapshot.data ?? const <RiskZone>[];
      final firstZone = zones.isEmpty ? null : zones.first;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const _TopBar(),
          const SizedBox(height: 26),
          Text(
            'Pantau pesisir,',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'mulai dari sekitarmu.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          if (snapshot.hasError)
            _LoadError(
              onRetry: onRetry,
              message:
                  'Data zona tidak dapat dimuat. Pastikan API sedang berjalan.',
            ),
          if (snapshot.hasError) const SizedBox(height: 12),
          if (snapshot.connectionState == ConnectionState.waiting)
            const LinearProgressIndicator(),
          if (snapshot.connectionState == ConnectionState.waiting)
            const SizedBox(height: 12),
          if (snapshot.hasData)
            _RiskCard(zone: firstZone, isDemo: firstZone?.isDemo ?? false),
          const SizedBox(height: 14),
          const _SectionHeading(
            title: 'Kondisi hari ini',
            trailing: 'Sumber data',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: _MetricCard(
                  icon: Icons.water,
                  label: 'Pasang',
                  value: '—',
                  unit: 'belum terhubung',
                  color: AppColors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.terrain_outlined,
                  label: 'Amblesan',
                  value: firstZone?.subsidenceRate?.toStringAsFixed(1) ?? '—',
                  unit: firstZone == null
                      ? 'data belum tersedia'
                      : 'cm / tahun${firstZone.isDemo ? ' · demo' : ''}',
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionHeading(title: 'Jelajahi', trailing: 'Semarang'),
          const SizedBox(height: 10),
          const _ExploreTile(
            icon: Icons.map_outlined,
            title: 'Peta risiko rob',
            subtitle: 'Zona dari API',
            color: AppColors.teal,
          ),
          const SizedBox(height: 9),
          const _ExploreTile(
            icon: Icons.query_stats,
            title: 'Lihat proyeksi',
            subtitle: 'Model dasar 2026–2045',
            color: AppColors.amber,
          ),
          const SizedBox(height: 18),
          const _DataNote(),
        ],
      );
    },
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.water_drop_outlined,
          color: AppColors.teal,
          size: 21,
        ),
      ),
      const SizedBox(width: 10),
      Text('cakra tirta', style: Theme.of(context).textTheme.titleLarge),
      const Spacer(),
      IconButton(
        tooltip: 'Notifikasi',
        onPressed: () => _showInfo(
          context,
          'Notifikasi belum tersedia',
          'Peringatan akan muncul setelah sumber data pasang terhubung.',
        ),
        icon: const Icon(Icons.notifications_none, color: AppColors.muted),
      ),
    ],
  );
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.zone, required this.isDemo});

  final RiskZone? zone;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    final label = switch (zone?.riskLevel) {
      'bahaya' => 'Risiko tinggi',
      'waspada' => 'Perlu pemantauan',
      'aman' => 'Risiko rendah',
      _ => zone?.name ?? 'Belum ada zona tersedia',
    };
    final status = isDemo ? '$label · ilustrasi' : label;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    zone?.district.toUpperCase() ?? 'KOTA SEMARANG',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                if (isDemo) _DemoBadge(),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              zone == null ? 'Belum ada data zona' : status,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              isDemo
                  ? '${zone?.name ?? ''} · data ilustrasi, bukan pengukuran atau peringatan resmi.'
                  : 'Data berasal dari backend Cakra Tirta.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Ikuti kanal resmi BMKG dan BPBD untuk kondisi terkini.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.amber.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'DEMO',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.amber,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const Spacer(),
      Text(
        trailing,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 25),
          ),
          Text(
            unit,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      leading: Icon(icon, color: color),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 15,
        color: AppColors.muted,
      ),
      onTap: () => _showInfo(
        context,
        title,
        'Bagian ini masih menggunakan rancangan awal. Data dan fitur akan dihubungkan bertahap.',
      ),
    ),
  );
}

class _DataNote extends StatelessWidget {
  const _DataNote();

  @override
  Widget build(BuildContext context) => Text(
    'Nilai zona pada mode demo dibuat untuk menguji alur aplikasi; bukan hasil studi atau pengukuran lapangan.',
    style: Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: AppColors.muted, height: 1.5),
  );
}

class RiskMapScreen extends StatelessWidget {
  const RiskMapScreen({
    super.key,
    required this.zonesFuture,
    required this.onRetry,
  });

  final Future<List<RiskZone>> zonesFuture;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<RiskZone>>(
    future: zonesFuture,
    builder: (context, snapshot) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _PageTitle(
          title: 'Zona pantauan',
          subtitle: 'Daftar area dari backend',
        ),
        const SizedBox(height: 16),
        if (snapshot.connectionState == ConnectionState.waiting)
          const LinearProgressIndicator(),
        if (snapshot.hasError)
          _LoadError(onRetry: onRetry, message: 'API tidak dapat dihubungi.'),
        if (snapshot.hasData && snapshot.data!.isEmpty)
          const Text('Belum ada zona tersedia.'),
        for (final zone in snapshot.data ?? const <RiskZone>[]) ...[
          _ZoneTile(zone: zone),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        Text(
          'Peta dasar belum terhubung. Zona dan tingkat risiko dari mode demo sepenuhnya ilustratif; jangan gunakan untuk navigasi atau keputusan keselamatan.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.5),
        ),
      ],
    ),
  );
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({required this.zone});

  final RiskZone zone;

  @override
  Widget build(BuildContext context) {
    final color = switch (zone.riskLevel) {
      'bahaya' => AppColors.coral,
      'waspada' => AppColors.amber,
      'aman' => AppColors.teal,
      _ => AppColors.muted,
    };
    return Card(
      child: ListTile(
        leading: Icon(Icons.place_outlined, color: color),
        title: Text(zone.name),
        subtitle: Text(
          '${zone.district} · ${zone.subsidenceRate?.toStringAsFixed(1) ?? '—'} cm/tahun',
        ),
        trailing: zone.isDemo
            ? const _DemoBadge()
            : Icon(Icons.circle, color: color, size: 10),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry, required this.message});

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: AppColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    ),
  );
}

class ProjectionScreen extends StatefulWidget {
  const ProjectionScreen({
    super.key,
    required this.apiClient,
    required this.zonesFuture,
    required this.onRetry,
  });

  final ApiClient apiClient;
  final Future<List<RiskZone>> zonesFuture;
  final VoidCallback onRetry;

  @override
  State<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends State<ProjectionScreen> {
  int _year = 2035;
  int _requestedYear = 2035;
  String? _selectedZoneId;
  final Map<String, Future<Projection>> _projectionCache = {};

  Future<Projection> _projectionFor(String zoneId, int year) {
    final key = '$zoneId:$year';
    return _projectionCache.putIfAbsent(
      key,
      () => widget.apiClient.fetchProjection(zoneId: zoneId, year: year),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<RiskZone>>(
    future: widget.zonesFuture,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _PageTitle(
              title: 'Simulasi masa depan',
              subtitle: 'Data zona belum tersedia',
            ),
            const SizedBox(height: 16),
            _LoadError(
              onRetry: widget.onRetry,
              message: 'Zona tidak dapat dimuat dari API.',
            ),
          ],
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final zones = snapshot.data!;
      if (zones.isEmpty) {
        return const Center(child: Text('Belum ada zona untuk disimulasikan.'));
      }
      final zoneId = zones.any((zone) => zone.id == _selectedZoneId)
          ? _selectedZoneId!
          : zones.first.id;
      final zone = zones.firstWhere((item) => item.id == zoneId);
      return _buildProjection(
        context,
        zones,
        zone,
        _projectionFor(zoneId, _requestedYear),
      );
    },
  );

  Widget _buildProjection(
    BuildContext context,
    List<RiskZone> zones,
    RiskZone zone,
    Future<Projection> future,
  ) {
    final year = _year;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _PageTitle(
          title: 'Simulasi masa depan',
          subtitle: 'Skenario berdasarkan zona terpilih',
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: zone.id,
          decoration: const InputDecoration(labelText: 'Zona'),
          items: [
            for (final item in zones)
              DropdownMenuItem(value: item.id, child: Text(item.name)),
          ],
          onChanged: (value) => setState(() {
            _selectedZoneId = value;
            _requestedYear = _year;
          }),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$year',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 38),
                ),
                Slider(
                  value: _year.toDouble(),
                  min: 2026,
                  max: 2045,
                  divisions: 19,
                  label: '$year',
                  onChanged: (value) => setState(() => _year = value.round()),
                  onChangeEnd: (value) =>
                      setState(() => _requestedYear = value.round()),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('2026'), Text('2045')],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<Projection>(
          future: future,
          builder: (context, result) {
            if (result.hasError) {
              return _LoadError(
                onRetry: () => setState(
                  () => _projectionCache.remove('${zone.id}:$_requestedYear'),
                ),
                message: 'Proyeksi belum tersedia untuk zona ini.',
              );
            }
            if (!result.hasData) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: LinearProgressIndicator(),
                ),
              );
            }
            final projection = result.data!;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hasil proyeksi',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (projection.isDemo) const _DemoBadge(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ProjectionMetric(
                      label: 'Risiko skenario',
                      value: projection.riskLevel.toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    _ProjectionMetric(
                      label: 'Elevasi proyeksi',
                      value: '${projection.elevationCm.toStringAsFixed(1)} cm',
                    ),
                    const SizedBox(height: 12),
                    _ProjectionMetric(
                      label: 'Estimasi hari tergenang',
                      value: '${projection.floodDays} hari/tahun',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      projection.notice,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Model linear ilustratif; belum memperhitungkan pasang, perubahan garis pantai, atau mitigasi. Bukan prediksi resmi.',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.muted, height: 1.5),
        ),
      ],
    );
  }
}

class _ProjectionMetric extends StatelessWidget {
  const _ProjectionMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
      ),
      Text(value, style: Theme.of(context).textTheme.titleMedium),
    ],
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _PageTitle(title: 'Profil', subtitle: 'Pengaturan dan informasi'),
      const SizedBox(height: 20),
      const _ExploreTile(
        icon: Icons.location_on_outlined,
        title: 'Lokasi pantauan',
        subtitle: 'Belum ada lokasi tersimpan',
        color: AppColors.teal,
      ),
      const SizedBox(height: 10),
      const _ExploreTile(
        icon: Icons.info_outline,
        title: 'Tentang Cakra Tirta',
        subtitle: 'Peringatan dini rob untuk Semarang',
        color: AppColors.amber,
      ),
      const SizedBox(height: 20),
      Text(
        'Aplikasi prototipe. Informasi risiko belum terhubung ke sumber data operasional dan tidak menggantikan arahan otoritas.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.55),
      ),
    ],
  );
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 5),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
      ),
    ],
  );
}

void _showInfo(BuildContext context, String title, String message) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}

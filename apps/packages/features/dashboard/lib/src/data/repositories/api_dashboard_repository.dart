import 'package:core_models/core_models.dart';
import 'package:core_network/core_connectivity.dart';
import 'package:core_network/core_network.dart';
import 'package:hive_ce/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../mappers/dashboard_summary_mapper.dart';
import 'dashboard_repository.dart';

/// Loads dashboard summary from the API with offline Hive cache.
final class ApiDashboardRepository
    with DashboardSummaryMapper, ConnectivityAware, DioAware
    implements DashboardRepository {
  ApiDashboardRepository(this.ref, {this.boxName = 'dashboard_summary_cache'});

  @override
  final Ref ref;

  final String boxName;

  static const _path = '/dashboard/summary';

  Box<String>? _box;

  Future<Box<String>> get _boxAsync async {
    final cached = _box;
    if (cached != null && cached.isOpen) {
      return cached;
    }
    final opened = await Hive.openBox<String>(boxName);
    _box = opened;
    return opened;
  }

  @override
  Future<Result<DashboardSummary>> getSummary() => fetchWithOfflineCache(
    connectivity: connectivity,
    getCached: _getCached,
    saveCached: _saveCached,
    fetchRemote: () =>
        dioGetEnvelope(dio: dio, path: _path, fromJson: summaryFromJson),
    emptyCacheMessage: 'No cached dashboard data available',
  );

  Future<DashboardSummary?> _getCached() async {
    final box = await _boxAsync;
    final raw = box.get(DashboardSummaryMapper.cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return decodeSummary(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCached(DashboardSummary summary) async {
    final box = await _boxAsync;
    await box.put(DashboardSummaryMapper.cacheKey, encodeSummary(summary));
  }
}

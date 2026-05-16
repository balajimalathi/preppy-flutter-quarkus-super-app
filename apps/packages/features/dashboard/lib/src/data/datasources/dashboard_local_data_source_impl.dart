import 'package:hive_ce/hive.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../mappers/dashboard_summary_mapper.dart';
import 'dashboard_local_data_source.dart';

final class DashboardLocalDataSourceImpl
    with DashboardSummaryMapper
    implements DashboardLocalDataSource {
  DashboardLocalDataSourceImpl({this.boxName = 'dashboard_summary_cache'});

  final String boxName;
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
  Future<DashboardSummary?> getSummary() async {
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

  @override
  Future<void> saveSummary(DashboardSummary summary) async {
    final box = await _boxAsync;
    await box.put(DashboardSummaryMapper.cacheKey, encodeSummary(summary));
  }
}

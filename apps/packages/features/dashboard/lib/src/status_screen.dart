import 'package:core_di/core_di.dart';
import 'package:core_notifications/core_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  String? _fcmToken;
  bool _loadingToken = false;

  @override
  void initState() {
    super.initState();
    _refreshFcmToken();
  }

  Future<void> _refreshFcmToken() async {
    setState(() => _loadingToken = true);
    final token = await CoreNotificationsFacade.instance
        .requestFirebaseAppToken();
    if (!mounted) return;
    setState(() {
      _fcmToken = token;
      _loadingToken = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final network = ref.read(dioProvider);
    final pushLog = PushReceiveDebugLog.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
        actions: [
          IconButton(
            tooltip: 'Clear push log',
            onPressed: () => pushLog.clear(),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final response = await network.get('/status');
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.data.toString())));
        },
        child: const Icon(Icons.refresh),
      ),
      body: ListenableBuilder(
        listenable: pushLog.events,
        builder: (context, _) {
          final events = pushLog.events.value;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Push payload log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                events.isEmpty
                    ? 'No push payloads yet. After curl, look for silent + '
                          'created/displayed events and the system tray.'
                    : '${events.length} payload(s). '
                          'silent = FCM received · created/displayed = shown in tray.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _FcmTokenCard(
                token: _fcmToken,
                loading: _loadingToken,
                onRefresh: _refreshFcmToken,
              ),
              const SizedBox(height: 16),
              if (events.isEmpty)
                const ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text('Waiting for FCM…'),
                )
              else
                ...events.map((e) => _PushEventTile(event: e)),
            ],
          );
        },
      ),
    );
  }
}

class _FcmTokenCard extends StatelessWidget {
  const _FcmTokenCard({
    required this.token,
    required this.loading,
    required this.onRefresh,
  });

  final String? token;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'FCM token',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh token',
                  onPressed: loading ? null : onRefresh,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              token ?? '(null — check Firebase / permissions)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PushEventTile extends StatelessWidget {
  const _PushEventTile({required this.event});

  final PushReceiveEvent event;

  @override
  Widget build(BuildContext context) {
    final time =
        '${event.at.hour.toString().padLeft(2, '0')}:'
        '${event.at.minute.toString().padLeft(2, '0')}:'
        '${event.at.second.toString().padLeft(2, '0')}';
    final mapperNote = _mapperPreview();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(_iconFor(event.kind)),
        title: Text('${event.kindLabel} · $time'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.summary),
            if (mapperNote != null) ...[
              const SizedBox(height: 4),
              Text(
                mapperNote,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: event.prettyJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payload JSON copied')),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy JSON'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SelectableText(
              event.prettyJson,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String? _mapperPreview() {
    final facade = CoreNotificationsFacade.instance;
    if (!facade.isLocalInitialized) {
      return null;
    }
    try {
      final data = event.dataForMapper;
      if (data.isEmpty) {
        return 'Mapper: no fields in raw payload';
      }
      final normalized = PushPayloadMapper.normalizeFcmData(data);
      final content = facade.payloadMapper.toNotificationContent(data);
      if (content == null) {
        return 'Mapper: would NOT show (no channel_key in payload)';
      }
      final channelKey = content.channelKey;
      if (channelKey == null) {
        return 'Mapper: mapped but no channelKey on content';
      }
      if (!facade.payloadMapper.isKnownChannel(channelKey)) {
        return 'Mapper: unknown channel "$channelKey" '
            '(registered: general, content)';
      }
      final enabled = facade.preferences.isChannelEnabled(channelKey);
      final via = normalized.containsKey('content.channelKey')
          ? 'Awesome flattened'
          : 'flat keys';
      return 'Mapper: can show on "$channelKey" ($via) · pref: $enabled · '
          'look for created/displayed events if tray notification appears';
    } catch (_) {
      return 'Mapper: unavailable';
    }
  }

  IconData _iconFor(PushReceiveKind kind) => switch (kind) {
    PushReceiveKind.created => Icons.add_alert,
    PushReceiveKind.displayed => Icons.notifications_active,
    PushReceiveKind.silentData => Icons.cloud_download,
    PushReceiveKind.action => Icons.touch_app,
    PushReceiveKind.dismissed => Icons.notifications_off,
  };
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'crop_detail_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final alerts = _buildAlerts(state);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 110,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'Alertas y Notificaciones',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (alerts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                        child: Text('${alerts.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: alerts.isEmpty
                ? SliverToBoxAdapter(
                    child: EmptyState(
                      message: 'Todo está al día.\nNo hay alertas pendientes.',
                      icon: Icons.check_circle_outline,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AlertItem(data: alerts[i], state: state),
                      childCount: alerts.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildAlerts(AppState state) {
    final alerts = <Map<String, dynamic>>[];
    for (final crop in state.crops) {
      final last = state.lastActivityForCrop(crop.id);
      if (last == null) {
        alerts.add({
          'title': 'Sin actividades',
          'message': '"${crop.name}" no tiene actividades registradas.',
          'color': AppColors.warning,
          'icon': Icons.warning_amber_outlined,
          'type': 'warning',
          'cropId': crop.id,
        });
      } else {
        final diff = DateTime.now().difference(last.date).inDays;
        if (diff > 14) {
          alerts.add({
            'title': 'Sin actividad reciente',
            'message': '"${crop.name}" lleva $diff días sin actividades.',
            'color': AppColors.error,
            'icon': Icons.schedule,
            'type': 'danger',
            'cropId': crop.id,
          });
        } else if (diff > 7) {
          alerts.add({
            'title': 'Actividad pendiente',
            'message': '"${crop.name}" tiene $diff días sin actividades.',
            'color': AppColors.info,
            'icon': Icons.info_outline,
            'type': 'info',
            'cropId': crop.id,
          });
        }
      }
    }
    if (state.crops.isNotEmpty && state.activities.isEmpty) {
      alerts.add({
        'title': 'Comienza a registrar',
        'message': 'Tienes cultivos pero aún no has registrado actividades.',
        'color': AppColors.primary,
        'icon': Icons.add_circle_outline,
        'type': 'info',
        'cropId': null,
      });
    }
    return alerts;
  }
}

class _AlertItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final AppState state;
  const _AlertItem({required this.data, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color = data['color'] as Color;
    final IconData icon = data['icon'] as IconData;
    final String? cropId = data['cropId'] as String?;

    return GestureDetector(
      onTap: cropId != null
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailScreen(cropId: cropId)))
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.12), color.withOpacity(0.04)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'] as String, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(data['message'] as String, style: TextStyle(fontSize: 13, height: 1.4, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ),
            ),
            if (cropId != null) Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

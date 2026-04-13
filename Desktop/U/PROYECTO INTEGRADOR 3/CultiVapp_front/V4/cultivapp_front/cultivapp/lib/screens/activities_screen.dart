import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'add_activity_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  ActivityType? _filterType;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    var activities = state.allActivitiesSorted;
    if (_filterType != null) activities = activities.where((a) => a.type == _filterType).toList();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final totalCost = activities.fold(0.0, (sum, a) => sum + a.cost);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 130,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    const Text('Actividades', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                      child: Text(currency.format(totalCost), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _buildChip('Todas', null),
                  const SizedBox(width: 8),
                  ...ActivityType.values.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildChip(t.label, t, color: t.color),
                  )),
                ],
              ),
            ),
          ),
          activities.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    message: 'No hay actividades registradas.\nVe al detalle de un cultivo para agregar una.',
                    icon: Icons.assignment_outlined,
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final a = activities[i];
                        final crop = state.crops.where((c) => c.id == a.cropId).firstOrNull
                            ?? state.archivedCrops.where((c) => c.id == a.cropId).firstOrNull;
                        return _ActivityListItem(activity: a, cropName: crop?.name ?? 'Cultivo eliminado', state: state);
                      },
                      childCount: activities.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: state.crops.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddActivityScreen(cropId: state.crops.first.id)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nueva actividad'),
            ),
    );
  }

  Widget _buildChip(String label, ActivityType? type, {Color? color}) {
    final c = color ?? AppColors.primary;
    final selected = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type == _filterType ? null : type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: [c, c.withOpacity(0.75)]) : null,
          color: selected ? null : c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.4)),
          boxShadow: selected ? [BoxShadow(color: c.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : c, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final Activity activity;
  final String cropName;
  final AppState state;
  const _ActivityListItem({required this.activity, required this.cropName, required this.state});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activity.type.color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: activity.type.color.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [activity.type.color.withOpacity(0.2), activity.type.color.withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.type.icon, color: activity.type.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.type.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(cropName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(activity.description, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(dateFormat.format(activity.date), style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(activity.cost), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => state.deleteActivity(activity.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

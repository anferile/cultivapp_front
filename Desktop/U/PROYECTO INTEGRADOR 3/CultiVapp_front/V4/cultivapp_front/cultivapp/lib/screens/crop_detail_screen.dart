import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'add_activity_screen.dart';
import 'expenses_screen.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final crop = state.cropById(cropId);
    if (crop == null) {
      return const Scaffold(body: Center(child: Text('Cultivo no encontrado')));
    }
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final activities = state.activitiesForCrop(cropId);
    final expenses = state.expensesForCrop(cropId);
    final totalCost = state.totalCostForCrop(cropId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(crop.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark ? AppColors.heroGradientDark : AppColors.heroGradientLight,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(crop.status.icon, color: Colors.white.withOpacity(0.25), size: 100),
                ),
              ),
            ),
            actions: [
              if (!crop.isArchived)
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showActions(context, state, crop),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: crop.status.color.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(crop.type, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                StatusBadge(label: crop.status.label, color: crop.status.color),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currency.format(totalCost),
                                  style: TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.w800)),
                              const Text('Total invertido', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      _DetailRow(icon: Icons.location_on_outlined, label: 'Ubicación', value: crop.location),
                      const SizedBox(height: 6),
                      _DetailRow(icon: Icons.calendar_today_outlined, label: 'Siembra', value: dateFormat.format(crop.sowingDate)),
                      if (crop.isArchived) ...[
                        const SizedBox(height: 6),
                        _DetailRow(icon: Icons.archive_outlined, label: 'Motivo', value: crop.archiveReason ?? '', color: AppColors.warning),
                        const SizedBox(height: 6),
                        _DetailRow(icon: Icons.event_available, label: 'Archivado', value: dateFormat.format(crop.archivedAt ?? DateTime.now()), color: AppColors.warning),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!crop.isArchived)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AddActivityScreen(cropId: cropId)),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Actividad'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AddExpenseScreen(cropId: cropId)),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Gasto'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 46),
                            backgroundColor: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                SectionHeader(title: 'Actividades (${activities.length})'),
                const SizedBox(height: 10),
                if (activities.isEmpty)
                  const EmptyState(message: 'Sin actividades registradas', icon: Icons.assignment_outlined)
                else
                  ...activities.map((a) => _ActivityCard(activity: a, state: state)),
                const SizedBox(height: 20),
                SectionHeader(title: 'Gastos (${expenses.length})'),
                const SizedBox(height: 10),
                if (expenses.isEmpty)
                  const EmptyState(message: 'Sin gastos registrados', icon: Icons.receipt_long_outlined)
                else
                  ...expenses.map((e) => _ExpenseCard(expense: e, state: state)),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, AppState state, Crop crop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Acciones del cultivo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.agriculture,
              label: 'Marcar como cosechado',
              color: AppColors.accentYellow,
              onTap: () {
                Navigator.pop(context);
                _showArchiveDialog(context, state, crop, CropStatus.harvested);
              },
            ),
            _ActionTile(
              icon: Icons.cancel_outlined,
              label: 'Cancelar cultivo',
              color: AppColors.warning,
              onTap: () {
                Navigator.pop(context);
                _showArchiveDialog(context, state, crop, CropStatus.cancelled);
              },
            ),
            _ActionTile(
              icon: Icons.delete_forever_outlined,
              label: 'Eliminar permanentemente',
              color: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, state, crop);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, AppState state, Crop crop, CropStatus finalStatus) {
    final reasonController = TextEditingController(
      text: finalStatus == CropStatus.harvested ? 'Cosecha completada' : 'Cultivo cancelado',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(finalStatus.icon, color: finalStatus.color),
            const SizedBox(width: 8),
            Text(finalStatus == CropStatus.harvested ? 'Cosechar cultivo' : 'Cancelar cultivo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('El cultivo "${crop.name}" será archivado. Sus datos y registros se conservarán.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              state.archiveCrop(crop.id, finalStatus, reasonController.text.trim());
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(finalStatus == CropStatus.harvested ? 'Cultivo cosechado y archivado' : 'Cultivo cancelado'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: finalStatus.color),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppState state, Crop crop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.error),
            SizedBox(width: 8),
            Text('Eliminar cultivo'),
          ],
        ),
        content: Text('¿Eliminar "${crop.name}" permanentemente?\n\nTodas sus actividades y gastos también se borrarán. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              state.deleteCrop(crop.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _DetailRow({required this.icon, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color ?? Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final AppState state;
  const _ActivityCard({required this.activity, required this.state});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: activity.type.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: activity.type.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(activity.type.icon, color: activity.type.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.type.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(activity.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(dateFormat.format(activity.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(activity.cost), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              GestureDetector(
                onTap: () => state.deleteActivity(activity.id),
                child: const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.delete_outline, size: 16, color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final AppState state;
  const _ExpenseCard({required this.expense, required this.state});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_long, color: AppColors.warning, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(expense.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(dateFormat.format(expense.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(expense.amount), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
              GestureDetector(
                onTap: () => state.deleteExpense(expense.id),
                child: const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.delete_outline, size: 16, color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

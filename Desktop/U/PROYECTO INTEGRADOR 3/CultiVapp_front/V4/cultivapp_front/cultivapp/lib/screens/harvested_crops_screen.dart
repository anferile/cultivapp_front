import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';
import 'crop_detail_screen.dart';

class HarvestedCropsScreen extends StatelessWidget {
  const HarvestedCropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final archived = state.archivedCrops.toList()
      ..sort((a, b) => (b.archivedAt ?? b.createdAt).compareTo(a.archivedAt ?? a.createdAt));

    if (archived.isEmpty) {
      return const EmptyState(
        message: 'No hay cultivos cosechados o archivados aún.\n\nCuando termines un cultivo, muévelo a cosechado desde su detalle.',
        icon: Icons.agriculture,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${archived.length} cultivo${archived.length == 1 ? '' : 's'} archivado${archived.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showExportDialog(context, state, archived),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Exportar PDF'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: archived.length,
            itemBuilder: (_, i) => _ArchivedCropCard(crop: archived[i]),
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context, AppState state, List<Crop> archived) {
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.error),
            SizedBox(width: 8),
            Text('Vista previa de exportación'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CULTIVAPP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary, letterSpacing: 2)),
                      const Text('Informe de Cultivos Archivados', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Generado: ${dateFormat.format(DateTime.now())}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...archived.map((c) {
                  final total = state.totalCostForCrop(c.id);
                  final acts = state.activitiesForCrop(c.id).length;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: c.status.color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                            StatusBadge(label: c.status.label, color: c.status.color),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Tipo: ${c.type}  |  Ubicación: ${c.location}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Siembra: ${dateFormat.format(c.sowingDate)}  |  Actividades: $acts', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (c.archiveReason != null)
                          Text('Motivo: ${c.archiveReason}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Total invertido: ${currency.format(total)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 13)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL GENERAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      Text(
                        currency.format(archived.fold(0.0, (sum, c) => sum + state.totalCostForCrop(c.id))),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Función de exportación PDF disponible con el paquete pdf/printing en producción.'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Exportar'),
          ),
        ],
      ),
    );
  }
}

class _ArchivedCropCard extends StatelessWidget {
  final Crop crop;
  const _ArchivedCropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'es');
    final totalCost = state.totalCostForCrop(crop.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CropDetailScreen(cropId: crop.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark.withOpacity(0.7) : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: crop.status.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: crop.status.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(crop.status.icon, color: crop.status.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crop.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  Text('${crop.type}  •  ${crop.location}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (crop.archiveReason != null)
                    Text('Motivo: ${crop.archiveReason}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                    crop.archivedAt != null ? 'Archivado: ${dateFormat.format(crop.archivedAt!)}' : '',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(label: crop.status.label, color: crop.status.color),
                const SizedBox(height: 4),
                Text(currency.format(totalCost), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

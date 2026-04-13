import 'package:flutter/material.dart';
import '../widgets/shared_widgets.dart';
import '../theme/app_theme.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: GradientHeader(
              height: 130,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Manual de uso', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Guía paso a paso para agricultores', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _IntroCard(),
                const SizedBox(height: 16),
                ..._sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ManualSection(data: s),
                )),
                const SizedBox(height: 24),
                _TipCard(
                  tip: 'Recuerda registrar cada actividad apenas la hagas. Así no perderás ningún dato importante de tu cultivo.',
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? AppColors.cardGradientDark : [const Color(0xFFE8F5E9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bienvenido a CultivApp', style: Theme.of(context).textTheme.titleLarge),
                    const Text('Tu bitácora digital del campo', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'CultivApp te ayuda a llevar el control de tus cultivos de forma fácil y organizada, sin necesidad de papeles ni cuadernos que se pueden perder.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ManualSection extends StatefulWidget {
  final Map<String, dynamic> data;
  const _ManualSection({required this.data});

  @override
  State<_ManualSection> createState() => _ManualSectionState();
}

class _ManualSectionState extends State<_ManualSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.data['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.03)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(widget.data['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.data['title'] as String, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15)),
                      Text(widget.data['subtitle'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down, color: color),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Divider(color: color.withOpacity(0.2), height: 1),
              const SizedBox(height: 12),
              ...(widget.data['steps'] as List<Map<String, String>>).map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 10, top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(step['num']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(step['desc']!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.accentYellow.withOpacity(0.2), AppColors.accentYellow.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentYellow.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.accentYellow.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consejo del campo', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 13)),
                const SizedBox(height: 3),
                Text(tip, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<Map<String, dynamic>> _sections = [
  {
    'title': 'Registrar un cultivo',
    'subtitle': 'Agrega tus parcelas o siembras',
    'icon': Icons.grass,
    'color': AppColors.primary,
    'steps': [
      {'num': '1', 'title': 'Ve a la pestaña "Cultivos"', 'desc': 'En la barra de abajo, toca el ícono de la hoja verde que dice "Cultivos".'},
      {'num': '2', 'title': 'Toca el botón "Nuevo cultivo"', 'desc': 'Verás un botón verde en la parte inferior de la pantalla con un signo +.'},
      {'num': '3', 'title': 'Llena el formulario', 'desc': 'Escribe el nombre del cultivo, qué tipo es (maíz, tomate, etc.), dónde está ubicado y cuándo lo sembraste.'},
      {'num': '4', 'title': 'Guarda el cultivo', 'desc': 'Toca "Guardar Cultivo". Aparecerá en tu lista listo para registrar actividades.'},
    ],
  },
  {
    'title': 'Registrar actividades',
    'subtitle': 'Riego, fumigación, fertilización...',
    'icon': Icons.assignment,
    'color': AppColors.info,
    'steps': [
      {'num': '1', 'title': 'Entra al cultivo o ve a Actividades', 'desc': 'Puedes tocar un cultivo y usar el botón "Actividad", o ir directo a la pestaña "Actividades".'},
      {'num': '2', 'title': 'Elige el tipo de actividad', 'desc': 'Selecciona si fue riego, fertilización, fumigación, cosecha u otro trabajo.'},
      {'num': '3', 'title': 'Escribe la descripción y el costo', 'desc': 'Anota qué hiciste exactamente y cuánto te costó esa actividad (en pesos colombianos).'},
      {'num': '4', 'title': 'Confirma la fecha', 'desc': 'Asegúrate de que la fecha sea correcta. Puedes cambiarla tocando el selector de fecha.'},
    ],
  },
  {
    'title': 'Registrar gastos',
    'subtitle': 'Semillas, abonos, herramientas...',
    'icon': Icons.attach_money,
    'color': AppColors.warning,
    'steps': [
      {'num': '1', 'title': 'Ve a la pestaña "Gastos"', 'desc': 'Toca el ícono de dinero en la barra de abajo.'},
      {'num': '2', 'title': 'Toca "Nuevo gasto"', 'desc': 'El botón verde aparece en la esquina inferior derecha.'},
      {'num': '3', 'title': 'Selecciona el cultivo y categoría', 'desc': 'Indica a qué cultivo pertenece este gasto y qué tipo es (semillas, fertilizantes, etc.).'},
      {'num': '4', 'title': 'Escribe el monto', 'desc': 'Ingresa cuánto gastaste en pesos. Esto se sumará al total invertido en ese cultivo.'},
    ],
  },
  {
    'title': 'Ver el resumen',
    'subtitle': 'Dashboard e información clave',
    'icon': Icons.dashboard,
    'color': AppColors.primary,
    'steps': [
      {'num': '1', 'title': 'Ve a la pantalla "Inicio"', 'desc': 'Al abrir la app, la primera pantalla muestra el resumen general de todos tus cultivos.'},
      {'num': '2', 'title': 'Toca las tarjetas de estadísticas', 'desc': 'Las tarjetas de "Cultivos activos" y "Total invertido" se pueden tocar para ver más detalle.'},
      {'num': '3', 'title': 'Revisa las actividades recientes', 'desc': 'Abajo verás las últimas actividades registradas para saber qué hiciste recientemente.'},
    ],
  },
  {
    'title': 'Cosechar o cancelar un cultivo',
    'subtitle': 'Mover al historial de cosechados',
    'icon': Icons.agriculture,
    'color': Color(0xFF8BC34A),
    'steps': [
      {'num': '1', 'title': 'Abre el detalle del cultivo', 'desc': 'Toca el cultivo en la lista. Verás toda su información.'},
      {'num': '2', 'title': 'Toca los tres puntos (⋮)', 'desc': 'En la esquina superior derecha del detalle del cultivo.'},
      {'num': '3', 'title': 'Elige "Marcar como cosechado"', 'desc': 'El cultivo pasará al historial de cosechados. Sus datos quedarán guardados.'},
      {'num': '4', 'title': 'Escribe el motivo (opcional)', 'desc': 'Puedes escribir una nota como "Buena cosecha" o "Se canceló por lluvia". Esto es opcional.'},
    ],
  },
  {
    'title': 'Revisar alertas',
    'subtitle': 'Cultivos que necesitan atención',
    'icon': Icons.notifications,
    'color': AppColors.warning,
    'steps': [
      {'num': '1', 'title': 'Ve a la pestaña "Alertas"', 'desc': 'Toca el ícono de la campana en la barra de abajo.'},
      {'num': '2', 'title': 'Lee las alertas', 'desc': 'La app te avisa si algún cultivo lleva muchos días sin actividades o necesita atención.'},
      {'num': '3', 'title': 'Toca la alerta para ir al cultivo', 'desc': 'Tocando una alerta, irás directo al cultivo para registrar lo que necesite.'},
    ],
  },
];

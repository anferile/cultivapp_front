# CultivApp

**Bitácora digital agrícola para pequeños y medianos productores.**

> Organiza · Registra · Mejora tu cultivo

---

## Descripción

CultivApp es una aplicación móvil desarrollada en Flutter orientada al sector agrícola. Permite a los productores llevar un registro detallado de sus cultivos, actividades agrícolas, gastos e insumos, facilitando la organización, el análisis del desempeño y la toma de decisiones.

### Funcionalidades principales

- Registro y gestión de cultivos (nombre, tipo, ubicación, fecha de siembra, estado)
- Registro de actividades agrícolas: riego, fertilización, fumigación, cosecha
- Registro de gastos e insumos asociados a cada cultivo
- Dashboard con resumen general, alertas simuladas y actividades recientes
- Historial completo de actividades y gastos
- Perfil de usuario y resumen por cultivo
- Modo oscuro / claro con toggle funcional
- Persistencia de sesión local
- Autenticación simulada con validaciones completas
- Interfaz en español, diseño mobile-first

---

## Requisitos

| Herramienta | Versión mínima |
|-------------|----------------|
| Flutter SDK | 3.10.0 o superior |
| Dart SDK    | 3.0.0 o superior |
| Android SDK | API 21+ |
| Xcode       | 14+ (solo para iOS/macOS) |

---

## Dependencias principales

```yaml
provider: ^6.1.1           # Gestión de estado
shared_preferences: ^2.2.2 # Persistencia local
intl: ^0.19.0              # Formato de fechas y moneda
uuid: ^4.3.3               # Generación de IDs únicos
fl_chart: ^0.66.2          # Gráficas (disponible para uso futuro)
google_fonts: ^6.2.1       # Tipografía Nunito
```

---

## Instalación

### 1. Clonar o descomprimir el proyecto

```bash
# Si lo descargaste como ZIP, descomprímelo y navega a la carpeta:
cd cultivapp
```

### 2. Verificar instalación de Flutter

```bash
flutter doctor
```

Asegúrate de que todos los checks relevantes estén en verde.

### 3. Instalar dependencias

```bash
flutter pub get
```

---

## Cómo ejecutar

### En un emulador Android / iOS

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en el dispositivo deseado
flutter run
```

### En Chrome (modo web, funcional pero no optimizado para móvil)

```bash
flutter run -d chrome
```

### Generar APK de debug

```bash
flutter build apk --debug
```

El APK se genera en: `build/app/outputs/flutter-apk/app-debug.apk`

---

## Cuenta de demostración

Al iniciar la app, puedes usar las credenciales de demo:

```
Correo:     carlos@cultivapp.co
Contraseña: Demo1234
```

O registrar una cuenta nueva desde la pantalla de registro.

---

## Estructura del proyecto

```
cultivapp/
├── assets/
│   └── images/
│       ├── logo_light.png       # Logo modo claro
│       └── logo_dark.png        # Logo modo oscuro
├── lib/
│   ├── main.dart                # Punto de entrada
│   ├── models/
│   │   └── models.dart          # Clases: Crop, Activity, Expense, AppUser
│   ├── state/
│   │   └── app_state.dart       # Provider principal (ChangeNotifier)
│   ├── theme/
│   │   └── app_theme.dart       # Temas claro y oscuro, colores, tipografía
│   ├── widgets/
│   │   └── shared_widgets.dart  # Widgets reutilizables
│   └── screens/
│       ├── login_screen.dart         # Pantalla de inicio de sesión
│       ├── register_screen.dart      # Pantalla de registro
│       ├── main_screen.dart          # Navegación principal (BottomNav)
│       ├── dashboard_screen.dart     # Dashboard con resumen
│       ├── crops_screen.dart         # Lista de cultivos con filtros
│       ├── add_crop_screen.dart      # Formulario nuevo cultivo
│       ├── crop_detail_screen.dart   # Detalle de cultivo
│       ├── activities_screen.dart    # Historial de actividades
│       ├── add_activity_screen.dart  # Formulario nueva actividad
│       ├── expenses_screen.dart      # Lista y registro de gastos
│       └── profile_screen.dart       # Perfil, configuración, resumen
├── pubspec.yaml
└── README.md
```

---

## Arquitectura

- **Gestión de estado:** Provider (ChangeNotifier)
- **Persistencia:** SharedPreferences (sesión de usuario, preferencia de tema)
- **Datos:** Simulados en memoria (sin backend ni API externa)
- **Patrón:** Separación por capas: models / state / screens / widgets / theme

---

## Notas

- La aplicación no requiere conexión a internet.
- Todos los datos se simulan en memoria; al cerrar la app se reinician (excepto sesión y tema).
- Para un entorno productivo se recomienda integrar SQLite (sqflite) o Hive para persistencia completa.

---

## Proyecto académico

Desarrollado como proyecto de demostración para la asignatura de desarrollo de aplicaciones móviles.

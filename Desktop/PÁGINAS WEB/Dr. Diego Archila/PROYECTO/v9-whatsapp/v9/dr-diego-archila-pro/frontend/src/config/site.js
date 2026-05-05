/**
 * src/config/site.js
 * ----------------------------------------------------------------------------
 * Configuración central del sitio. Editar este archivo es suficiente para
 * cambiar la información del consultorio en TODO el frontend.
 *
 * Dirección oficial confirmada:
 *   Centro Médico de Especialistas — Cra. 23 #30A-37, Floridablanca, Santander.
 * ----------------------------------------------------------------------------
 */

// Link literal de Google Maps que el cliente entregó (NO modificar).
const MAPS_URL =
  'https://www.google.com/maps/place/Centro+M%C3%A9dico+de+Especialistas/@7.0677469,-73.1076478,3a,75y,84.12h,99.5t/data=!3m7!1e1!3m5!1sKadZjvctANm4zd0IPDUL7Q!2e0!6shttps:%2F%2Fstreetviewpixels-pa.googleapis.com%2Fv1%2Fthumbnail%3Fcb_client%3Dmaps_sv.tactile%26w%3D900%26h%3D600%26pitch%3D-9.498763064392676%26panoid%3DKadZjvctANm4zd0IPDUL7Q%26yaw%3D84.1165076465706!7i16384!8i8192!4m15!1m8!3m7!1s0x8e683f6d9a886d41:0xc24f53f0c943a35c!2sCra.+23+%23+30a+-+37,+Floridablanca,+Santander,+Colombia!3b1!8m2!3d7.0679767!4d-73.1077367!16s%2Fg%2F11j3jdkbxc!3m5!1s0x8e683f6d96e4318b:0x33b1dcb25dab6665!8m2!3d7.0677676!4d-73.1075523!16s%2Fg%2F11h2gf80pv?hl=es&entry=ttu&g_ep=EgoyMDI2MDQyOS4wIKXMDSoASAFQAw%3D%3D'

// Embed apuntando a las mismas coordenadas (lat/lng del Centro Médico).
const MAPS_EMBED_SRC =
  'https://www.google.com/maps?q=Centro+M%C3%A9dico+de+Especialistas,+Cra.+23+%2330A-37,+Floridablanca,+Santander&hl=es&z=18&ll=7.0679767,-73.1077367&output=embed'

export const site = {
  doctor: {
    name: 'Dr. Diego Archila',
    fullName: 'Dr. Diego Armando Archila Acevedo',
    profession: 'Odontólogo Estético',
    phrase: 'Más que estética, es amor propio',
  },

  // ── UBICACIÓN ──────────────────────────────────────────────────────────────
  location: {
    building: 'Centro Médico de Especialistas',
    office: 'Consultorio 404',
    street: 'Cra. 23 #30A-37',
    city: 'Floridablanca',
    state: 'Santander',
    country: 'Colombia',
    mapsUrl:      MAPS_URL,
    mapsEmbedSrc: MAPS_EMBED_SRC,
  },

  contact: {
    phone: '311 363 9995',
    phoneE164: '+573113639995',
    whatsapp: 'https://wa.me/573113639995',
    whatsappPrefilled:
      'https://wa.me/573113639995?text=Hola%2C%20me%20gustar%C3%ADa%20agendar%20una%20cita',
    email: 'contacto@drdiegoarchila.com',
    instagram: 'https://www.instagram.com/drdiegoarchila/',
    facebook: 'https://www.facebook.com/profile.php?id=100088011938695',
    instagramHandle: '@drdiegoarchila',
  },

  hours: [
    { dia: 'Lunes',     hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Martes',    hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Miércoles', hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Jueves',    hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Viernes',   hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Sábado',    hora: '8:00 a.m. – 8:00 p.m.', cerrado: false },
    { dia: 'Domingo',   hora: 'Cerrado',               cerrado: true  },
  ],

  // ── SERVICIOS Y PRECIOS ────────────────────────────────────────────────────
  // Los precios se mantienen en backend para futuro pero NO se muestran al
  // paciente todavía (`showPrices: false`). Cuando el cliente quiera publicar
  // tarifas, basta con cambiar este flag a `true`.
  showPrices: false,
  services: [
    { id: 'valoracion',      title: 'Consulta de Valoración', tagline: 'El inicio de tu transformación', price: 80000,   currency: 'COP', duration: 45  },
    { id: 'limpieza',        title: 'Limpieza y Profilaxis',  tagline: 'La base de todo tratamiento',    price: 180000,  currency: 'COP', duration: 60  },
    { id: 'blanqueamiento',  title: 'Blanqueamiento Dental',  tagline: 'Luz en tu sonrisa',              price: 650000,  currency: 'COP', duration: 90  },
    { id: 'composite',       title: 'Composite Dental',       tagline: 'Restauraciones que se integran', price: 280000,  currency: 'COP', duration: 60  },
    { id: 'carillas',        title: 'Carillas en Resina',     tagline: 'Naturalidad en cada detalle',    price: 420000,  currency: 'COP', duration: 120 },
    { id: 'diseno-sonrisa',  title: 'Diseño de Sonrisa',      tagline: 'Tu identidad, redefinida',       price: 1500000, currency: 'COP', duration: 120 },
  ],

  // ── REGLAS DE AGENDA ───────────────────────────────────────────────────────
  // Estas reglas se reflejan en la UI; el backend valida igualmente y es la
  // fuente de verdad. Si cambias horario o festivos en el backend, actualiza
  // estos valores también para mantener la UX coherente.
  appointments: {
    yearsAhead: 2,           // se puede agendar hasta 2 años en el futuro
    workdayStart: 8,         // 8:00 AM (L–S)
    workdayEnd: 20,          // 8:00 PM (L–V)
    saturdayEnd: 14,         // 2:00 PM (sábados)
    slotMinutes: 60,
    leadMinutes: 60,         // anticipación mínima requerida
    holidays: [              // festivos colombianos (YYYY-MM-DD)
      '2025-01-01','2025-05-01','2025-07-20','2025-08-07','2025-12-08','2025-12-25',
      '2026-01-01','2026-05-01','2026-07-20','2026-08-07','2026-12-08','2026-12-25',
      '2027-01-01','2027-05-01','2027-07-20','2027-08-07','2027-12-08','2027-12-25',
    ],
  },

  payment: {
    description: 'Reserva de cita médica',
  },

  developer: {
    label: '@anferile',
    url: 'https://github.com/anferile',
  },
}

// ── Helpers ─────────────────────────────────────────────────────────────────
export function fullAddress() {
  const l = site.location
  return `${l.street}, ${l.city}, ${l.state}`
}

export function addressLines() {
  const l = site.location
  return [`${l.building}`, l.street, `${l.city}, ${l.state}`, l.country]
}

export default site

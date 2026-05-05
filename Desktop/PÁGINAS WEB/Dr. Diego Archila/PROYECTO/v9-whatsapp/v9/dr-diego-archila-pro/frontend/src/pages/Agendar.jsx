import React, { useMemo, useState } from 'react'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import { site } from '../config/site'
import './Agendar.css'

// Número de WhatsApp destino — cámbialo cuando el doctor lo confirme
const WHATSAPP_NUMBER = '573113639995'

const dayShort   = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
const monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
const stepsLabels = ['Servicio', 'Tus datos', 'Fecha y hora', 'Confirmar']

function fmt12h(hour24, minute = 0) {
  const ap = hour24 >= 12 ? 'PM' : 'AM'
  const h12 = ((hour24 + 11) % 12) + 1
  const mm = String(minute).padStart(2, '0')
  return `${h12}:${mm} ${ap}`
}

function ymd(date) {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

function prettyDate(yyyymmdd) {
  if (!yyyymmdd) return '—'
  const d = new Date(`${yyyymmdd}T12:00`)
  return d.toLocaleDateString('es-CO', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric',
  })
}

/* ───────── Calendario ───────────────────────────────────────────────────── */
function Calendar({ value, onChange }) {
  const today = useMemo(() => new Date(new Date().toDateString()), [])
  const max = useMemo(() => {
    const d = new Date(today)
    d.setFullYear(d.getFullYear() + site.appointments.yearsAhead)
    return d
  }, [today])

  const [view, setView] = useState(() => {
    const d = value ? new Date(`${value}T00:00`) : today
    return new Date(d.getFullYear(), d.getMonth(), 1)
  })

  const monthStart   = new Date(view.getFullYear(), view.getMonth(), 1)
  const monthEnd     = new Date(view.getFullYear(), view.getMonth() + 1, 0)
  const startWeekday = monthStart.getDay()
  const daysInMonth  = monthEnd.getDate()

  const cells = []
  for (let i = 0; i < startWeekday; i++) cells.push(null)
  for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(view.getFullYear(), view.getMonth(), d))

  const canPrev = monthStart > new Date(today.getFullYear(), today.getMonth(), 1)
  const canNext = new Date(view.getFullYear(), view.getMonth() + 1, 1) <= max
  const navMonth = (delta) => {
    const next = new Date(view); next.setMonth(view.getMonth() + delta); setView(next)
  }

  return (
    <div className="cal2">
      <div className="cal2__nav">
        <button type="button" className="cal2__navbtn" onClick={() => navMonth(-1)} disabled={!canPrev} aria-label="Mes anterior">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6"/></svg>
        </button>
        <div className="cal2__title">{monthNames[view.getMonth()]} {view.getFullYear()}</div>
        <button type="button" className="cal2__navbtn" onClick={() => navMonth(1)} disabled={!canNext} aria-label="Mes siguiente">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6"/></svg>
        </button>
      </div>

      <div className="cal2__weekdays">
        {dayShort.map((d, i) => (
          <span key={d} className={`cal2__weekday ${i === 0 ? 'cal2__weekday--off' : ''}`}>{d}</span>
        ))}
      </div>

      <div className="cal2__grid">
        {cells.map((d, i) => {
          if (!d) return <span key={`b${i}`} className="cal2__cell cal2__cell--blank" />
          const key      = ymd(d)
          const isPast   = d < today
          const isSunday = d.getDay() === 0
          const isHoliday = (site.appointments.holidays || []).includes(key)
          const isAfterMax = d > max
          const disabled = isPast || isSunday || isHoliday || isAfterMax
          const selected = value === key
          const isToday  = key === ymd(today)
          const titleMsg = isSunday ? 'Domingo: cerrado' : isHoliday ? 'Festivo: cerrado' : ''
          return (
            <button
              key={key}
              type="button"
              className={[
                'cal2__cell',
                disabled ? 'cal2__cell--disabled' : '',
                selected  ? 'cal2__cell--selected' : '',
                isToday   ? 'cal2__cell--today'    : '',
                (isSunday || isHoliday) ? 'cal2__cell--sunday' : '',
              ].filter(Boolean).join(' ')}
              disabled={disabled}
              onClick={() => onChange(key)}
              title={titleMsg}
            >
              {d.getDate()}
            </button>
          )
        })}
      </div>

      <p className="cal2__hint">
        Disponible hasta {monthNames[max.getMonth()]} {max.getFullYear()}. Domingos cerrado.
      </p>
    </div>
  )
}

/* ───────── Slots de hora ────────────────────────────────────────────────── */
function buildSlots(endHourOverride) {
  const out = []
  const { workdayStart, workdayEnd, slotMinutes } = site.appointments
  const endHour = endHourOverride ?? workdayEnd
  for (let h = workdayStart; h < endHour; h++) {
    for (let m = 0; m < 60; m += slotMinutes) {
      out.push({
        h, m,
        label: fmt12h(h, m),
        value: `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`,
      })
    }
  }
  return out
}

/* ───────── Componente principal ─────────────────────────────────────────── */
export default function Agendar() {
  useScrollAnimationAll()

  const [step, setStep]       = useState(1)
  const [errorMsg, setErrorMsg] = useState('')

  const [form, setForm] = useState({
    serviceId: '',
    name: '', phone: '',
    date: '', time: '',
    notes: '',
  })

  const services = site.services

  const selectedService = useMemo(
    () => services.find(s => s.id === form.serviceId) || null,
    [services, form.serviceId]
  )

  const update = (k, v) => setForm(prev => ({ ...prev, [k]: v }))

  const slotsForDate = useMemo(() => {
    if (!form.date) return buildSlots()
    const sel = new Date(`${form.date}T00:00`)
    const dow  = sel.getDay()
    if (dow === 0) return []
    if ((site.appointments.holidays || []).includes(form.date)) return []
    const endHour = dow === 6 ? site.appointments.saturdayEnd : site.appointments.workdayEnd
    const slots   = buildSlots(endHour)
    const now     = new Date()
    if (sel.toDateString() !== now.toDateString()) return slots
    const lead = site.appointments.leadMinutes || 30
    return slots.filter(s => (s.h * 60 + s.m) > (now.getHours() * 60 + now.getMinutes() + lead))
  }, [form.date])

  const goNext = () => {
    setErrorMsg('')
    if (step === 1 && !form.serviceId)    return setErrorMsg('Selecciona un servicio para continuar.')
    if (step === 2) {
      if (!form.name.trim())  return setErrorMsg('Tu nombre es requerido.')
      if (!form.phone.trim()) return setErrorMsg('Tu teléfono es requerido.')
    }
    if (step === 3) {
      if (!form.date) return setErrorMsg('Selecciona una fecha.')
      if (!form.time) return setErrorMsg('Selecciona una hora.')
    }
    setStep(s => Math.min(s + 1, 4))
  }

  const goBack = () => { setErrorMsg(''); setStep(s => Math.max(s - 1, 1)) }

  const handleWhatsApp = () => {
    const h = parseInt(form.time.split(':')[0], 10)
    const m = parseInt(form.time.split(':')[1], 10)
    const fechaFormateada = `${prettyDate(form.date)}, ${fmt12h(h, m)}`

    const mensaje =
      `Reserva de cita — Comprobante de pago\n` +
      `Paciente: ${form.name.trim()}\n` +
      `Teléfono: ${form.phone.trim()}\n` +
      `Servicio: ${selectedService.title}\n` +
      `Fecha y hora: ${fechaFormateada}\n` +
      `Adjunto el comprobante del pago.`

    const url = `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(mensaje)}`
    window.open(url, '_blank', 'noopener,noreferrer')
  }

  return (
    <div className="agendar-page">
      <section className="page-hero">
        <div className="container">
          <div className="page-hero__content animate-fade-up">
            <span className="section-label">Agenda tu cita</span>
            <div className="gold-line" />
            <h1 className="page-hero__title">Empieza tu <em>transformación</em></h1>
            <p className="page-hero__sub">Selecciona el servicio, escoge día y hora, y te contactamos por WhatsApp.</p>
          </div>
        </div>
      </section>

      <section className="section agendar-section">
        <div className="container">

          <ol className="agendar-stepper animate-fade-up">
            {stepsLabels.map((label, i) => {
              const n     = i + 1
              const state = step === n ? 'active' : step > n ? 'done' : ''
              return (
                <li key={label} className={`agendar-step ${state}`}>
                  <span className="agendar-step__num">{n}</span>
                  <span className="agendar-step__label">{label}</span>
                </li>
              )
            })}
          </ol>

          <div className="agendar-layout animate-fade-up">
            <div className="agendar-form-wrap glass-card">

              {/* ── PASO 1 — SERVICIO ── */}
              {step === 1 && (
                <div>
                  <h2 className="agendar-form__title">¿Qué servicio te interesa?</h2>
                  <p className="agendar-date-note">Elige un servicio para iniciar el agendamiento.</p>
                  <div className="services-pick">
                    {services.map(s => (
                      <button
                        type="button"
                        key={s.id}
                        className={`service-pick ${form.serviceId === s.id ? 'selected' : ''}`}
                        onClick={() => update('serviceId', s.id)}
                      >
                        <div className="service-pick__head">
                          <span className="service-pick__title">{s.title}</span>
                          {s.tagline && <span className="service-pick__tag">{s.tagline}</span>}
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* ── PASO 2 — DATOS ── */}
              {step === 2 && (
                <div>
                  <h2 className="agendar-form__title">Datos de contacto</h2>
                  <div className="agendar-field">
                    <label>Nombre completo</label>
                    <input type="text" value={form.name} onChange={e => update('name', e.target.value)} placeholder="Tu nombre y apellido" />
                  </div>
                  <div className="agendar-field">
                    <label>Teléfono / Celular</label>
                    <input type="tel" value={form.phone} onChange={e => update('phone', e.target.value)} placeholder="300 000 0000" />
                  </div>
                  <div className="agendar-field">
                    <label>Comentario adicional (opcional)</label>
                    <textarea rows={4} value={form.notes} onChange={e => update('notes', e.target.value)} placeholder="Cuéntanos sobre tu caso o lo que deseas mejorar…" />
                  </div>
                </div>
              )}

              {/* ── PASO 3 — FECHA Y HORA ── */}
              {step === 3 && (
                <div>
                  <h2 className="agendar-form__title">Fecha preferida</h2>
                  <p className="agendar-date-note">
                    Hasta {site.appointments.yearsAhead} años a futuro. Domingos el consultorio permanece cerrado.
                  </p>
                  <Calendar value={form.date} onChange={(d) => { update('date', d); update('time', '') }} />

                  <h2 className="agendar-form__title" style={{ marginTop: '2rem' }}>Hora</h2>
                  <p className="agendar-date-note">
                    Atención: {fmt12h(site.appointments.workdayStart)} – {fmt12h(site.appointments.workdayEnd)}.
                  </p>
                  <div className="time-grid">
                    {slotsForDate.map(t => (
                      <button
                        type="button"
                        key={t.value}
                        className={`time-slot ${form.time === t.value ? 'selected' : ''}`}
                        onClick={() => update('time', t.value)}
                      >{t.label}</button>
                    ))}
                    {form.date && slotsForDate.length === 0 && (
                      <p className="agendar-date-note" style={{ gridColumn: '1 / -1' }}>
                        No hay horas disponibles ese día. Selecciona otra fecha.
                      </p>
                    )}
                  </div>
                </div>
              )}

              {/* ── PASO 4 — RESUMEN + WHATSAPP ── */}
              {step === 4 && selectedService && (
                <div>
                  <h2 className="agendar-form__title">Resumen de tu cita</h2>
                  <div className="resumen">
                    <div className="resumen-row"><span>Servicio</span><strong>{selectedService.title}</strong></div>
                    <div className="resumen-row"><span>Paciente</span><strong>{form.name}</strong></div>
                    <div className="resumen-row"><span>Teléfono</span><strong>{form.phone}</strong></div>
                    <div className="resumen-row">
                      <span>Fecha y hora</span>
                      <strong>
                        {prettyDate(form.date)} · {fmt12h(parseInt(form.time.split(':')[0], 10), parseInt(form.time.split(':')[1], 10))}
                      </strong>
                    </div>
                    {form.notes.trim() && (
                      <div className="resumen-row"><span>Notas</span><strong>{form.notes}</strong></div>
                    )}
                  </div>
                  <div className="mp-notice">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884"/>
                    </svg>
                    <p>
                      Al confirmar se abrirá WhatsApp con el mensaje prellenado. Adjunta el comprobante del pago para que el doctor confirme tu cita.
                    </p>
                  </div>
                </div>
              )}

              {errorMsg && <div className="agendar-error">{errorMsg}</div>}

              <div className="agendar-actions">
                {step > 1 && (
                  <button type="button" className="btn-secondary" onClick={goBack}>
                    ← Atrás
                  </button>
                )}
                {step < 4 && (
                  <button type="button" className="btn-primary agendar-submit" onClick={goNext}>
                    Continuar
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                  </button>
                )}
                {step === 4 && (
                  <button type="button" className="btn-primary agendar-submit" onClick={handleWhatsApp}>
                    Confirmar por WhatsApp
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884"/>
                    </svg>
                  </button>
                )}
              </div>
            </div>

            <div className="agendar-sidebar">
              <div className="agendar-info glass-card">
                <h3>Información del consultorio</h3>
                <div className="agendar-info-item">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                  <span>{site.location.building}<br />{site.location.street}<br />{site.location.city}, {site.location.state}</span>
                </div>
                <div className="agendar-info-item">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6A19.79 19.79 0 012.12 4.18 2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
                  <span>{site.contact.phone}</span>
                </div>
                <div className="agendar-info-item">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                  <span>Lun–Sáb: {fmt12h(site.appointments.workdayStart)} – {fmt12h(site.appointments.workdayEnd)}<br />Domingo: Cerrado</span>
                </div>
              </div>
              <div className="agendar-note glass-card">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <p>Tu cita queda confirmada cuando el doctor recibe y aprueba el comprobante de pago por WhatsApp.</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}

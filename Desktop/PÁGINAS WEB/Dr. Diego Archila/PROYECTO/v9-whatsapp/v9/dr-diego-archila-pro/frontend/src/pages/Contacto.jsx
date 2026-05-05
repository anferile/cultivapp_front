import React from 'react'
import { Link } from 'react-router-dom'
import { useScrollAnimationAll } from '../hooks/useScrollAnimation'
import { site } from '../config/site'
import './Contacto.css'

export default function Contacto() {
  useScrollAnimationAll()

  return (
    <div className="contacto-page">
      <section className="page-hero">
        <div className="container">
          <div className="page-hero__content animate-fade-up">
            <span className="section-label">Ubicación y contacto</span>
            <div className="gold-line" />
            <h1 className="page-hero__title">Encuéntranos <em>aquí</em></h1>
            <p className="page-hero__sub">{site.location.street}, {site.location.city}, {site.location.state}.</p>
          </div>
        </div>
      </section>

      <section className="section">
        <div className="container">
          <div className="contacto-grid animate-fade-up">
            <div className="contacto-info">
              <div className="contacto-block">
                <h3 className="contacto-block__title">Dirección</h3>
                <p className="contacto-block__text">
                  {site.location.street}<br />
                  {site.location.city}, {site.location.state}<br />
                  {site.location.country}
                </p>
                <a
                  href={site.location.mapsUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="contacto-link"
                >
                  Ver en Google Maps →
                </a>
              </div>

              <div className="contacto-block">
                <h3 className="contacto-block__title">Teléfonos</h3>
                <a href={`tel:${site.contact.phoneE164}`} className="contacto-block__phone">{site.contact.phone}</a>
                <a
                  href={site.contact.whatsapp}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-primary"
                  style={{ marginTop: '1rem', display: 'inline-flex', fontSize: '0.75rem', padding: '0.7rem 1.5rem' }}
                >
                  Escribir por WhatsApp
                </a>
              </div>

              <div className="contacto-block">
                <h3 className="contacto-block__title">Horarios de atención</h3>
                <div className="horarios">
                  {site.hours.map((h) => (
                    <div key={h.dia} className={`horario-row ${h.cerrado ? 'horario-row--cerrado' : ''}`}>
                      <span className="horario-dia">{h.dia}</span>
                      <span className="horario-hora">{h.hora}</span>
                    </div>
                  ))}
                </div>
                <p className="cita-previa-notice">
                  <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
                  Atención únicamente con cita previa
                </p>
              </div>

              <div className="contacto-block">
                <h3 className="contacto-block__title">Redes sociales</h3>
                <div className="contacto-redes">
                  <a href={site.contact.instagram} target="_blank" rel="noopener noreferrer" className="contacto-red">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><rect x="2" y="2" width="20" height="20" rx="5"/><circle cx="12" cy="12" r="5"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none"/></svg>
                    {site.contact.instagramHandle}
                  </a>
                  <a href={site.contact.facebook} target="_blank" rel="noopener noreferrer" className="contacto-red">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"><path d="M18 2h-3a5 5 0 00-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 011-1h3z"/></svg>
                    Facebook
                  </a>
                </div>
              </div>
            </div>

            <div className="contacto-map animate-fade-in">
              <div className="contacto-map__wrap">
                <iframe
                  title={`Ubicación ${site.doctor.name}`}
                  src={site.location.mapsEmbedSrc}
                  allowFullScreen
                  loading="lazy"
                  referrerPolicy="no-referrer-when-downgrade"
                />
              </div>
              <div className="contacto-cta-card glass-card">
                <h3>¿Listo para transformar tu sonrisa?</h3>
                <p>Agenda tu consulta de valoración sin costo y descubramos juntos el tratamiento ideal para ti.</p>
                <Link to="/agendar" className="btn-primary" style={{ justifyContent: 'center' }}>
                  Agendar cita ahora
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}
